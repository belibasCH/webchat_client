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

chatView : Chat -> List ChatPreview -> Html Msg
chatView activeChat chatList = 
  div [class "chat-container"] [
    div [class "chat-list"][
      contactList chatList activeChat
    ],
    div [ class "current-chat"][
      currentChatPartnerView activeChat,

      --Map over ChatPrevies an put it in a div
      List.map chatPreviews (List.reverse (chatList)) |> div [class "chat"],
    
    inputField
    ]
  ]

contactList : List ChatPreview -> Chat -> Html Msg
contactList chats activeChat = 
  case chats of 
    [] -> div [] []
    x::xs -> div [] [contactPerson x activeChat, contactList xs activeChat]


contactPerson :  ChatPreview -> Chat ->  Html Msg
contactPerson chatPreview activeChat = a [if chatPreview.userId == activeChat.chatPartner.user.id then class "contact-preview active" else class "contact-preview" ] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h2 [] [text chatPreview.userId],
           p [] [ text chatPreview.latestMessage.text]
           ]]
           

chatPreviews : ChatPreview -> Html Msg
chatPreviews mes = div [class "chat-item"] [
           p [] [text mes.latestMessage.text]
           ]

inputField : Html Msg
inputField = div [class "chat-input"] [
       textarea [ id "message", placeholder "Nachricht"] []
    , button [class "primary-button"] [ div [class "send-icon"] [] ]
    ]



currentChatPartnerView : Chat -> Html Msg
currentChatPartnerView chat = a [class "contact-preview large", href "https://www.w3schools.com/howto/img_avatar.png"] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h1 [] [text chat.chatPartner.user.id],
           p [] [text "online"]
           ]
           ]