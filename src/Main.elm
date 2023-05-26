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
import Html exposing (s)
import File exposing (File)
import Task
import Services.InitialData exposing (..)
import Base64
import Services.Rsa exposing (generatePrimes)
import Tuple exposing (first)
import Tuple exposing (second)
import Services.Rsa exposing (calculatePublicKey)
import Services.Rsa exposing (calculatePrivateKey)
import Crypto.Strings.Types exposing (Passphrase)
import Crypto.Strings.Types exposing (Ciphertext)
import Services.CryptoStringAes exposing (doEncrypt)
import Debug exposing (toString)
import String exposing (split)
import List exposing (filterMap)
import Random exposing (Seed, initialSeed)
import Services.CryptoStringAes exposing (doDecrypt)
import Time exposing (posixToMillis, now)
import Random exposing (step)
import Random exposing (Generator)
import Crypto.Strings.Types exposing (Plaintext)



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


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case (model.page, msg) of
  (_, SetUsername u) -> ({model | user = {name = u, id = model.user.id, avatar = model.user.avatar}}, Cmd.none)
  (_, SetPassword p) -> ({model | user = {name = model.user.name, id = model.user.id, avatar = model.user.avatar}, password = p}, Cmd.none)
  (_, SetAvatar a) -> ({model | user = {name = model.user.name, id = model.user.id, avatar = Just a}}, Cmd.none)
  (_, ValidatePassword p)-> (model, Cmd.none)
  (_, SubmitRegistration) -> ({model | page = LoginPage}, sendMessage (ToJson.encodeRegisterUser model.user model.password))
  (_, SubmitLogin) -> ( model , sendMessage (ToJson.encodeLogin model.user (encodeChatText model model.password)))
  (_, Recv s) -> manageAnswers (returnTypeSave (D.decodeString decodeType s)) (decodeAesChipertext model s) model
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
    sendMessage (ToJson.encodeLoadChats)
    ]
    )
  (_, SendChatMessage) -> ({model | currentText="", messages = ( model.messages  ++ [newMessage model] )}, sendMessage (ToJson.encodeSendMessage model.activeChatPartner.id (encodeChatText model model.currentText)))
  (_, ChatInput i) -> ({model | currentText=i}, Cmd.none)
  (_, SubmitReadMsg id) -> ({model | messages = List.map (\m -> if m.id == id then {m | read_at = Just "now"} else m) model.messages}, Cmd.batch [
    sendMessage (ToJson.encodeMarkAsRead id),
    sendMessage (ToJson.encodeLoadChats)
    ])
  (_, Search s) -> ({model | filteredUsers = List.filter (\u -> String.contains s u.user.name) model.users}, Cmd.none)
  (_, GotFile f) -> (model,  read f)
  (_, ImageLoaded s) -> ({model | user = {name = model.user.name, id = model.user.id, avatar = Just ( s)}}, 
   sendMessage (ToJson.encodeChangeAvatar s))
  (_, GenerateKeyPair) -> (model, generatePrimes) 
  (_, PrimePQ n) -> generateKeyPair model n
  (_, Tick newTime) -> ({model | time = newTime}, Cmd.none)



generateKeyPair : Model -> (Int, Int) -> ( Model, Cmd Msg )
generateKeyPair model n = 
  let
    pk = calculatePrivateKey 11 13-- TODO (first n)(second n)
    sk = calculatePublicKey pk 11 13 --TODO (first n)(second n)
  in
    ({model | prime = { p = 11, q = 13}, privateKey = pk, publicKey = sk}, Cmd.none) -- TODO p = (first n), q = (second n)

encodeChatText : Model -> Plaintext -> Ciphertext
encodeChatText model plaintext= 
  doEncrypt (Time.posixToMillis model.time) model.passphrase plaintext
  

decodeAesChipertext : Model -> Ciphertext -> Plaintext
decodeAesChipertext model chipertext = 
  case doDecrypt model.passphrase chipertext of
    Ok plaintext -> plaintext
    Err _ -> "Error"



-- encrypt the RSA Private Key with AES
encryptRsaPrivateKeyWithAes : Model -> PrivateKey -> Passphrase -> Ciphertext
encryptRsaPrivateKeyWithAes m pk pw = doEncrypt (Time.posixToMillis m.time) pw (privateKeyToString pk)

decryptRsaPrivateKeyWithAes : String -> Passphrase -> PrivateKey
decryptRsaPrivateKeyWithAes chipertext pw = case doDecrypt pw chipertext of
  Ok plaintext -> createPrivateKey (split "," plaintext)
  Err _ -> createPrivateKey ["0","0","0","0"]

  
privateKeyToString : PrivateKey -> String
privateKeyToString pk = 
  let
    p = toString pk.p
    q = toString pk.q
    d = toString pk.d
  in
    p ++ "," ++ q ++ "," ++ d

createPrivateKey : List String -> PrivateKey
createPrivateKey str = 
  let
    valueList = filterMap String.toInt str

    p = case List.head valueList of
      Just x -> x
      Nothing -> 0

    q = case List.head (List.drop 1 valueList) of
      Just x -> x
      Nothing -> 0

    phi = case List.head (List.drop 1 valueList) of
      Just x -> x
      Nothing -> 0

    d = case List.head (List.drop 1 valueList) of
      Just x -> x
      Nothing -> 0
  in
    PrivateKey p q phi d

read : File -> Cmd Msg
read file =
  Task.perform ImageLoaded (File.toUrl file)

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
      --produces an erro
      sendMessage (ToJson.encodeRecievedMessage (returnReceiveMessage (D.decodeString decodeReceiveMessage data)))
      ])--Cmd.none)
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
  NewChatPage -> ({model | page = p}, sendMessage (ToJson.encodeLoadUsers))
  ChatPage -> ({model | page = p}, sendMessage (ToJson.encodeLoadChats))
  LoginPage -> ({model | page = p}, Cmd.none)
  RegisterPage -> ({model | page = p}, Cmd.none)
  ProfilePage -> ({model | page = p}, Cmd.none)


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.batch [messageReceiver Recv, Time.every 1000 Tick]

view : Model -> Html Msg
view m = case m.page of
  LoginPage -> withLoginContainer m (Login.loginView m.user)
  RegisterPage -> withLoginContainer m (Register.registerView m.errorMessage)
  ChatPage -> withContainer m (Chat.chatView m.activeChatPartner m.messages m.chats m)
  NewChatPage -> withContainer m (NewChat.newChatView m)
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


  

