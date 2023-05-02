module Main exposing (..)


import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html exposing (nav)
import Html exposing (p)
import Html exposing (ul)
import Html exposing (li, h2, a)
import Html exposing (img)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)
import Html exposing (textarea)


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
    navigation,
    chatList,
    div [ class "chat-wrapper"][
      div [class "chat-header"] [
           text "Name 1"],
    div [class "chat"][
      message,
      message,
      message,
      div [class "chat-item me"] [
           text "Nachricht 2 dfgdg dfgsd gdg fsd"],
      message
    ],
    inputField
    ],
    secureSign
  ]

navigation : Html Msg
navigation = nav [][
      ul [][
        li [][div [class "user-icon"] []],
        li [][div [class "chats-icon"] []],
        li [][div [class "new-icon"] []]
      ]
    ]

chatList : Html Msg
chatList = div [class "chat-list"][
      contactPerson,
      contactPerson,
      contactPerson
    ]
contactPerson : Html Msg
contactPerson = a [class "contact-preview", href "https://www.w3schools.com/howto/img_avatar.png"] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h2 [] [text "Name Person"],
           p [] [text "Meine letzte Nachricht"]
           ]
           ]

message : Html Msg
message = div [class "chat-item"] [
           text "Nachricht 1"]

inputField : Html Msg
inputField = div [class "chat-input"] [
       textarea [ id "message",placeholder "Nachricht"] []
    , button [class "primary-button"] [ div [class "send-icon"] [] ]
    ]

secureSign : Html Msg
secureSign = div [class "secure", title "This chat is End-to-End Encrypted"] [
      div [class "secure-icon"] [
         ]
    ]