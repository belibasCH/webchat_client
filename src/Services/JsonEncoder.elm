module Services.JsonEncoder exposing (..)
import Json.Encode as E
import Types exposing (..)
import Json.Decode exposing (Error)
import Json.Decode as D
import Maybe exposing (withDefault)
import Services.ParserCrypt exposing (publicKeyToString, stringToPublicKey)
import Services.CryptoStringAes exposing (decryptPrivateKeyWithAes, doEncrypt, doDecrypt, encryptPrivateKeyWithAes)
import Sha256 exposing (sha256)

exampleMessage : Message
exampleMessage = {
  id = "ExID", 
  key = "ExKey",
  sender_id = "ExSenID",
  receiver_id = "ExRecID",
  text = "Expample Text",
  sent_at = "ExSentAt",
  received_at = Just "ExRecAt",
  read_at = Just "ExReadAt"
  }

errorChatPreview : ChatPreview
errorChatPreview = {
  user = {id = "Error", name = "Error", avatar = Nothing, public_key = PublicKey 0 0},
  latest_message = exampleMessage,
  total_message_count = 3,
  unread_message_count = 1 
  }

encodeRegisterUser : Model -> E.Value
encodeRegisterUser m =
  E.object
    [ ("type", E.string "create_user")
    , ("username", E.string m.user.name)
    , ("password", E.string ( sha256 m.password))
    , ("avatar", E.string (withDefault "" m.user.avatar))
    , ("public_key", E.string (publicKeyToString m.tmpPublicKey))
    , ("private_key", E.string (encryptPrivateKeyWithAes m m.privateKey m.password))
    , ("message_key", E.string (doEncrypt m.time m.password m.messageKey))
    ]



encodeLogin : Model -> E.Value
encodeLogin m =
  E.object
    [ ("type", E.string "login")
    , ("username", E.string m.user.name)
    , ("password", E.string (sha256 m.password))
    ]

encodeLoadChats : E.Value
encodeLoadChats =
  E.object
    [ ("type", E.string "load_chats")
    ]
encodeLoadUsers : E.Value
encodeLoadUsers =
  E.object
    [ ("type", E.string "load_users")
    ]

encodeStartChat : String -> E.Value
encodeStartChat receiver_id =
  E.object
    [ ("type", E.string "send")
    , ("receiver_id", E.string receiver_id)
    , ("text", E.string "Chat started")
    
    ]
encodeLoadMessages : String -> E.Value
encodeLoadMessages user_id =
  E.object
    [ ("type", E.string "load_chat")
    , ("user_id", E.string user_id)
    ]

encodeReadMessage : String -> E.Value
encodeReadMessage message_id =
  E.object
    [ ("type", E.string "read")
    , ("message_id", E.string message_id)
    ]
encodeRecievedMessage : String -> E.Value
encodeRecievedMessage message_id =
  E.object
    [ ("type", E.string "received")
    , ("message_id", E.string message_id)
    ]
encodeMarkAsRead : String -> E.Value
encodeMarkAsRead message_id =
  E.object
    [ ("type", E.string "read")
    , ("message_id", E.string message_id)
    ]

encodeSendMessage : String -> String -> Message_Key -> E.Value
encodeSendMessage receiver_id text crypted_message_key =
  E.object
    [ ("type", E.string "send")
    , ("receiver_id", E.string receiver_id)
    , ("text", E.string text)
    , ("key", E.string crypted_message_key)
    ]

encodeChangeAvatar : String -> E.Value
encodeChangeAvatar avatar =
  E.object
    [ ("type", E.string "change_avatar")
    , ("avatar", E.string avatar)
    ]

encodeChangeUserName : String -> E.Value
encodeChangeUserName name =
  E.object
    [ ("type", E.string "change_username")
    , ("username", E.string name)
    ]

encodeChangePassword : String -> E.Value
encodeChangePassword password =
  E.object
    [ ("type", E.string "change_password")
    , ("password", E.string password)
    ]
    
returnChats : Result Error ChatsLoaded -> List ChatPreview
returnChats r = case r of
  Ok ok -> ok.chats
  Err _ -> []

returnUsers : Result Error UsersLoaded -> List UserPreview
returnUsers r = case r of
  Ok ok -> ok.users
  Err _ -> []

returnUser : Result Error LoginSucceded ->  User
returnUser r = case r of
  Ok ok -> ok.user
  Err e -> {id = Debug.toString e, name = Debug.toString e, avatar = Nothing, public_key = stringToPublicKey "Error"}

returnError : Result Error ErrorMessage -> String
returnError r = case r of
  Ok ok -> ok.error
  Err e -> Debug.toString e

returnReceiveMessage : Result Error ReceiveMessage -> String
returnReceiveMessage r = case r of
  Ok ok -> ok.message.id
  Err _ -> "Error decoding message"

returnUserCreated : Result Error UserCreated -> UserPreview
returnUserCreated r = case r of
  Ok ok -> {user = ok.user, is_online = False}
  Err e -> {user = {id = Debug.toString e, name = Debug.toString e, avatar = Nothing, public_key = PublicKey 0 0}, is_online = False}

returnUserLoggedIn : Result Error UserLoggedIn -> String
returnUserLoggedIn r = case r of
  Ok ok -> ok.id
  Err e -> Debug.toString e

returnUserLoggedOut : Result Error UserLoggedOut -> String
returnUserLoggedOut r = case r of
  Ok ok -> ok.id
  Err e -> Debug.toString e


decodeError : D.Decoder ErrorMessage
decodeError = D.map2 ErrorMessage (D.field "type" D.string) (D.field "error" D.string)

decodeReceiveMessage : D.Decoder ReceiveMessage
decodeReceiveMessage = D.map2 ReceiveMessage (D.field "type" D.string) (D.field "message" decodeMessage)

decodeUserCreated : D.Decoder UserCreated
decodeUserCreated = D.map2 UserCreated (D.field "type" D.string) (D.field "user" decodeUser)

decodeUserLoggedIn : D.Decoder UserLoggedIn
decodeUserLoggedIn = D.map2 UserLoggedIn (D.field "type" D.string) (D.field "user_id" D.string)

decodeUserLoggedOut : D.Decoder UserLoggedOut
decodeUserLoggedOut = D.map2 UserLoggedOut (D.field "type" D.string) (D.field "user_id" D.string)

decodeChatsLoaded : D.Decoder ChatsLoaded
decodeChatsLoaded = D.map2 ChatsLoaded 
  (D.field "type" D.string) 
  (D.field "chats" decodeChats)

decodeUsersLoaded : D.Decoder UsersLoaded
decodeUsersLoaded = D.map2 UsersLoaded 
  (D.field "type" D.string) 
  (D.field "users" decodeUsers)

decodeUsers : D.Decoder (List UserPreview)
decodeUsers = D.list decodeUserPreview

decodeUserPreview : D.Decoder UserPreview
decodeUserPreview = D.map2 UserPreview 
  (D.field "user" decodeUser)
  (D.field "is_online" D.bool)

decodeChats : D.Decoder (List ChatPreview)
decodeChats = D.list decodeChatPreview

decodeChatPreview : D.Decoder ChatPreview
decodeChatPreview = D.map4 ChatPreview 
  (D.field "user" decodeUser) 
  (D.field "latest_message" decodeMessage) 
  (D.field "total_message_count" D.int) 
  (D.field "unread_message_count" D.int)

decodeMessage : D.Decoder Message
decodeMessage = D.map8 Message
  (D.field "id" D.string) 
  (D.field "key" D.string)
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
  Err _ -> Answertype "Error"
  

decodeLoginSucceded : Model -> D.Decoder LoginSucceded
decodeLoginSucceded m = D.map4 LoginSucceded (D.field "type" D.string) (D.field "user" decodeUser) (decodePrivateKey m)(decodeMessageKey m)
    
decodeUser : D.Decoder User
decodeUser = D.map4 User (D.field "name" D.string)  (D.field "id" D.string) (D.field "avatar" (D.nullable D.string)) (D.field "public_key" (D.map stringToPublicKey D.string))

decodePrivateKey : Model -> D.Decoder PrivateKey
decodePrivateKey model = D.map (decryptPrivateKeyWithAes  model.password) (D.field "private_key" D.string)

decodeMessageKey : Model -> D.Decoder Message_Key
decodeMessageKey model= D.map (doDecrypt  model.password) (D.field "message_key" D.string)

returnSave : Result Error LoginSucceded -> LoginSucceded
returnSave s = case s of
  Ok ok -> ok
  Err e -> LoginSucceded "Error" {id = "Error", name = "Error" , avatar = Nothing, public_key = PublicKey 0 0} (PrivateKey 0 0 0 0) "Error"

returnLoadMessages : Result Error ChatLoaded -> List Message
returnLoadMessages s = case s of
  Ok ok -> ok.messages
  Err _ -> []

decodeMessageLoaded : D.Decoder ChatLoaded
decodeMessageLoaded = D.map2 ChatLoaded 
  (D.field "type" D.string) 
  (D.field "messages" decodeMessages)

decodeMessages : D.Decoder (List Message)
decodeMessages = D.list decodeMessage

decodeMessageRead : D.Decoder ReadMessage
decodeMessageRead = D.map2 ReadMessage 
  (D.field "type" D.string) 
  (D.field "message_id" D.string)

returnMessageRead : Result Error ReadMessage -> String
returnMessageRead s = case s of
  Ok ok -> ok.id
  Err _ -> "Error"

returnPrivateKey : Result Error PrivateKey  -> PrivateKey
returnPrivateKey s = case s of
  Ok ok ->  ok
  Err e -> PrivateKey 0 0 0 0

returnMessageKey : Result Error Message_Key  -> Message_Key
returnMessageKey s = case s of
  Ok ok ->  ok
  Err e -> "Error"