module SpinSquarePair where

import Html exposing (..)
import Html.Attributes exposing (..)
import SpinSquare
import StartApp exposing (HandledTask)


-- MODEL

type alias Model =
    { left : SpinSquare.Model
    , right : SpinSquare.Model
    }


init : (Model, List Action)
init =
  let
    (left, leftFx) = SpinSquare.init
    (right, rightFx) = SpinSquare.init
  in
    ( Model left right
    , List.map Left leftFx ++ List.map Right rightFx
    )


-- UPDATE

type Action
    = Left SpinSquare.Action
    | Right SpinSquare.Action


update : Signal.Address Action -> Action -> Model -> (Model, Maybe HandledTask)
update address action model =
  case action of
    Left act ->
      let
        (left, fx) = SpinSquare.update (Signal.forwardTo address Left) act model.left
      in
        ( Model left model.right
        , fx
        )

    Right act ->
      let
        (right, fx) = SpinSquare.update (Signal.forwardTo address Right) act model.right
      in
        ( Model model.left right
        , fx
        )



-- VIEW

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div [ style [ "display" => "flex" ] ]
    [ SpinSquare.view (Signal.forwardTo address Left) model.left
    , SpinSquare.view (Signal.forwardTo address Right) model.right
    ]
