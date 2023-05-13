module Types exposing (..)

type Msg
  =   Submit
    |   Recv String
    |   SetUsername String
    |   SetPassword String
    |   ValidatePassword String
    |   SetPage Page
  

-- type LoginMsg
--   = Submit
--   | ChangeUsername String
--   | ChangePassword String

-- type ChatMsg
--   = SendMessage




type alias LoginInfo = {
  username : String,
  password : String
  }
type alias ChatInfo = {
  currentText : String,
  currentChat : Chat,
  chatList : List Chat
  }


type Page 
  = LoginPage
  | RegisterPage
  | ChatPage
  | NewChatPage 
    | ProfilePage

type alias Chat = { 
  chatPartner : User, 
  messages : List Message
  }
type alias Message = {
  content : String,
  timestamp : String
  }
type alias User = {
  name : String,
  id : Int,
  avatar : String
  }

