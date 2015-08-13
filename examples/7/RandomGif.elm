module RandomGif where

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Json
import Task exposing (Task, andThen, onError)
import StartApp exposing (HandledTask, notify)


-- MODEL

type alias Model =
    { topic : String
    , gifUrl : String
    }


init : String -> (Model, List Action)
init topic =
  ( Model topic "assets/waiting.gif"
  , [ RequestMore ]
  )


-- UPDATE

type Action
    = RequestMore
    | NewGif String


update : Signal.Address Action -> Action -> Model -> (Model, Maybe HandledTask)
update address action model =
  case action of
    RequestMore ->
      ( model
      , Just <|
          getRandomGif model.topic
            `andThen` notify address NewGif
            `onError` always (Task.fail ())
            -- normally, another notify ... but the original example doesn't handle
            -- the failure case either
      )

    NewGif url ->
      ( Model model.topic url
      , Nothing
      )


-- VIEW

(=>) = (,)


view : Signal.Address Action -> Model -> Html
view address model =
  div [ style [ "width" => "200px" ] ]
    [ h2 [headerStyle] [text model.topic]
    , div [imgStyle model.gifUrl] []
    , button [ onClick address RequestMore ] [ text "More Please!" ]
    ]


headerStyle : Attribute
headerStyle =
  style
    [ "width" => "200px"
    , "text-align" => "center"
    ]


imgStyle : String -> Attribute
imgStyle url =
  style
    [ "display" => "inline-block"
    , "width" => "200px"
    , "height" => "200px"
    , "background-position" => "center center"
    , "background-size" => "cover"
    , "background-image" => ("url('" ++ url ++ "')")
    ]


-- EFFECTS

getRandomGif : String -> Task Http.Error String
getRandomGif topic =
  Http.get decodeUrl (randomUrl topic)


randomUrl : String -> String
randomUrl topic =
  Http.url "http://api.giphy.com/v1/gifs/random"
    [ "api_key" => "dc6zaTOxFJmzC"
    , "tag" => topic
    ]


decodeUrl : Json.Decoder String
decodeUrl =
  Json.at ["data", "image_url"] Json.string
