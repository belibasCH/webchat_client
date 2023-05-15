module Types exposing (..)
import Html exposing (text)
import Json.Decode as D
import Json.Encode as E
import Html.Attributes exposing (type_)

type alias Model = {
  page : Page,
  user : User,
  password : String,
  users : List UserPreview,
  activeChatPartner : User,
  messages : List Message,
  chats : List ChatPreview,
  revicedMessageFromServer : Answertype
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
    |   StartChat String
    |   LoadMessages ChatPreview
  
type alias ChatInfo = {
  currentText : String,
  currentChat : Chat,
  chatList : List Chat
  }
type alias UserPreview = {
    user : User,
    is_online : Bool
    }

type alias ChatPreview = {
    user : User,
    latest_message : Message,
    total_message_count : Int,
    unread_message_count : Int
    }


type Page 
  = LoginPage
  | RegisterPage
  | ChatPage
  | NewChatPage 
    | ProfilePage

type alias Chat = { 
  user : User,
  messages : List Message
  }
type alias Message = {
  id : String,
  sender_id : String,
  receiver_id : String,
  text : String,
  sent_at : String,
  received_at : Maybe String,
  read_at : Maybe String
  }
type alias User = {
  name : String,
  id : String
  }

type alias LoginSucceded = {
  msgType : String,
  user : User
  }
type alias ChatsLoaded = {
  msgType : String,
  chats : List ChatPreview
  }
type alias ChatLoaded = {
  msgType : String,
  messages : List Message
  }
type alias UsersLoaded = {
  msgType : String,
  users : List UserPreview
  }
type alias DateTime = String

type alias Answertype = {
  msgType : String
  }

