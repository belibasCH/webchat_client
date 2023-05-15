module Types exposing (..)
import Html exposing (text)
import Json.Decode as D
import Json.Encode as E
import Html.Attributes exposing (type_)

type alias Model = {
  page : Page,
  user : User,
  users : List UserPreview,
  activeChat : Chat,
  chats : List ChatPreview,
  revicedMessageFromServer : LoginSucceded
  }
type Msg
  =   SubmitRegistration
    |   SubmitLogin
    |   Recv String
    |   SetUsername String
    |   SetPassword String
    |   ValidatePassword String
    |   SetPage Page
    |   ChangeUserName String
    |   ChangePassword String
    |   SendNewPW
    |   LoadChats
  
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
type alias UserShort = {
  name : String,
  id : String
  }

type alias LoginSucceded = {
  msgType : String,
  user : UserShort
  }
type alias DateTime = String

