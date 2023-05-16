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
import Platform exposing (sendToApp)
import Html exposing (s)


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
  password = "",
  users = [exampleUserPreview, exampleUserPreview],
  activeChatPartner = initialUser,
  messages = [],
  currentText = "",
  errorMessage = "",
  chats = [exampleChatPreview, exampleChatPreview],
  revicedMessageFromServer = {msgType = "nothing"}},  Cmd.none)

initialUser : User
initialUser = {name = "", id = ""}

exampleUserPreview : UserPreview
exampleUserPreview = {user = initialUser, is_online = True}

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
  user = {name="ExName", id="ExID"},
  messages = [exampleMessage, exampleMessage, exampleMessage]
  }
exampleChatPreview : ChatPreview
exampleChatPreview = {
  user = {name="ExName", id="ExID"},
  latest_message = exampleMessage,
  total_message_count = 3,
  unread_message_count = 1 
  }
  


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model.page, msg) of
  (_, SetUsername u) -> ({model | user = {name = u, id = model.user.id}}, Cmd.none)
  (_, SetPassword p) -> ({model | user = {name = model.user.name, id = model.user.id}, password = p}, Cmd.none)
  (_, ValidatePassword p)-> ({model | user = {name = model.user.name, id = model.user.id}}, Cmd.none)
  (_, SubmitRegistration) -> (model, sendMessage (ToJson.encodeRegisterUser model.user model.password))
  (_, SubmitLogin) -> ( model , sendMessage (ToJson.encodeLogin model.user model.password))
  (_, Recv s) -> manageAnswers (returnTypeSave (D.decodeString decodeType s)) s model
  (_, SetPage p) -> changePage p model
  (_, ChangeUserName u) -> ({model | user = {name = u, id = model.user.id}}, Cmd.none)
  (_, ChangePassword p) -> ({model | user = {name = model.user.name, id = model.user.id}, password = p}, Cmd.none)
  (_, SendNewPW) -> (model, Cmd.none)
  (_, StartChat id) -> ({model | page = ChatPage}, sendMessage (ToJson.encodeStartChat id))
  (_, LoadMessages chatPreview) -> ({model | 
    page = ChatPage, 
    activeChatPartner = chatPreview.user }, 
    sendMessage (ToJson.encodeLoadMessages chatPreview.user.id))
  (_, SendChatMessage) -> ({model | page = ChatPage, currentText=""}, sendMessage (ToJson.encodeSendMessage model.activeChatPartner.id model.currentText))
  (_, ChatInput i) -> ({model | currentText=i}, Cmd.none)


manageAnswers : Answertype -> String -> Model -> (Model, Cmd Msg)
manageAnswers t data model = case t.msgType of 
  "login_succeeded" -> ({model | page = ChatPage, errorMessage= "", user = returnUser (D.decodeString decodeLoginSucceded data), revicedMessageFromServer = {msgType = "login_succeeded"}}, 
    Cmd.batch[
    sendMessage (ToJson.encodeLoadChats),
    sendMessage (ToJson.encodeLoadUsers)])
  "chats_loaded" -> ({model | 
      chats = returnChats (D.decodeString decodeChatsLoaded data), 
      revicedMessageFromServer = {msgType = "chats_loaded"}
    }, Cmd.none)
  "users_loaded" -> ({model | users = returnUsers (D.decodeString decodeUsersLoaded data), revicedMessageFromServer = {msgType = "users_loaded"}}, Cmd.none)
  "chat_loaded" -> ({model | 
      page = ChatPage, 
      messages = returnLoadMessages (D.decodeString decodeMessageLoaded data), 
      revicedMessageFromServer = {msgType = "chat_loaded"}}, 
      Cmd.none)
  "error" -> ({model | password = "", errorMessage = returnError (D.decodeString decodeError data)}, Cmd.none)
  "receive_message" -> ({model | 
      revicedMessageFromServer = {msgType = "receive_message"}}, 
      --produces an error
      sendMessage (ToJson.encodeRecievedMessage (returnReceiveMessage (D.decodeString decodeReceiveMessage data))))
      --Cmd.none)
  "user_created" -> ({model | users = returnUserCreated (D.decodeString decodeUserCreated data) :: model.users }, Cmd.none)
  "user_logged_in" -> ({model |users = 
    List.map (\ a -> if a.user.id == (returnUserLoggedIn (D.decodeString decodeUserLoggedIn data)) then {a | is_online = True} else a) model.users, revicedMessageFromServer = {msgType = "user_logged_in"}}, Cmd.none)
  "user_logged_out" -> ({model |users = 
    List.map (\ a -> if a.user.id == (returnUserLoggedOut (D.decodeString decodeUserLoggedOut data)) then {a | is_online = False} else a) model.users, revicedMessageFromServer = {msgType = "user_logged_out"}}, Cmd.none)
  _ -> (model, Cmd.none)

changePage : Page -> Model -> (Model, Cmd Msg)
changePage p model = case p of 
  NewChatPage -> ({model | page = p},Cmd.none)
  ChatPage -> ({model | page = p}, sendMessage (ToJson.encodeLoadChats))
  LoginPage -> ({model | page = p}, Cmd.none)
  RegisterPage -> ({model | page = p}, Cmd.none)
  ProfilePage -> ({model | page = p}, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions _ =
  messageReceiver Recv

view : Model -> Html Msg
view m = case m.page of
  LoginPage -> withLoginContainer m (Login.loginView m.user m.errorMessage)
  RegisterPage -> withLoginContainer m (Register.registerView m.errorMessage)
  ChatPage -> withContainer m (Chat.chatView m.activeChatPartner m.messages m.chats m)
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
    div [id "bubble1"] [],
    div [ class "server-message "] [text model.revicedMessageFromServer.msgType],
    withErrorMessage model.errorMessage
  ]

withContainer : Model -> Html Msg  -> Html Msg
withContainer model content = 
 div [ class "container"] [
  navigation model.page,
  content,
  secureSign,
  div [ class "server-message "] [text model.revicedMessageFromServer.msgType],
  withErrorMessage model.errorMessage
 ]

withErrorMessage : String -> Html Msg
withErrorMessage s = case s of 
  "" -> div [] []
  _ -> div [class "error-message"][
        div [class "error-border"] [],
        div [class "error-icon"] [],
        div [class "error-text"] [
          h2 [] [text "Error"],
          p [] [text s]]
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


  

