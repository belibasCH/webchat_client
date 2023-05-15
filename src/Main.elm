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
  revicedMessageFromServer = "Response" },  Cmd.none)

initialUser : User
initialUser = {name = "Name Person1", id = "314258b5-a16f-46fe-93e5-82ca0e26e302", password ="",avatar = "https://www.w3schools.com/howto/img_avatar.png"}

exampleUserPreview : UserPreview
exampleUserPreview = {user = initialUser, isonline = True}

exampleMessage : Message
exampleMessage = {
  id = "12345", 
  senderId = "314258b5-a16f-46fe-93e5-82ca0e26e302",
  reciverId = "314258b5-a16f-46fe-93e5-82ca0e26e301",
  text = "Nachricht 1",
  sentAt = "12:00 Uhr",
  recivedAt = "13:00 Uhr",
  readAt = "14:00 Uhr"
  }

exampleChat : Chat
exampleChat = {
  messages = [exampleMessage, exampleMessage, exampleMessage],
  chatPartner = exampleUserPreview
  }
exampleChatPreview : ChatPreview
exampleChatPreview = {
  userId = "314258b5-a16f-46fe-93e5-82ca0e26e301",
  latestMessage = exampleMessage,
  totalMessageCount = 3,
  unreadMessageCount = 1 
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
  (_, Recv s) -> ({model | revicedMessageFromServer = s}, Cmd.none)
  (_, SetPage p) -> ({model | page = p}, Cmd.none)
  (_, ChangeUserName u) -> ({model | user = {name = u, id = model.user.id, password = model.user.password, avatar = model.user.avatar}}, Cmd.none)
  (_, ChangePassword p) -> ({model | user = {name = model.user.name, id = model.user.id, password = p, avatar = model.user.avatar}}, Cmd.none)
  (_,  SendNewPW) -> (model, Cmd.none)
  (_, LoadChats) -> (model, sendMessage (ToJson.encodeLoadChats))


-- parseUser : D.Decoder User
-- parseUser = D.map2 User
--   (D.field "name" D.string)
--   (D.field "id" D.string)







-- {
--     "type": "login_succeeded",
    
--     // The authenticated user.
--     "user": User
-- }


-- quoteDecoder : Decoder Quote
-- quoteDecoder =
--   map4 Quote
--     (field "quote" string)
--     (field "source" string)
--     (field "author" string)
--     (field "year" int)

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
  text model.revicedMessageFromServer
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


  

