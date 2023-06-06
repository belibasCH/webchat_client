module Services.InitialData exposing (..)
import Types exposing (..)
import Time
import Crypto.Strings.Types exposing (Passphrase)


initialModel : (Model, Cmd Msg)
initialModel = ({
  page = LoginPage,
  user = initialUser,
  password = "",
  users = [],
  filteredUsers = [],
  activeChatPartner = initialUser,
  messages = [],
  currentText = "",
  errorMessage = "",
  chats = [],
  revicedMessageFromServer = {msgType = "nothing"},
  prime = { p = 0, q = 0 }, 
  publicKey = {e = 0, n = 0},
  privateKey = {p = 0, q = 0, phi = 0, d = 0},
  time = (Time.millisToPosix 0),
  passphrase = ""
  }, Cmd.none)

exampleUserPreview : UserPreview
exampleUserPreview = {user = initialUser, is_online = True}

exampleRecivedMessageFromServer : LoginSucceded
exampleRecivedMessageFromServer = { msgType = "", user = {id = "exID", name = "ExName", avatar = Just "ExAvatar", public_key = PublicKey 3 7}, privateKey = PrivateKey 3 7 2 3, messageKey = "123456789"}
exampleMessage : Message
exampleMessage = {
  id = "ExID", 
  key = "ExKey",
  sender_id = "ExSenID",
  receiver_id = "ExRecID",
  text = "Expample Text",
  sent_at = "ExSentAt",
  received_at = Nothing,
  read_at = Nothing
  }
newMessage :  Model-> Message
newMessage model= {
  id = "", 
  key = "",
  sender_id = model.user.id,
  receiver_id = model.activeChatPartner.id,
  text = model.currentText,
  sent_at = "",
  received_at = Nothing,
  read_at = Nothing
  }

exampleChat : Chat
exampleChat = {
  user = {name="ExName", id="ExID", avatar = Just "ExAvatar", public_key = PublicKey 3 7},
  messages = [exampleMessage, exampleMessage, exampleMessage]
  }
exampleChatPreview : ChatPreview
exampleChatPreview = {
  user = {name="ExName", id="ExID", avatar = Just "ExAvatar", public_key = PublicKey 3 7},
  latest_message = exampleMessage,
  total_message_count = 3,
  unread_message_count = 1 
  }
  


initialUser : User
initialUser = {name = "", id = "", avatar = Just "bild", public_key = PublicKey 0 0}
