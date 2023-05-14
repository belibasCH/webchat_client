port module Main exposing (..)

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
import Page.ChatView as Chat exposing (..)
import Page.ProfileView as Profile exposing (..)
import Page.LoginView as Login exposing (..)
import Page.RegisterView as Register exposing (..)
import Page.NewChatView as NewChat exposing (..)
import Types exposing (..)
import Debug exposing (log)
import List exposing (head)
import List exposing (sum)
import Json.Decode as D
import Json.Encode as E
import Html.Attributes exposing (classList)

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
  recivedMessage = "",
  chatInfo = {
    currentText = "", 
    currentChat = currtenChat, 
    chatList = chatList}, 
  loginInfo = {username = "", password = ""},
  currentUser = {name = "Name Person1", id = 1, avatar = "https://www.w3schools.com/howto/img_avatar.png"}  },
  Cmd.none)



type alias Model = {
  page : Page,
  recivedMessage : String,
  loginInfo : LoginInfo,
  chatInfo : ChatInfo,
  currentUser : User
  }


currtenChat : Chat
currtenChat = { chatPartner = { 
    name = "Name Person1",
    id = 1, 
    avatar = "https://www.w3schools.com/howto/img_avatar.png"}, 
    messages = [
      { content = "Nachricht 1 P1", timestamp = "12:00 Uhr"}, 
      { content = "Nachricht 2 p2", timestamp = "12:00 Uhr"}
      ]
  }
--page  = LoginPage {username = "", password = ""
  
chatList : List Chat
chatList = [
  { chatPartner = { 
    name = "Name Person1",
    id = 1, 
    avatar = "https://www.w3schools.com/howto/img_avatar.png"}, 
    messages = [
      { content = "Nachricht 1 P1", timestamp = "12:00 Uhr"}, 
      { content = "Nachricht 2 p2", timestamp = "12:00 Uhr"}
      ]
  },
  { chatPartner = { 
    name = "Name Person2", 
    id = 2,
    avatar = "https://www.w3schools.com/howto/img_avatar.png"}, 
    messages = [
      { content = "Nachricht 1 - P2", timestamp = "12:00 Uhr"}, 
      { content = "Nachricht 2 -p2", timestamp = "12:00 Uhr"},
      { content = "Nachricht 3 -p2", timestamp = "12:00 Uhr"}
      ]
  }]




update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model.page, msg) of
  (_, SetUsername u) -> ({model | loginInfo = {username = u, password = model.loginInfo.password}}, Cmd.none)
  (_, SetPassword p) -> ({model | loginInfo = {username = model.loginInfo.username, password = p}}, Cmd.none)
  (_, ValidatePassword p)-> ({model | loginInfo = {username = model.loginInfo.username, password = p}}, Cmd.none)
  (_, Submit) -> ({model | page = ChatPage}, sendMessage (encode model.loginInfo.username))
  (_, Recv s) -> ({model | page = ChatPage , recivedMessage = s}, Cmd.none)
  (_, SetPage p) -> ({model | page = p}, Cmd.none)
  (_, ChangeUserName u) -> ({model | currentUser = {name = u, id = model.currentUser.id, avatar = model.currentUser.avatar}}, Cmd.none)
  (_, ChangePassword p) -> ({model | currentUser = {name = model.currentUser.name, id = model.currentUser.id, avatar = model.currentUser.avatar}}, Cmd.none)

encode : String -> E.Value
encode s =
  E.object
    [ ("type", E.string s)
    , ("username", E.string s)
    , ("password", E.string s)
    ]

    --TBD
   -- ChangeText  s -> { model | page = { model.page | currentText = s}}
    --SetChat chat -> { model | page = ChatPage {currentText = "", currentChat = chat, chatList = model.page.chatList}}

subscriptions : Model -> Sub Msg
subscriptions _ =
  messageReceiver Recv

view : Model -> Html Msg
view m = case m.page of
  LoginPage -> withLoginContainer m (Login.loginView m.loginInfo)
  RegisterPage -> withLoginContainer m (Register.registerView m.loginInfo)
  ChatPage -> withContainer m (Chat.chatView m.chatInfo)
  NewChatPage -> withContainer m (NewChat.newChatView m.chatInfo)
  ProfilePage -> withContainer m (Profile.profileView m.currentUser)


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
  secureSign
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


  

