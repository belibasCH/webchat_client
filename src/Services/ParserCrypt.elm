module Services.ParserCrypt exposing (..)

import List exposing (filterMap)
import Types exposing (Message)
import String exposing (split)
import Types exposing (PrivateKey)
import Debug exposing (toString)
import Types exposing (PublicKey)
import Parser exposing (..)
import Types exposing (..)


-- TODO "" sollte nach dem decoden erneut ein MAybe erzeugen oder nicht?"" 
-- convert Message to String with seperator
messageToString : Message -> String
messageToString m = 
  let
    id = m.id
    key = m.key
    sender_id = m.sender_id
    receiver_id = m.receiver_id
    text = m.text
    send_at = m.sent_at
    receive_at = case m.received_at of
      Just x -> x
      Nothing -> ""
    read_at = case m.read_at of
      Just x -> x
      Nothing -> ""
  in
    id ++ "~" ++ key ++ "~" ++ sender_id ++ "~" ++ receiver_id ++ "~" ++ text ++ "~" ++ send_at ++ "~" ++ receive_at ++ "~" ++ read_at

decodeStringMessage : String -> Message
decodeStringMessage s = 
  let
    splitted = split "~" s
    id = maybeToString (List.head splitted)
    key = maybeToString (List.head (List.drop 1 splitted))
    sender_id = maybeToString (List.head (List.drop 1 splitted))
    receiver_id = maybeToString (List.head (List.drop 2 splitted))
    text = maybeToString (List.head (List.drop 3 splitted))
    send_at = maybeToString (List.head (List.drop 4 splitted))
    receive_at = (List.head (List.drop 5 splitted))
    read_at = List.head (List.drop 6 splitted)
  in
    Message id key sender_id receiver_id text send_at receive_at read_at


-- convert a Maybe to a String
maybeToString : Maybe String -> String
maybeToString m = case m of
  Just x -> x
  Nothing -> "not read"

-- convert a String, that is taken from the Server, to a PrivateKey
-- on the Server the PrivateKey is encrypted with AES as a single String
convertStringToPrivateKey : List String -> PrivateKey
convertStringToPrivateKey str =
  let
    valueList = filterMap String.toInt str
    p = case List.head valueList of
      Just x -> x
      Nothing -> 0
    q = case List.head (List.drop 1 valueList) of
      Just x -> x
      Nothing -> 0
    phi = case List.head (List.drop 2 valueList) of
      Just x -> x
      Nothing -> 0
    d = case List.head (List.drop 3 valueList) of
      Just x -> x
      Nothing -> 0
  in
    PrivateKey p q phi d

-- convert the PrivateKey to a String for encrypt it and store it on the server as a single String
convertPrivateKeyToString : PrivateKey -> String
convertPrivateKeyToString sk =
  let
    p = toString sk.p
    q = toString sk.q
    phi = toString sk.phi
    d = toString sk.d
  in
    p ++ "," ++ q ++ "," ++phi ++ "," ++ d

--publicKey to String
publicKeyToString : PublicKey -> String
publicKeyToString pk = 
  let
    n = toString pk.n
    e = toString pk.e
  in
    e ++ "," ++ n

-- convert a String to a PublicKey
stringToPublicKey : String -> PublicKey
stringToPublicKey s = 
  let
    splitted = split "," s
    e = case run int (maybeToString (List.head splitted)) of
      Ok x -> x
      Err _ -> 0
    n = case run int (maybeToString (List.head (List.drop 1 splitted))) of
      Ok x -> x
      Err _ -> 0
  in
    PublicKey e n

-- convert String to PrivateKey
stringToPrivateKey : String -> PrivateKey
stringToPrivateKey s = 
  let
    splitted = split "," s
    p = case run int (maybeToString (List.head splitted)) of
      Ok x -> x
      Err _ -> 0
    q = case run int (maybeToString (List.head (List.drop 1 splitted))) of
      Ok x -> x
      Err _ -> 0
    phi = case run int (maybeToString (List.head (List.drop 1 splitted))) of
      Ok x -> x
      Err _ -> 0
    d = case run int (maybeToString (List.head (List.drop 2 splitted))) of
      Ok x -> x
      Err _ -> 0
  in
    PrivateKey p q phi d

-- convert a List of Int to a String
listToString : List Int -> String
listToString l = 
  let
    list = List.map toString l
  in
    String.join "," list

-- convert a Passphrase to a Int
passphraseToInt : Message_Key -> Int
passphraseToInt p = case run int p of
  Ok x -> x
  Err _ -> 0
