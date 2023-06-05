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
primeGenerator : Random.Generator Prime
primeGenerator = Random.int 1 50000 |> Random.andThen (\n -> if isPrime n then Random.constant n else primeGenerator)

-- Define a generator for a list of 20 prime numbers as string
primeListGenerator : Random.Generator (List Int)
primeListGenerator = Random.list 20 (Random.int 0 9)

generatePrimes : Cmd Msg
generatePrimes = Random.generate PrimePQ (Random.pair primeGenerator primeGenerator)

-- Generate a passphrase with 20 prime numbers
generatePassphrase : Cmd Msg
generatePassphrase = Random.generate Passphrase (primeListGenerator)

calculateN : Prime -> Prime -> Int
calculateN p q = p * q

calculatePhi : Prime -> Prime -> Int
calculatePhi p q = (p - 1) * (q - 1)

-- calculate d that is element of Z* phi(n) and ggt (d, phi(n)) = 1
calculateD : Int -> Int
calculateD phi = 
    let
        helper d =
            if gcd d phi == 1 then 7 else helper (d - 1) -- statt 7 kommt d rein
    in
    helper (round (toFloat phi / 2- 1))


-- calculate ´e´ that is an element from Z* phi and is multiplicative inverse of (d modulo phi)
-- TODO Ich bekomme e nicht berechnet, da ein zufälliges d gewählt wird und es dafür keine inverse gibt!!!

calculateE : Int -> Int -> Int  
calculateE d phi = 
    let
        helper e dP = case (modBy (e * dP) phi) of
            1 -> e
            _ -> if e > 10000 then -1 else helper (e + 1) d
    in
    helper 2 d

-- calculate a public key
calculatePublicKey : PrivateKey -> Prime -> Prime -> PublicKey
calculatePublicKey pk p q  = 
    let
        n = calculateN p q
        e = calculateE pk.d pk.phi
    in
    PublicKey e n

-- calculate a private key
calculatePrivateKey : Prime -> Prime -> PrivateKey
calculatePrivateKey p q = 
    let
        phi = calculatePhi p q
        d = calculateD phi
    in
    PrivateKey p q phi d

-- decrypt a message
decrypt : Int -> PrivateKey -> PublicKey -> Int
decrypt y sk pk = 
    let
        d = sk.d
        n = pk.n
    in
    modBy (y ^ d) n
    
-- encrypt a message
encryptFunc : Int -> PublicKey -> Int
encryptFunc p pk = 
    let
        e = pk.e
        n = pk.n
    in
    modBy (p ^ e) n

-- encrypt a message_key for send with a Message
encryptMessageKey : Model -> String
encryptMessageKey model = 
    let
        messageKey = model.passphrase
        publicKeyActiveChatPartner = model.activeChatPartner.public_key
        encryptedMessageKey = String.fromInt (encryptFunc (passphraseToInt messageKey) publicKeyActiveChatPartner)

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
