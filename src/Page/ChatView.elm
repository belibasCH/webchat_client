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
    div [class "chat-list"]
      (List.map (\x -> contactPerson x activeChat) chatList)
    ,
    div [ class "current-chat"][
      currentChatPartnerView activeChat,
      --Map over Messages an put it in a div
      div [class "chat"] (List.map messageView activeChat.messages),
      inputField
    ]
  ]

messageView : Message -> Html Msg
messageView mes = div [class "chat-item"] [
           p [] [text mes.text]
           ]

contactList : List ChatPreview -> Chat -> Html Msg
contactList chats activeChat = 
  case chats of 
    [] -> div [] []
    x::xs -> div [] [contactPerson x activeChat, contactList xs activeChat]


contactPerson :  ChatPreview -> Chat ->  Html Msg
contactPerson chatPreview activeChat = a [ class "contact-preview", onClick (LoadMessages chatPreview)] [
  --if chatPreview.user_id == activeChat.chatPartner.user.id then class "contact-preview active" else class "contact-preview", onClick (LoadMessages chatPreview)
  
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
           h2 [] [text chatPreview.user_id],
           p [] [ text chatPreview.latest_message.text],
           p [] [ text ((String.fromInt (chatPreview.unread_message_count)) ++ " unread messages")]
           ]]
           



inputField : Html Msg
inputField = div [class "chat-input"] [
       textarea [ id "message", placeholder "Nachricht"] []
    , button [class "primary-button"] [ div [class "send-icon"] [] ]
    ]



currentChatPartnerView : Chat -> Html Msg
currentChatPartnerView chat = a [class "contact-preview large", href "https://www.w3schools.com/howto/img_avatar.png"] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-details"] [
    
           p [] [text "online"]
           ]
           ]