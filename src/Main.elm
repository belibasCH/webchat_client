module Main exposing (..)


import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html exposing (nav)
import Html exposing (p)
import Html exposing (ul)
import Html exposing (li)
import Html exposing (img)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)


main =
  Browser.sandbox { init = init, update = update, view = view }

type alias Model = Int

init : Model
init =
  0

type Msg
  = Increment
  | Decrement

update : Msg -> Model -> Model
update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement ->
      model - 1

view : Model -> Html Msg
view model =
  div [ class "chat-container"] [
    nav [][
      ul [][
        li [][div [class "user-icon"] []],
        li [][div [class "chats-icon"] []],
        li [][div [class "new-icon"] []]
      ]
    ],
    div [class "chat-list"][
      div [] [
           text "Name 1"],
      div [] [
           text "Name 2"],
      div [] [
           text "Name 3"]

    ],
    div [ class "chat-wrapper"][
      div [class "chat-header"] [
           text "Name 1"],
    div [class "chat"][
      div [class "chat-item"] [
           text "Nachricht 1"],
      div [class "chat-item me"] [
           text "Nachricht 2 dfgdg dfgsd gdg fsd"],
      div [class "chat-item"] [
           text "Nachricht 3 sdfsaf sdf "]
    ],
    div [class "chat-input"] [
       input [ id "message",placeholder "Nachricht"] []
    , button [class "primary-button"] [ text ("Senden") ]
    ]
    ],
    div [class "secure"] [
      div [class "secure-icon"] [
         ]
    ]
  ]