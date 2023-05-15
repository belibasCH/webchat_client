module Services.JsonEncoder exposing (..)
import Json.Encode as E
import Types exposing (..)
import Json.Decode exposing (Error)
import Json.Decode exposing (decodeString)
import Json.Decode as D
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

errorChatPreview : ChatPreview
errorChatPreview = {
  user = {id = "Error", name = "Error"},
  latest_message = exampleMessage,
  total_message_count = 3,
  unread_message_count = 1 
  }

encodeRegisterUser : User -> String-> E.Value
encodeRegisterUser u pw =
  E.object
    [ ("type", E.string "create_user")
    , ("username", E.string u.name)
    , ("password", E.string pw)
    ]

encodeLogin : User -> String -> E.Value
encodeLogin u pw=
  E.object
    [ ("type", E.string "login")
    , ("username", E.string u.name)
    , ("password", E.string pw)
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

encodeSendMessage : String -> String -> E.Value
encodeSendMessage receiver_id text =
  E.object
    [ ("type", E.string "send")
    , ("receiver_id", E.string receiver_id)
    , ("text", E.string text)
    ]
    
returnChats : Result Error ChatsLoaded -> List ChatPreview
returnChats r = case r of
  Ok ok -> ok.chats
  Err e -> [{errorChatPreview | user = {id = Debug.toString e, name = Debug.toString e}}]

returnUsers : Result Error UsersLoaded -> List UserPreview
returnUsers r = case r of
  Ok ok -> ok.users
  Err e -> [{user = {id = Debug.toString e, name = Debug.toString e}, is_online = False}]

returnUser : Result Error LoginSucceded ->  User
returnUser r = case r of
  Ok ok -> ok.user
  Err e -> {id = Debug.toString e, name = Debug.toString e}


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
    
decodeUser : D.Decoder User
decodeUser = D.map2 User (D.field "name" D.string)  (D.field "id" D.string) 

returnSave : Result Error LoginSucceded -> LoginSucceded
returnSave s = case s of
  Ok ok -> ok
  Err e -> LoginSucceded "Error" {id = "Error", name = "Error"}

returnLoadMessages : Result Error ChatLoaded -> List Message
returnLoadMessages s = case s of
  Ok ok -> ok.messages
  Err e -> []

decodeMessageLoaded : D.Decoder ChatLoaded
decodeMessageLoaded = D.map2 ChatLoaded 
  (D.field "type" D.string) 
  (D.field "messages" decodeMessages)

decodeMessages : D.Decoder (List Message)
decodeMessages = D.list decodeMessage

