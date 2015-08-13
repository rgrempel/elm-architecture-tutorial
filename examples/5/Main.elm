
import RandomGif exposing (init, update, view)
import StartApp
import Task


app =
  StartApp.start
    { init = init "funny cats"
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html

{- Note that the more desirable signature would be

    port tasks : Signal StartApp.HandledTask

However, the compiler then produces the following error:

    -- PORT ERROR --------------------------------------------------------- Main.elm

    Trying to send an unsupported type through outbound port `tasks`

    20| port tasks : Signal StartApp.HandledTask
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    The specific unsupported type is:

        Task.Task () ()

    The types of values that can flow through outbound ports include:
    Ints, Floats, Bools, Strings, Maybes, Lists, Arrays, Tuples,
    Json.Values, and concrete records.

Now, clearly Task.Task () () is actually a supported type, so the compiler must
not be thinking through the type alias as well as it should in this context.
-}
port tasks : Signal (Task.Task () ())
port tasks =
  app.tasks


