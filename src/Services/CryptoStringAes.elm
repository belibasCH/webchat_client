module Services.CryptoStringAes exposing (..)

import Crypto.Strings exposing (decrypt, encrypt, justEncrypt)
import Crypto.Strings.Types exposing (Passphrase, Plaintext, Ciphertext)
import Random exposing (Seed, initialSeed)
import Random exposing (initialSeed)
import Types exposing (Model)
import Types exposing (PrivateKey)
import Time
import Services.ParserCrypt exposing (privateKeyToString)
import String exposing (split)
import List exposing (filterMap)
import Types exposing (Message)
import Services.Rsa exposing (decryptMessageKey)
import Types exposing (ChatPreview)

{-| In real code, you'd pass in a seed created from a time, not a time.
-}
doEncrypt : Time.Posix -> Passphrase -> Plaintext -> Ciphertext
doEncrypt time passphrase plaintext =
    justEncrypt (Random.initialSeed (Time.posixToMillis time)) passphrase plaintext

tryDecrypt : Passphrase -> Ciphertext -> Result String Plaintext
tryDecrypt passphrase ciphertext =
    decrypt passphrase ciphertext

doDecrypt : Passphrase -> Ciphertext -> Plaintext
doDecrypt passphrase ciphertext =
    case tryDecrypt passphrase ciphertext of
        Ok plaintext -> plaintext
        Err _ -> ""



-- encrypt the RSA Private Key with AES
encryptRsaPrivateKeyWithAes : Model -> PrivateKey -> Passphrase -> Ciphertext
encryptRsaPrivateKeyWithAes m pk pw = doEncrypt m.time pw (privateKeyToString pk)

decryptRsaPrivateKeyWithAes : Passphrase -> String  -> PrivateKey
decryptRsaPrivateKeyWithAes pw chipertext  = case tryDecrypt pw chipertext of
  Ok plaintext -> createPrivateKey (split "," plaintext)
  Err _ -> createPrivateKey ["7","7","7","7"]

createPrivateKey : List String -> PrivateKey
createPrivateKey str = 
  let
    valueList = filterMap String.toInt str

    p = case List.head valueList of
      Just x -> x
      Nothing -> 0

    q = case List.head (List.drop 1 valueList) of
      Just x -> x
      Nothing -> 0

    phi = case List.head (List.drop 1 valueList) of
      Just x -> x
      Nothing -> 0

    d = case List.head (List.drop 1 valueList) of
      Just x -> x
      Nothing -> 0
  in
    PrivateKey p q phi d

cryptMessageAes : Model -> Message -> Message
cryptMessageAes model plainMessage = 
  let
    id = doEncrypt model.time plainMessage.id model.passphrase
    key = decryptMessageKey model plainMessage.key
    sender_id = doEncrypt model.time plainMessage.sender_id model.passphrase
    receiver_id = doEncrypt model.time plainMessage.receiver_id model.passphrase
    text = doEncrypt model.time plainMessage.text model.passphrase
    send_at = doEncrypt model.time  plainMessage.sent_at model.passphrase
    receive_at = case plainMessage.received_at of
      Just x -> Just (doEncrypt model.time x model.passphrase)
      Nothing -> Nothing
    read_at = case plainMessage.read_at of
      Just x -> Just (doEncrypt  model.time x model.passphrase)
      Nothing -> Nothing
  in
  Message id key sender_id receiver_id text send_at receive_at read_at

decryptMessageAes : Model -> Message -> Message
decryptMessageAes model cryptMessage = 
  let
    id = cryptMessage.id
    key = decryptMessageKey model cryptMessage.key
    sender_id = cryptMessage.sender_id
    receiver_id = cryptMessage.receiver_id
    text = doDecrypt key cryptMessage.text
    send_at = cryptMessage.sent_at
    receive_at = cryptMessage.received_at 
    read_at =  cryptMessage.read_at 
  in
  Message id key sender_id receiver_id text send_at receive_at read_at

decryptChatPreviewAes : Model -> ChatPreview -> ChatPreview
decryptChatPreviewAes model chatPreview = 
  let
    id = chatPreview.latest_message.id
    key = decryptMessageKey model chatPreview.latest_message.key
    sender_id = chatPreview.latest_message.sender_id
    receiver_id = chatPreview.latest_message.receiver_id
    text = doDecrypt model.passphrase chatPreview.latest_message.text
    send_at = chatPreview.latest_message.sent_at
    receive_at = chatPreview.latest_message.received_at 
    read_at =  chatPreview.latest_message.read_at 
  
    encryptedMessage = Message id key sender_id receiver_id text send_at receive_at read_at
  in
    ChatPreview chatPreview.user encryptedMessage chatPreview.total_message_count chatPreview.unread_message_count
