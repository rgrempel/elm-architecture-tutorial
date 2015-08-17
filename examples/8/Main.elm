
import SpinSquarePair exposing (init, update, view)
import StartApp
import Task
import Ticker


app =
  StartApp.start
    { init = init
    , update = update
    , view = view
    , inputs = []
    }


main =
  app.html


port tasks : Signal (Task.Task () ())
port tasks =
  app.tasks


-- The Ticker module needs this for the same reason that StartApp does ...
-- it's a consequence of the rule that only the main module can create ports.
-- One potential simplification would be for the StartApp config to have an
-- 'outputs' property, roughly analogous to the 'inputs' property above, so
-- that StartApp could merge several signals and and only one port would be
-- required here. But, that wouldn't be much better than this -- one would
-- still have to put `Ticker.tasks` in the outputs property, after all,
-- which isn't much less effort than this.
port tickerTasks : Signal (Task.Task () ())
port tickerTasks =
    Ticker.tasks
