module Services.Rsa exposing (..)

import Arithmetic exposing (isPrime)
import Random exposing (..)
import Types exposing (..)
import Arithmetic exposing (gcd)
import Arithmetic exposing (modularInverse)
import Services.ParserCrypt exposing (messageToString)
import Services.ParserCrypt exposing (passphraseToInt)
import Parser exposing (run)
import Parser exposing (int)
import List exposing (concat)
import Arithmetic exposing (extendedGcd)
import Tuple.Trio exposing (first)
import Arithmetic exposing (isCoprimeTo)
import Arithmetic exposing (primesBelow)
import Parser exposing (number)
import Arithmetic exposing (totient)
import Arithmetic exposing (powerMod)

type alias P = Prime
type alias Q = Prime


-- Define a function to check if a number is prime
isPrime : Int -> Bool
isPrime n = 
    let
        helper d =
            d * d > n || modBy d n /= 0 && helper (d + 1)
    in
    n > 1 && helper 2

-- Define a generator for two prime numbers
primeGenerator : Random.Generator (Prime, Prime)
primeGenerator = Random.pair (Random.int 50 5000) (Random.int 60 4000) |> Random.andThen (\n -> if isPrime (Tuple.first n) && isPrime (Tuple.second n) &&  (Tuple.first n) /= (Tuple.second n) then Random.constant n else primeGenerator)

-- Define a generator for a list of 20 prime numbers as string
primeListGenerator : Random.Generator (List Int)
primeListGenerator = Random.list 1 (Random.int 1 100)

generatePrimes : Cmd Msg
generatePrimes = Random.generate PrimePQ primeGenerator

-- Generate a passphrase with 20 prime numbers
generatePassphrase : Cmd Msg
generatePassphrase = Random.generate Passphrase (primeListGenerator)

calculateN : Prime -> Prime -> Int
calculateN p q = p * q

calculatePhi : Prime -> Prime -> Int
calculatePhi p q = (p - 1) * (q - 1)

-- Calculate a d that is an element from Z* phi and is multiplicative inverse of (e modulo phi)
calculateD : Int -> Int
calculateD n = case primesBelow n |> List.filter (\x -> isCoprimeTo x n) |> List.reverse  |> List.drop 17 |> List.head of
    Just x -> x
    Nothing -> 0
  --  let
        --helper d =
    --        if isCoprimeTo d n then d else helper (d - 1) -- statt 7 kommt d rein
--in
    -- if n < 12 then (helper (round (toFloat n - 1))) else (helper (round (toFloat n / 2)))
    --helper (round (toFloat n - 1))


-- calculate ´e´ that is an element from Z* phi and is multiplicative inverse of (d modulo phi)
-- TODO Ich bekomme e nicht berechnet, da ein zufälliges d gewählt wird und es dafür keine inverse gibt!!!

calculateE : Int -> Int -> Int  
--calculateE d phi = first (extendedGcd d phi)
calculateE d phi = case modularInverse d phi of
    Just x -> x
    Nothing -> 0

-- calculate a public key
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

-- decrypt a message
decrypt : Int -> PrivateKey -> PublicKey -> Int
decrypt y sk pk = 
    let
        d = sk.d
        n = pk.n
    in
    powerMod y d n
    
-- encrypt an int with rsa

encryptFunc : Int -> PublicKey -> Int
encryptFunc x pk = 
    let
        e = pk.e
        n = pk.n
    in
    powerMod x e n

-- encrypt a message_key for send with a Message
encryptMessageKey : Model -> String
encryptMessageKey model = 
    let
        messageKey = model.passphrase
        publicKeyActiveChatPartner = model.activeChatPartner.public_key
        encryptedMessageKey = String.fromInt (encryptFunc (passphraseToInt (String.replace "," "" messageKey)) publicKeyActiveChatPartner)

    in
     encryptedMessageKey

decryptMessageKey : Model -> String -> String
decryptMessageKey model encryptedMessageKey = 
    let
        privateKey = model.privateKey
        publicKey = model.user.public_key
        decryptedMessageKey = String.fromInt (decrypt (case run Parser.int encryptedMessageKey of
            Ok x -> x
            Err _ -> 0) privateKey publicKey)
    in
        decryptedMessageKey

test : String
test = String.fromInt (decrypt (case (run Parser.int "4") of
            Ok x -> x
            Err _ -> 0) (PrivateKey 7 3 7 7) (PublicKey 6 7))