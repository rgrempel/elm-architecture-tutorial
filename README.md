# An Alternate Elm Architecture

This branch represents an attempt to think through a variation of The Elm Architecture
which uses 'plain old tasks' to perform effects, rather than a special Effects type.

To do this, I've reworked examples 5 through 8 using a 
[local variation of StartApp.elm](start-app/StartApp.elm). 

You can see both the changes to the examples, and the changes to StartApp, at the
following commit:

[a08dbe8d37392684174af18df08c97d6b077c2b4](https://github.com/rgrempel/elm-architecture-tutorial/commit/a08dbe8d37392684174af18df08c97d6b077c2b4)

You can also check out this branch (plain-old-tasks) and run the examples in
elm-reactor, just like the original examples. But it's not super-interesting,
since they do exactly the same thing as the originals ...

So, it's really the differences in the commit that are potentially interesting.
