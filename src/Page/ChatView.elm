module Page.ChatView exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Maybe exposing (withDefault)
import Types exposing (..)

chatView : User -> List Message -> List ChatPreview -> Model-> Html Msg
chatView partner messages chatList model = 
  div [class "chat-container"] [
    div [class "chat-list"]
      (List.map (\x -> contactPerson x (Chat partner messages)) chatList)
    ,
    if (model.activeChatPartner.id == "") then
    defaultView 
    else
    div [ class "current-chat"][
      currentChatPartnerView partner,
      div [class "chat"] (List.map (messageView model) (List.reverse(messages))  ),
      inputField model
    ]
  ]

defaultView : Html Msg
defaultView = div [class "no-chat"] [ 
  div [class "no-chat-icon"] [],
  h1 [][text "Kein Chat ausgewählt"],
  p [][text "Wähle einen Chat aus der Liste aus"]


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
         img [src (withDefault "" chatPreview.user.avatar), class "avatar"] [],
    
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
          img [src (withDefault "" user.avatar), class "avatar"] [],
          div [class "contact-text"] [
            h2 [] [text user.name],
           p [] [text ""]
           ]
           ]