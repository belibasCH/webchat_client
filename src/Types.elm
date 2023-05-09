module Types exposing (..)

type Msg
  = 
--ChangeText String
 -- | SetChat Chat
  SendMessage


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
  = LoginPage LoginInfo
  | ChatPage ChatInfo
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

