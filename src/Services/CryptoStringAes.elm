module Services.CryptoStringAes exposing (..)

import Crypto.Strings exposing (decrypt, justEncrypt)
import Crypto.Strings.Types exposing (Passphrase, Plaintext, Ciphertext)
import Random exposing (Seed, initialSeed)
import Types exposing (Model, Message, PrivateKey, ChatPreview)
import Time
import Services.ParserCrypt exposing (convertPrivateKeyToString, convertStringToPrivateKey)
import String exposing (split)
import Services.Rsa exposing (decryptMessageKey)

-- this is the main encrypt function. It encrypts the plaintext with the passphrase and a timestamp. So the ciphertext is always different
encryptAes : Time.Posix -> Passphrase -> Plaintext -> Ciphertext
encryptAes time passphrase plaintext =
    justEncrypt (initialSeed (Time.posixToMillis time)) passphrase plaintext

-- this is the main decrypt function. It decrypts the ciphertext with the passphrase with aes
decryptAes : Passphrase -> Ciphertext -> Plaintext
decryptAes passphrase ciphertext = case decrypt passphrase ciphertext of
    Ok plaintext -> plaintext
    Err _ -> "Error decrypting"

-- encrypt the RSA Private Key with AES for Store it on the Server
encryptPrivateKeyWithAes : Model -> PrivateKey -> Passphrase -> Ciphertext
encryptPrivateKeyWithAes m sk pw = encryptAes m.time pw (convertPrivateKeyToString sk)

-- decrypt the RSA Private Key with AES that is taken from the Server
decryptPrivateKeyWithAes : Passphrase -> String  -> PrivateKey
decryptPrivateKeyWithAes pw chipertext  = convertStringToPrivateKey (split "," (decryptAes pw chipertext))

-- encrypt the message_key with RSA and encrypt the text with AES to send it to the Server
cryptMessageAes : Model -> Message -> Message
cryptMessageAes model plainMessage = 
  let
    id = encryptAes model.time plainMessage.id model.messageKey
    key = decryptMessageKey model plainMessage.key
    sender_id = encryptAes model.time plainMessage.sender_id model.messageKey
    receiver_id = encryptAes model.time plainMessage.receiver_id model.messageKey
    text = encryptAes model.time plainMessage.text model.messageKey
    send_at = encryptAes model.time  plainMessage.sent_at model.messageKey
    receive_at = case plainMessage.received_at of
      Just x -> Just (encryptAes model.time x model.messageKey)
      Nothing -> Nothing
    read_at = case plainMessage.read_at of
      Just x -> Just (encryptAes  model.time x model.messageKey)
      Nothing -> Nothing
  in
  Message id key sender_id receiver_id text send_at receive_at read_at

-- decrypt the message_key with RSA and decrypt the text with AES to show it to the User
-- If this is a own message, the key is the own passphrase.
-- If this is a message from another user, the key have to be encrypted with the own private key
decryptMessageAes : Model -> Message -> Message
decryptMessageAes model cryptMessage = 
  let
    id = cryptMessage.id
    key = if sender_id /= model.user.id then decryptMessageKey model cryptMessage.key else model.messageKey
    sender_id = cryptMessage.sender_id
    receiver_id = cryptMessage.receiver_id
    text = decryptAes key cryptMessage.text
    send_at = cryptMessage.sent_at
    receive_at = cryptMessage.received_at 
    read_at =  cryptMessage.read_at 
  in
  Message id key sender_id receiver_id text send_at receive_at read_at

-- decrypt the message_key with RSA and decrypt the text with AES to show it to the User
-- If this is a own message, the key is the own passphrase.
-- If this is a message from another user, the key have to be encrypted with the own private key
decryptChatPreviewAes : Model -> ChatPreview -> ChatPreview
decryptChatPreviewAes model chatPreview = 
  let
    id = chatPreview.latest_message.id
    key = if sender_id /= model.user.id then decryptMessageKey model chatPreview.latest_message.key else model.messageKey
    sender_id = chatPreview.latest_message.sender_id
    receiver_id = chatPreview.latest_message.receiver_id
    text = decryptAes key chatPreview.latest_message.text
    send_at = chatPreview.latest_message.sent_at
    receive_at = chatPreview.latest_message.received_at 
    read_at =  chatPreview.latest_message.read_at 
  
    encryptedMessage = Message id key sender_id receiver_id text send_at receive_at read_at
  in
    ChatPreview chatPreview.user encryptedMessage chatPreview.total_message_count chatPreview.unread_message_count
