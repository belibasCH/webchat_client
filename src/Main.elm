port module Main exposing (..)
import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Maybe exposing (withDefault)
import Page.ChatView as Chat exposing (..)
import Page.ProfileView as Profile exposing (..)
import Page.LoginView as Login exposing (..)
import Page.RegisterView as Register exposing (..)
import Page.NewChatView as NewChat exposing (..)
import Services.JsonEncoder as ToJson exposing (..)
import List exposing (..)
import Json.Encode as E
import Json.Decode as D
import File exposing (File)
import Task
import Services.InitialData exposing (..)
import Page.Templates exposing (..)


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

subscriptions : Model -> Sub Msg
subscriptions _ =
  messageReceiver Recv



update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model.page, msg) of
  (_, SetUsername u) -> ({model | user = {name = u, id = model.user.id, avatar = model.user.avatar}}, Cmd.none)
  (_, SetPassword p) -> ({model | user = {name = model.user.name, id = model.user.id, avatar = model.user.avatar}, password = p}, Cmd.none)
  (_, SetAvatar a) -> ({model | user = {name = model.user.name, id = model.user.id, avatar = Just a}}, Cmd.none)
  (_, ValidatePassword _)-> (model, Cmd.none)
  (_, SubmitRegistration) -> ({model | page = LoginPage}, sendMessage (ToJson.encodeRegisterUser model.user model.password))
  (_, SubmitLogin) -> ( model , sendMessage (ToJson.encodeLogin model.user model.password))
  (_, Recv s) -> manageAnswers (returnTypeSave (D.decodeString decodeType s)) s model
  (_, SetPage p) -> changePage p model
  (_, ChangeUserName) -> (model, sendMessage (ToJson.encodeChangeUserName model.user.name))
  (_, ChangePassword) -> (model, sendMessage (ToJson.encodeChangePassword model.password))
  (_, ChangeAvatar) -> (model, sendMessage (ToJson.encodeChangeAvatar (withDefault "" model.user.avatar)))
  (_, SendNewPW) -> (model, Cmd.none)
  (_, StartChat userPreview) -> ({model | page = ChatPage, activeChatPartner = userPreview.user }, sendMessage (ToJson.encodeLoadMessages userPreview.user.id))
  (_, LoadMessages chatPreview) -> ({model | 
    page = ChatPage, 
    activeChatPartner = chatPreview.user },Cmd.batch[
    sendMessage (ToJson.encodeLoadMessages chatPreview.user.id),
    sendMessage (ToJson.encodeLoadChats)])
  (_, SendChatMessage) -> ({model | currentText="", messages = ( model.messages  ++ [newMessage model] )}, sendMessage (ToJson.encodeSendMessage model.activeChatPartner.id model.currentText))
  (_, ChatInput i) -> ({model | currentText=i}, Cmd.none)
  (_, SubmitReadMsg id) -> ({model | messages = List.map (\m -> if m.id == id then {m | read_at = Just "now"} else m) model.messages}, Cmd.batch [
    sendMessage (ToJson.encodeMarkAsRead id),
    sendMessage (ToJson.encodeLoadChats)
    ])
  (_, Search s) -> ({model | filteredUsers = List.filter (\u -> String.contains s u.user.name) model.users}, Cmd.none)
  (_, GotFile f) -> (model,  read f)
  (_, ImageLoaded s) -> ({model | user = {name = model.user.name, id = model.user.id, avatar = Just ( s)}}, 
   sendMessage (ToJson.encodeChangeAvatar s))

  

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
  "users_loaded" -> ({model | users = returnUsers (D.decodeString decodeUsersLoaded data), filteredUsers = returnUsers(D.decodeString decodeUsersLoaded data), revicedMessageFromServer = {msgType = "users_loaded"}}, Cmd.none)
  "chat_loaded" -> ({model | 
      page = ChatPage, 
      messages = returnLoadMessages (D.decodeString decodeMessageLoaded data), 
      revicedMessageFromServer = {msgType = "chat_loaded"}}, 
      Cmd.none)
  "error" -> ({model | password = "", errorMessage = returnError (D.decodeString decodeError data)}, Cmd.none)
  "receive_message" -> ({model | 
      revicedMessageFromServer = {msgType = "receive_message"}}, Cmd.batch[
      sendMessage (ToJson.encodeLoadMessages model.activeChatPartner.id),
      sendMessage (ToJson.encodeLoadChats),
      sendMessage (ToJson.encodeRecievedMessage (returnReceiveMessage (D.decodeString decodeReceiveMessage data)))
      ])
  "user_created" -> ({model | users = returnUserCreated (D.decodeString decodeUserCreated data) :: model.users }, Cmd.none)
  "user_logged_in" -> ({model |users = 
    List.map (\ a -> if a.user.id == (returnUserLoggedIn (D.decodeString decodeUserLoggedIn data)) then {a | is_online = True} else a) model.users, revicedMessageFromServer = {msgType = "user_logged_in"}}, Cmd.none)
  "user_logged_out" -> ({model |users = 
    List.map (\ a -> if a.user.id == (returnUserLoggedOut (D.decodeString decodeUserLoggedOut data)) then {a | is_online = False} else a) model.users, revicedMessageFromServer = {msgType = "user_logged_out"}}, Cmd.none)
  "message_read" -> ({model | 
      messages = 
        List.map (\ a -> if a.id == (returnMessageRead (D.decodeString decodeMessageRead data)) then {a | read_at = Just "now"} else a) model.messages}, Cmd.batch[
          sendMessage (ToJson.encodeLoadChats),
          sendMessage (ToJson.encodeLoadUsers)])
  _ -> (model, Cmd.none)


changePage : Page -> Model -> (Model, Cmd Msg)
changePage p model = case p of 
  NewChatPage -> ({model | page = p, errorMessage = ""}, sendMessage (ToJson.encodeLoadUsers))
  ChatPage -> ({model | page = p, errorMessage = ""}, sendMessage (ToJson.encodeLoadChats))
  LoginPage -> ({model | page = p, errorMessage = ""}, Cmd.none)
  RegisterPage -> ({model | page = p, errorMessage = ""}, Cmd.none)
  ProfilePage -> ({model | page = p, errorMessage = ""}, Cmd.none)


read : File -> Cmd Msg
read file =
  Task.perform ImageLoaded (File.toUrl file)


view : Model -> Html Msg
view m = case m.page of
  LoginPage -> withLoginContainer m (Login.loginView m.user)
  RegisterPage -> withLoginContainer m (Register.registerView)
  ChatPage -> withContainer m (Chat.chatView m.activeChatPartner m.messages m.chats m)
  NewChatPage -> withContainer m (NewChat.newChatView m)
  ProfilePage -> withContainer m (Profile.profileView m.user)



  

