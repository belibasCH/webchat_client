module Main exposing (..)


import Browser
import Html exposing (Html, button, div, text, li, h2, a, h1 , h3, ul,p,nav,textarea, img)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)
import Html exposing (textarea)
import Html.Events exposing (targetValue)


main =
  Browser.sandbox { init = init, update = update, view = view }

type alias Model = {
  currentText : String,
  chatList : List Chat}

type alias Chat = { 
  chatPartner : ChatPartner, 
  messages : List Message
  }
type alias Message = {
  content : String,
  timestamp : String
  }
type alias ChatPartner = {
  name : String,
  id : Int,
  avatar : String
  }

init : Model
init = {currentText = "Hallo", chatList = chatList}

chatList : List Chat
chatList = [
  { chatPartner = { 
    name = "Name Person1",
    id = 1, 
    avatar = "https://www.w3schools.com/howto/img_avatar.png"}, 
    messages = [
      { content = "Nachricht 1", timestamp = "12:00 Uhr"}, 
      { content = "Nachricht 2", timestamp = "12:00 Uhr"}
      ]
  },
  { chatPartner = { 
    name = "Name Person2", 
    id = 2,
    avatar = "https://www.w3schools.com/howto/img_avatar.png"}, 
    messages = [
      { content = "Nachricht 1", timestamp = "12:00 Uhr"}, 
      { content = "Nachricht 2", timestamp = "12:00 Uhr"}
      ]
  }]


type Msg
  = ChangeText String

update : Msg -> Model -> Model
update msg model =
  case msg of
    ChangeText text-> { model | currentText = text }

view : Model -> Html Msg
view model =
  div [ class "chat-container"] [
    div [class "sidebar"] [
    navigation,
    div [class "chat-list"][
      chatListView model.chatList
    ]
    
    ],
    div [ class "chat-wrapper"][
      currentChatPartnerView,
    div [class "chat"][
      message model,
      message model,
      message model,
      div [class "chat-item me"] [
           p [] [text "Nachricht 2 dfgdg dfgsd gdg fsd"]],
      message model
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

chatListView : List Chat -> Html Msg
chatListView chats = List.map contactPerson chats |> div [class "contact-list"]

contactPerson : Chat -> Html Msg
contactPerson chat = a [class "contact-preview", href "https://www.w3schools.com/howto/img_avatar.png" ] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h2 [] [text chat.chatPartner.name],
           p [] [text (getFirst chat.messages)]
           ]
           ]
getFirst : List Message -> String
getFirst messages = 
  case messages of
    [] -> "Keine Nachrichten"
    x::xs -> x.content

message : Model -> Html Msg
message model = div [class "chat-item"] [
           p [] [text model.currentText]]

inputField : Html Msg
inputField = div [class "chat-input"] [
       textarea [ id "message", placeholder "Nachricht", onInput ChangeText] []
    , button [class "primary-button"] [ div [class "send-icon"] [] ]
    ]

secureSign : Html Msg
secureSign = div [class "secure", title "This chat is End-to-End Encrypted"] [
      div [class "secure-icon"] [
         ]
    ]

currentChatPartnerView : Html Msg
currentChatPartnerView = a [class "contact-preview large", href "https://www.w3schools.com/howto/img_avatar.png"] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h1 [] [text "Name Person"],
           p [] [text "Letzte Nachricht um 12:00 Uhr"]
           ]
           ]