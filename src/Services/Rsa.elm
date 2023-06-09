module Services.Rsa exposing (..)

import Random exposing (..)
import Types exposing (..)
import Services.ParserCrypt exposing (passphraseToInt)
import Parser exposing (run)
import List
import Arithmetic exposing (isPrime, isCoprimeTo, primesBelow, powerMod, modularInverse)
import Parser

type alias P = Prime
type alias Q = Prime

-- Define a generator for two prime numbers
-- the two primes need to be different
primeGenerator : Random.Generator (Prime, Prime)
primeGenerator = Random.pair (Random.int 50 500) (Random.int 50 500) |> Random.andThen (\n -> if isPrime (Tuple.first n) && isPrime (Tuple.second n) &&  (Tuple.first n) /= (Tuple.second n) then Random.constant n else primeGenerator)

-- Define a generator for a list of 20 prime numbers as string
primeListGenerator : Random.Generator (List Int)
primeListGenerator = Random.list 1 (Random.int 1 100)

generatePrimes : Cmd Msg
generatePrimes = Random.generate PrimePQ primeGenerator

-- Generate a passphrase with 20 prime numbers
generatePassphrase : Cmd Msg
generatePassphrase = Random.generate Passphrase (primeListGenerator)

-- calculate n for the public key
calculateN : Prime -> Prime -> Int
calculateN p q = p * q

-- Calculate phi for the private key
calculatePhi : Prime -> Prime -> Int
calculatePhi p q = (p - 1) * (q - 1)

-- Calculate a d that is an element from Z* phi and is multiplicative inverse of (e modulo phi)
-- The "17" is a random number, that is used to pick the 17th prime number from the list of primes below n
-- There a always more than 17 prime numbers below n, so this should work
calculateD : Int -> Int
calculateD n = case primesBelow n |> List.filter (\x -> isCoprimeTo x n) |> List.reverse  |> List.drop 17 |> List.head of
    Just x -> x
    Nothing -> 0

-- calculate ´e´ that is an element from Z* phi and is multiplicative inverse of (d modulo phi)
-- this is part of the public key
calculateE : Int -> Int -> Int
calculateE d phi = case modularInverse d phi of
    Just x -> x
    Nothing -> 0

-- produce a public key from a private key
calculatePublicKey : PrivateKey -> Prime -> Prime -> PublicKey
calculatePublicKey sk p q  = 
    let
        n = calculateN p q
        e = calculateE sk.d sk.phi
    in
    PublicKey e n

-- calculate a private key
calculatePrivateKey : Prime -> Prime -> PrivateKey
calculatePrivateKey p q = 
    let
        n = p * q
        phi = calculatePhi p q
        d = calculateD n
    in
    PrivateKey p q phi d

-- decrypt the message_key that is encrypted with the private key of the user
decryptWithRsaModus : Int -> PrivateKey -> PublicKey -> Int
decryptWithRsaModus y sk pk =
    let
        d = sk.d
        n = pk.n
    in
    powerMod y d n
    
-- encrypt the message_key that is encrypted with the public key of the active chat partner
-- so only the active chat partner can decrypt the message_key and decrypt the message
encryptWithRsaModus : Int -> PublicKey -> Int
encryptWithRsaModus x pk =
    let
        e = pk.e
        n = pk.n
    in
    powerMod x e n

-- encrypt a message_key with the public_key from the active chat partner
-- so it can be sent to the active chat partner withing the message
encryptMessageKey : Model -> String
encryptMessageKey model = 
    let
        messageKey = model.messageKey
        publicKeyActiveChatPartner = model.activeChatPartner.public_key
        encryptedMessageKey = String.fromInt (encryptWithRsaModus (passphraseToInt (String.replace "," "" messageKey)) publicKeyActiveChatPartner)
    in
     encryptedMessageKey

decryptMessageKey : Model -> String -> String
decryptMessageKey model encryptedMessageKey = 
    let
        privateKey = model.privateKey
        publicKey = model.user.public_key
        decryptedMessageKey = String.fromInt (decryptWithRsaModus (case run Parser.int encryptedMessageKey of
            Ok x -> x
            Err _ -> 0) privateKey publicKey)
    in
    decryptedMessageKey
