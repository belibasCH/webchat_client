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

chatView : User -> List Message -> List ChatPreview -> Model-> Html Msg
chatView partner messages chatList model = 
  div [class "chat-container"] [
    div [class "chat-list"]
      (List.map (\x -> contactPerson x (Chat partner messages)) chatList)
    ,
    div [ class "current-chat"][
      currentChatPartnerView partner,
      --Map over Messages an put it in a div
      div [class "chat"] (List.map (messageView model) (List.reverse(messages))  ),
      inputField model
    ]
  ]

messageView : Model-> Message -> Html Msg
messageView  model mes = div [classList [
  ( "chat-item", True), 
  ("unread", mes.read_at == Nothing),
  ("me", model.user.id == mes.sender_id),
  ("you", model.user.id /= mes.sender_id)
  ], onClick (SubmitReadMsg mes.id)] [
           p [] [text mes.text]
           ]

contactList : List ChatPreview -> Chat -> Html Msg
contactList chats activeChat = 
  case chats of 
    [] -> div [] []
    x::xs -> div [] [contactPerson x activeChat, contactList xs activeChat]


contactPerson :  ChatPreview -> Chat ->  Html Msg
contactPerson chatPreview activeChat = a [ if chatPreview.user.id == activeChat.user.id then class "contact-preview active" else class "contact-preview", onClick (LoadMessages chatPreview)] [
          div [class "contact-details"][
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-text"] [
           h2 [] [text chatPreview.user.name],
           p [] [ text chatPreview.latest_message.text] ]
          ],
            div [classList [
              ("unread", True), 
              ("show", chatPreview.unread_message_count > 0),  
              ("hide", chatPreview.unread_message_count == 0)] ] [ p [][text ((String.fromInt (chatPreview.unread_message_count)))]]
         ]
           



inputField : Model ->  Html Msg
inputField model= div [class "chat-input"] [
       textarea [ id "message", placeholder "Nachricht",value model.currentText, onInput ChatInput] []
    , button [class "primary-button send"] [ div [class "send-icon", onClick SendChatMessage ] [] ]
    ]



currentChatPartnerView : User -> Html Msg
currentChatPartnerView user = div [class "current-chatpartner-profile"] [
          img [src "https://www.w3schools.com/howto/img_avatar.png", class "avatar"] [],
          div [class "contact-text"] [
            h2 [] [text user.name],
           p [] [text ""]
           ]
           ]