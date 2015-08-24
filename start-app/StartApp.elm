module StartApp ( start, Config, App, HandledTask, notify, batch ) where
{-| This module helps you start your application in a typical Elm workflow.
It assumes you are following [the Elm Architecture][arch] and using
[elm-effects][]. From there it will wire everything up for you!

**Be sure to [read the Elm Architecture tutorial][arch] to learn how this all
works!**

[arch]: https://github.com/evancz/elm-architecture-tutorial
[elm-effects]: http://package.elm-lang.org/packages/evancz/elm-effects/latest

# Start your Application
@docs start, Config, App

-}

import Html exposing (Html)
import Task
import Maybe exposing (withDefault)
import Ticker exposing (dropWhileWaiting)

-- Note that the original StartApp uses `Task Never ()` in an attempt to force
-- callers to deal explicitly with error conditions. However, it is doubtful
-- whether that actually works, since the original examples do not actually
-- deal with error conditions -- and, do so silently. Also, it seems awkward
-- to force the error handling through the Task's success case -- we have
-- success and failure paths in Task for a reason, after all.

{-} A convenient alias for a task where the 'real' result and error have been
handled. The 'tuple 0' () is a convenient terminating type because the result
and error will often be deaflt with using something like:

    actualTask
    `andThen` notify address HandleResult
    `onError` notify address HandleError

... which, given the return type of `notify`, will produce a Task () ()
-}
type alias HandledTask = Task.Task () ()


-- Note that the notify function probably wouldn't belong here ultimately
-- ... it would make more sense in a task-extra type of package, or perhaps
-- signal-extra, since it would be of some general use.

{-| A convenience for a common pattern, where we want to take the result of
a task and then send it to an address with a tag. For example, if you had
the following types:

    type Action
        = HandleResult Int
        | HandleError String

    mailbox : Mailbox Action
    task : Task Int String

... then you might use `notify` in this way:

    task
        `andThen` notify mailbox.address HandleResult
        `onError` notify mailbox.address HandleError

Of course, the (result -> action) function need not actually be a tag ... it
could be any function that fits the signature.
-}
notify : Signal.Address action -> (result -> action) -> result -> Task.Task x ()
notify address tag result =
    Signal.send address (tag result)


-- Note that this ultimately wouldn't belong here -- instead, it would make
-- sense in a task-extra type of package.

{-| Given a list of tasks, produce a task which executes each task in parallel,
ignoring the results.
-}
batch : List (Task.Task x a) -> HandledTask
batch tasks =
    Task.map (always ()) <|
        Task.sequence <|
            List.map Task.spawn tasks


-- One thing which might not be entirely clear here is why the type for 'init: '
-- is `List action` rather than something like `List HandledTask` or just
-- `HandledTask`. The reason is that when the client code provides the Config,
-- it doesn't have an address yet. So, it doesn't have a way to construct a Task
-- that reports back. However, if it provides an an initial action, we can later
-- hook that up with the address we provide.

{-| The configuration of an app follows the basic model / update / view pattern
that you see in every Elm program.

The `init` transaction will give you an initial model and create any tasks that
are needed on start up.

The `update` and `view` fields describe how to step the model and view the
model.

The `inputs` field is for any external signals you might need. If you need to
get values from JavaScript, they will come in through a port as a signal which
you can pipe into your app as one of the `inputs`.
-}
type alias Config model action =
    { init : (model, List action)
    , update : Signal.Address action -> action -> model -> (model, Maybe HandledTask)
    , view : Signal.Address action -> model -> Html
    , inputs : List (Signal.Signal action)
    }


{-| An `App` is made up of a couple signals:

  * `html` &mdash; a signal of `Html` representing the current visual
    representation of your app. This should be fed into `main`.

  * `model` &mdash; a signal representing the current model. Generally you
    will not need this one, but it is there just in case. You will know if you
    need this.

  * `tasks` &mdash; a signal of tasks that need to get run. Your app is going
    to be producing tasks in response to all sorts of events, so this needs to
    be hooked up to a `port` to ensure they get run.
-}
type alias App model =
    { html : Signal Html
    , model : Signal model
    , tasks : Signal HandledTask
    }


{-| Start an application. It requires a bit of wiring once you have created an
`App`. It should pretty much always look like this:

    app =
        start { init = init, view = view, update = update, inputs = [] }

    main =
        app.html

    port tasks : Signal (Task () ())
    port tasks =
        app.tasks

So once we start the `App` we feed the HTML into `main` and feed the resulting
tasks into a `port` that will run them all.
-}
start : Config model action -> App model
start config =
    let
        -- messages : Signal.Mailbox (Maybe action)
        messages =
            Signal.mailbox Nothing

        -- address : Signal.Address action
        address =
            Signal.forwardTo messages.address Just

        -- update : Maybe action -> (model, Maybe HandledTask) -> (model, Maybe HandledTask)
        update (Just action) (model, _) =
            config.update address action model

        -- inputs : Signal (Maybe action)
        inputs =
            Signal.mergeMany (messages.signal :: List.map (Signal.map Just) config.inputs)

        -- initialTask : Maybe HandledTask
        initialTask =
            Just <|
                batch <|
                    List.map (Signal.send address) (snd config.init)

        -- modelAndTask : Signal (model, Maybe HandledTask)
        modelAndTask =
            Signal.foldp update (fst config.init, initialTask) inputs

        -- model : Signal model
        model =
            Signal.map fst modelAndTask

        -- task : Signal HandledTask
        task =
            Signal.filterMap snd (Task.succeed ()) modelAndTask

    in
        { html = Signal.map (config.view address) (dropWhileWaiting (fst config.init) model)
        , model = model
        , tasks = task
        }
