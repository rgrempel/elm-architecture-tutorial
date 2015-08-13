module RandomGifPair where

import Html exposing (..)
import Html.Attributes exposing (..)
import StartApp exposing (HandledTask)
import List

import RandomGif


-- MODEL

type alias Model =
    { left : RandomGif.Model
    , right : RandomGif.Model
    }


init : String -> String -> (Model, List Action)
init leftTopic rightTopic =
  let
    (left, leftFx) = RandomGif.init leftTopic
    (right, rightFx) = RandomGif.init rightTopic
  in
    ( Model left right
    , List.map Left leftFx ++ List.map Right rightFx
    )


-- UPDATE

type Action
    = Left RandomGif.Action
    | Right RandomGif.Action


update : Signal.Address Action -> Action -> Model -> (Model, Maybe HandledTask)
update address action model =
  case action of
    Left act ->
      let
        (left, fx) = RandomGif.update (Signal.forwardTo address Left) act model.left
      in
        ( Model left model.right, fx )

    Right act ->
      let
        (right, fx) = RandomGif.update (Signal.forwardTo address Right) act model.right
      in
        ( Model model.left right, fx )


-- VIEW

view : Signal.Address Action -> Model -> Html
view address model =
  div [ style [ ("display", "flex") ] ]
    [ RandomGif.view (Signal.forwardTo address Left) model.left
    , RandomGif.view (Signal.forwardTo address Right) model.right
    ]
