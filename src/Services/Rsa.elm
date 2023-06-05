module Services.Rsa exposing (..)

import Arithmetic exposing (isPrime)
import Random exposing (..)
import Types exposing (..)
import Arithmetic exposing (gcd)
import Arithmetic exposing (modularInverse)

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
primeListGenerator = Random.list 20 (int 1 50000)

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
decrypt : Int -> KeyPair -> Int
decrypt y keyPair = 
    let
        d = keyPair.privateKey.d
        n = keyPair.publicKey.n
    in
    modBy (y ^ d) n
    
-- encrypt a message
encryptFunc : Int -> KeyPair -> Int
encryptFunc x keyPair = 
    let
        e = keyPair.publicKey.e
        n = keyPair.publicKey.n
    in
    modBy (x ^ e) n
