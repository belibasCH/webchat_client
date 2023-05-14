module Types exposing (..)
import Html exposing (text)

type alias Model = {
  page : Page,
  user : User,
  users : List UserPreview,
  activeChat : Chat,
  chats : List ChatPreview,
  revicedMessageFromServer : String

  }
type Msg
  =   Submit
    |   Recv String
    |   SetUsername String
    |   SetPassword String
    |   ValidatePassword String
    |   SetPage Page
    |   ChangeUserName String
    |   ChangePassword String
  
type alias ChatInfo = {
  currentText : String,
  currentChat : Chat,
  chatList : List Chat
  }
type alias UserPreview = {
    user : User,
    isonline : Bool
    }

type alias ChatPreview = {
    userId : String,
    latestMessage : Message,
    totalMessageCount : Int,
    unreadMessageCount : Int
    }


type Page 
  = LoginPage
  | RegisterPage
  | ChatPage
  | NewChatPage 
    | ProfilePage

type alias Chat = { 
  chatPartner : UserPreview, 
  messages : List Message
  }
type alias Message = {
  id : String,
  senderId : String,
  reciverId : String,
  text : String,
  sentAt : DateTime,
  recivedAt : DateTime,
  readAt : DateTime
  }
type alias User = {
  name : String,
  id : String,
  password: String,
  avatar : String
  }
type alias DateTime = String

