module Types exposing (..)

type Msg
  =   Submit
  

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
  | ChatPage
  | NewChatPage 
  | SettingsPage

type alias Chat = { 
  chatPartner : ChatPartner, 
  messages : List Message
  }
type alias Message = {
  content : String,
  timestamp : String
  }
type alias ChatPartner = {
  name : String,
  id : Int,
  avatar : String
  }

