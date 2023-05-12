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
import Maybe exposing (withDefault)
import Page.ChatView as Chat exposing (..)
import Page.LoginView as Login exposing (..)
import Types exposing (..)
import Debug exposing (log)
import List exposing (head)

main : Program () Model Msg
main =
    Browser.element
        { init = \_ -> initialModel
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

initialModel : (Model, Cmd Msg)
initialModel = ({
  page = LoginPage, 
  chatInfo = {
    currentText = "", 
    currentChat = currtenChat, 
    chatList = chatList}, 
  loginInfo = {username = "", password = ""}
  },
  Cmd.none)



type alias Model = {
  page : Page,
  loginInfo : LoginInfo,
  chatInfo : ChatInfo
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
  (LoginPage, Submit) -> ({model | page = ChatPage}, Cmd.none)
  otherwise -> (model, Cmd.none)


    --TBD
   -- ChangeText  s -> { model | page = { model.page | currentText = s}}
    --SetChat chat -> { model | page = ChatPage {currentText = "", currentChat = chat, chatList = model.page.chatList}}

view : Model -> Html Msg
view m = case m.page of
  LoginPage -> Login.loginView m.loginInfo
  ChatPage -> Chat.chatView m.chatInfo

  NewChatPage -> newChatView
  SettingsPage -> settingsView

newChatView : Html Msg
newChatView = div [class "new-chat-container"] [
    div [class "new-chat-wrapper"] [
      h1 [] [text "New Chat"],
      input [class "new-chat-input", placeholder "Username"] [],
      button [class "primary-button"] [text "Create Chat"]
    ]
  ]

settingsView : Html Msg
settingsView = div [class "settings-container"] [
    div [class "settings-wrapper"] [
      h1 [] [text "Settings"],
      input [class "settings-input", placeholder "Username"] [],
      input [class "settings-input", placeholder "Password"] [],
      button [class "primary-button"] [text "Save"]
    ]
  ]

