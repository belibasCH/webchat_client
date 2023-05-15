port module Main exposing (..)

import Browser
import Html exposing (Html, button, div, text, li, h2, a, h1 , h3, ul,p,nav,textarea, img)
import Html.Events exposing (..)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)
import Html exposing (textarea)
import Html.Events exposing (targetValue)
import Maybe exposing (withDefault)
import Page.ChatView as Chat exposing (..)
import Page.ProfileView as Profile exposing (..)
import Page.LoginView as Login exposing (..)
import Page.RegisterView as Register exposing (..)
import Page.NewChatView as NewChat exposing (..)
import Types exposing (..)
import Debug exposing (log)
import List exposing (head)
import List exposing (sum)
import Json.Encode as E
import Json.Decode as D
import Services.JsonEncoder as ToJson exposing (..)
import Html.Attributes exposing (classList)
import Json.Decode exposing (Error)
import Json.Decode exposing (decodeString)

main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

port sendMessage : E.Value -> Cmd msg
port messageReceiver : (String -> msg) -> Sub msg

initialModel : (Model, Cmd Msg)
initialModel = ({
  page = LoginPage,
  user = initialUser,
  users = [exampleUserPreview, exampleUserPreview],
  activeChat = exampleChat,
  chats = [exampleChatPreview, exampleChatPreview],
  revicedMessageFromServer = {msgType = "nothing"}},  Cmd.none)

initialUser : User
initialUser = {name = "", id = "", password ="",avatar = "https://www.w3schools.com/howto/img_avatar.png"}

exampleUserPreview : UserPreview
exampleUserPreview = {user = initialUser, isonline = True}

exampleRecivedMessageFromServer : LoginSucceded
exampleRecivedMessageFromServer = { msgType = "", user = {id = "exID", name = "ExName"}}
exampleMessage : Message
exampleMessage = {
  id = "ExID", 
  sender_id = "ExSenID",
  receiver_id = "ExRecID",
  text = "Expample Text",
  sent_at = "ExSentAt",
  received_at = Just "ExRecAt",
  read_at = Just "ExReadAt"
  }

exampleChat : Chat
exampleChat = {
  messages = [exampleMessage, exampleMessage, exampleMessage],
  chatPartner = exampleUserPreview
  }
exampleChatPreview : ChatPreview
exampleChatPreview = {
  user_id = "DefaultUser",
  latest_message = exampleMessage,
  total_message_count = 3,
  unread_message_count = 1 
  }
errorChatPreview : ChatPreview
errorChatPreview = {
  user_id = "ErrorUser",
  latest_message = exampleMessage,
  total_message_count = 3,
  unread_message_count = 1 
  }
--page  = LoginPage {username = "", password = ""
  


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model.page, msg) of
  (_, SetUsername u) -> ({model | user = {name = u, id = model.user.id, password = model.user.password, avatar = model.user.avatar}}, Cmd.none)
  (_, SetPassword p) -> ({model | user = {name = model.user.name, id = model.user.id, password = p, avatar = model.user.avatar}}, Cmd.none)
  (_, ValidatePassword p)-> ({model | user = {name = model.user.name, id = model.user.id, password = p, avatar = model.user.avatar}}, Cmd.none)
  (_, SubmitRegistration) -> (model, sendMessage (ToJson.encodeRegisterUser model.user))
  (_, SubmitLogin) -> ( {model | page = ChatPage} , sendMessage (ToJson.encodeLogin model.user))
  (_, Recv s) -> manageAnswers (returnTypeSave (D.decodeString decodeType s)) s model
  (_, SetPage p) -> ({model | page = p}, Cmd.none)
  (_, ChangeUserName u) -> ({model | user = {name = u, id = model.user.id, password = model.user.password, avatar = model.user.avatar}}, Cmd.none)
  (_, ChangePassword p) -> ({model | user = {name = model.user.name, id = model.user.id, password = p, avatar = model.user.avatar}}, Cmd.none)
  (_,  SendNewPW) -> (model, Cmd.none)
  (_, LoadChats) -> (model, sendMessage (ToJson.encodeLoadChats))
--returnSave (D.decodeString decodeType s)

manageAnswers : Answertype -> String -> Model -> (Model, Cmd Msg)
manageAnswers t data model = case t.msgType of 
   "login_succeeded" -> ({model | page = ProfilePage, revicedMessageFromServer = {msgType = "login_succeeded"}}, Cmd.none)
   "chats_loaded" -> ({model | chats = returnChats (D.decodeString decodeChatsLoaded data), revicedMessageFromServer = {msgType = "chats_loaded"}}, Cmd.none)
   _ -> (model, Cmd.none)

returnChats : Result Error ChatsLoaded -> List ChatPreview
returnChats r = case r of
  Ok ok -> ok.chats
  Err e -> [{errorChatPreview | user_id = Debug.toString e}]

decodeChatsLoaded : D.Decoder ChatsLoaded
decodeChatsLoaded = D.map2 ChatsLoaded 
  (D.field "type" D.string) 
  (D.field "chats" decodeChats)

decodeChats : D.Decoder (List ChatPreview)
decodeChats = D.list decodeChatPreview

decodeChatPreview : D.Decoder ChatPreview
decodeChatPreview = D.map4 ChatPreview 
  (D.field "user_id" D.string) 
  (D.field "latest_message" decodeMessage) 
  (D.field "total_message_count" D.int) 
  (D.field "unread_message_count" D.int)

decodeMessage : D.Decoder Message
decodeMessage = D.map7 Message 
  (D.field "id" D.string) 
  (D.field "sender_id" D.string) 
  (D.field "receiver_id" D.string) 
  (D.field "text" D.string) 
  (D.field "sent_at" D.string) 
  (D.field "received_at" (D.nullable D.string)) 
  (D.field "read_at" (D.nullable D.string)) 
  
decodeType : D.Decoder Answertype
decodeType = D.map Answertype (D.field "type" D.string)

returnTypeSave : Result Error Answertype -> Answertype
returnTypeSave r = case r of
  Ok ok -> ok
  Err e -> Answertype "Error"
  

decodeLoginSucceded : D.Decoder LoginSucceded
decodeLoginSucceded = D.map2 LoginSucceded (D.field "type" D.string) (D.field "user" decodeUser)
    
decodeUser : D.Decoder UserShort
decodeUser = D.map2 UserShort (D.field "id" D.string) (D.field "name" D.string) 

returnSave : Result Error LoginSucceded -> LoginSucceded
returnSave s = case s of
  Ok ok -> ok
  Err e -> LoginSucceded "Error" {id = "Error", name = "Error"}

-- {
--     "type": "login_succeeded",
    
--     // The authenticated user.
--     "user": User
-- }


subscriptions : Model -> Sub Msg
subscriptions _ =
  messageReceiver Recv

view : Model -> Html Msg
view m = case m.page of
  LoginPage -> withLoginContainer m (Login.loginView m.user)
  RegisterPage -> withLoginContainer m (Register.registerView)
  ChatPage -> withContainer m (Chat.chatView m.activeChat m.chats)
  NewChatPage -> withContainer m (NewChat.newChatView m.users)
  ProfilePage -> withContainer m (Profile.profileView m.user)


withLoginContainer : Model -> Html Msg  -> Html Msg
withLoginContainer model content = 
  div [] [
    
    div [class "login-container"] [
      nav [class "login-nav"] [
        ul [class "login-nav-list"] [
          li 
            [classList [
              ("login-nav-item", True),
              ("left", True),
              ("active", model.page == LoginPage)
              ],
            onClick (SetPage LoginPage)] [a [class "login-nav-item"] [text "Login"]],
          li 
            [classList [
              ("login-nav-item", True),
              ("right", True),
              ("active", model.page == RegisterPage)
              ],
              onClick (SetPage RegisterPage )] [a [class "login-nav-item"] [text "Register"]] 
          ]
         ],
    content
    ],
    div [id "bubble1"] []
  ]

withContainer : Model -> Html Msg  -> Html Msg
withContainer model content = 
 div [ class "container"] [
  navigation model.page,
  content,
  secureSign,
  text model.revicedMessageFromServer.msgType
 ]

navigation : Page -> Html Msg
navigation page = nav [class "sidebar"][
      ul [][
        li [ classList [
          ("active", page == ProfilePage)
          ],
          onClick (SetPage ProfilePage)
        ][div [class "user-icon"] []],
        li [classList [
          ("active", page == ChatPage)
           ],
          onClick (SetPage ChatPage)
          ][div [class "chats-icon"] []],
        li [classList [
          ("active", page == NewChatPage)
           ],
          onClick (SetPage NewChatPage)
          ][div [class "new-icon"] []]
      ]
    ]

secureSign : Html Msg
secureSign = div [class "secure", title "This chat is End-to-End Encrypted"] [
      div [class "secure-icon"] [
         ]
    ]


  

