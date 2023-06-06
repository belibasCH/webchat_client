module Types exposing (..)
import Html exposing (text)
import Json.Decode as D
import Json.Encode as E
import Html.Attributes exposing (type_)
import Html.Attributes exposing (id)
import List exposing (filter)
import File exposing (File)
import Browser.Navigation exposing (Key)
import Time
import Crypto.Strings.Types exposing (Passphrase)


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
  revicedMessageFromServer : Answertype,
  prime : PrimePair,
  publicKey : PublicKey,
  privateKey : PrivateKey,
  time : Time.Posix,
  passphrase : String
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
  messageKey : Passphrase
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
type alias Passphrase = String
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

type alias KeyPair = {
  publicKey : PublicKey,
  privateKey : PrivateKey
  }

type alias CryptedInt = Int 