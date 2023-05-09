module Page.ChatView exposing (..)
import Browser
import Html exposing (Html, button, div, text, li, h2, a, h1 , h3, ul,p,nav,textarea, img)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)
import Html exposing (textarea)
import Html.Events exposing (targetValue)
import Maybe exposing (withDefault)
import Types exposing (..)

chatView : ChatInfo -> Html Msg
chatView data = 
  div [ class "chat-container"] [
    div [class "sidebar"] [
    navigation,
    div [class "chat-list"][
      contactList data.chatList data 
    ]
    
    ],
    div [ class "chat-wrapper"][
      currentChatPartnerView data.currentChat,

      --Map over messages an put it in a div
      List.map message (List.reverse (data.currentChat.messages)) |> div [class "chat"],
    
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

contactList : List Chat -> ChatInfo -> Html Msg
contactList chats chatInfo = 
  case chats of 
    [] -> div [] []
    x::xs -> div [] [contactPerson chatInfo x, contactList xs chatInfo]


contactPerson :  ChatInfo -> Chat ->  Html Msg
contactPerson chatInfo chat  = a [if chatInfo.currentChat.chatPartner.id == chat.chatPartner.id then class "contact-preview active" else class "contact-preview" ] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h2 [] [text chat.chatPartner.name],
           p [] [text (withDefault "Test"(
            --get last element of messages list
            List.head (List.reverse chat.messages)
            |> Maybe.map .content 
           ))]
           ]
           ]
getFirst : List Message -> String
getFirst messages = 
  case messages of
    [] -> "Keine Nachrichten"
    x::xs -> x.content

message : Message -> Html Msg
message mes = div [class "chat-item"] [
           p [] [text mes.content]
           ]

inputField : Html Msg
inputField = div [class "chat-input"] [
       textarea [ id "message", placeholder "Nachricht"] []
    , button [class "primary-button"] [ div [class "send-icon"] [] ]
    ]

secureSign : Html Msg
secureSign = div [class "secure", title "This chat is End-to-End Encrypted"] [
      div [class "secure-icon"] [
         ]
    ]

currentChatPartnerView : Chat -> Html Msg
currentChatPartnerView chat = a [class "contact-preview large", href "https://www.w3schools.com/howto/img_avatar.png"] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h1 [] [text chat.chatPartner.name],
           p [] [text "online"]
           ]
           ]