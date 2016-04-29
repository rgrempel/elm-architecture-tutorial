# Deprecation Notice

This was a kind of experiment relevant in the Elm 0.16 time-frame. It is unlikely to be
interesting in the Elm 0.17 world or later, since the special `Effects` type has now
been renamed, and has an expanded role.

# An Alternate Elm Architecture

This branch represents an attempt to think through a variation of The Elm Architecture
which uses 'plain old tasks' to perform effects, rather than a special Effects type.

To do this, I've reworked examples 5 through 8 using a 
[local variation of StartApp.elm](start-app/StartApp.elm). 

You can see both the changes to the examples, and the changes to StartApp, at the
following commit:

[a08dbe8d37392684174af18df08c97d6b077c2b4](https://github.com/rgrempel/elm-architecture-tutorial/commit/a08dbe8d37392684174af18df08c97d6b077c2b4)

I have also created a Ticker module that you can use to schedule work to be
done when the browser wants the next animation frame. This is an alternative
to the code in elm-effects which consolidates ticks, with several benefits:

* it's not tightly-coupled to anything; and
* it consolidates all ticks until the next animation frame, whereas elm-effects
  only consolidates a single call to 'update'

[e7fec54b49b19ed099735ca5193054ccfacb0780](https://github.com/rgrempel/elm-architecture-tutorial/commit/e7fec54b49b19ed099735ca5193054ccfacb0780)

Note that I have now broken the Ticker module out into a
[separate package](https://github.com/rgrempel/elm-ticker),
with a significant optimization (it allows you to 'debounce' your view function
so that it only runs once per animation frame).

You can also check out this branch (plain-old-tasks) and run the examples in
elm-reactor, just like the original examples. But it's not super-interesting,
since they do exactly the same thing as the originals ...

So, it's really the differences in the commit that are potentially interesting.
