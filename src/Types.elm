module Types exposing (..)

import File exposing (File)
import Time

type alias Model = {
  page : Page,
  user : User,
  password : String,
  users : List UserPreview,
  filteredUsers : List UserPreview,
  activeChatPartner : User,
  messages : List Message,
  currentText : String,
  errorMessage : String,
  chats : List ChatPreview,
  receivedMessageFromServer : Answertype,
  prime : PrimePair,
  tmpPublicKey : PublicKey, -- when user was created, this public will encrypted an send to server. After Login the public key will be in the User object
  privateKey : PrivateKey,
  time : Time.Posix,
  messageKey : String
  }
type Msg
  =   SubmitRegistration
    |   SubmitLogin
    |   Recv String
    |   SetUsername String
    |   SetPassword String
    |   SetPassphrase String
    |   ValidatePassword String
    |   SetPage Page
    |   ChangeUserName
    |   ChangePassword 
    |   SendNewPW
    |   StartChat UserPreview
    |   LoadMessages ChatPreview
    |   ChatInput String
    |   SendChatMessage
    |   SubmitReadMsg String
    |   Search String
    |   SetAvatar String
    |   ChangeAvatar 
    |   GotFile File
    |   ImageLoaded String
    |   PrimePQ (Int, Int)
    |   Passphrase (List Int)
    |   GenerateKeyPair
    |   Tick Time.Posix
  
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
  key : String,
  sender_id : String,
  receiver_id : String,
  text : String,
  sent_at : String,
  received_at : Maybe String,
  read_at : Maybe String
  }
type alias User = {
  name : String,
  id : String,
  avatar : Maybe String,
  public_key : PublicKey
  }

type alias LoginSucceded = {
  msgType : String,
  user : User,
  privateKey : PrivateKey,
  messageKey : Message_Key
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
type alias ErrorMessage = {
  msgType : String,
  error : String
  }
type alias ReadMessage ={
  msgType : String,
  id : String
  }

type alias ReceiveMessage = {
  msgType : String,
  message : Message
  }
type alias UserCreated = {
  msgType : String,
  user : User
  }
type alias UserLoggedIn = {
  msgType : String,
  id : String
  }
type alias UserLoggedOut = {
  msgType : String,
  id : String
  }

type alias Prime = Int
type alias Message_Key = String
type alias PrimePair = {
  p : Prime,
  q : Prime
  }

type alias PublicKey = {
  e : Int,
  n : Int
  }

type alias PrivateKey = {
  p : Int,
  q : Int,
  phi : Int,
  d : Int
  }