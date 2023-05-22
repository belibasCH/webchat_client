module Services.Rsa exposing (..)

import Arithmetic exposing (isPrime)
import Random exposing (..)
import Types exposing (..)

type alias P = Prime
type alias Q = Prime
-- p & q bestimmen





-- Define a function to check if a number is prime
isPrime : Int -> Bool
isPrime n = 
    let
        helper d =
            d * d > n || modBy d n /= 0 && helper (d + 1)
    in
    n > 1 && helper 2

-- Define a generator for two prime numbers
primeGenerator : Random.Generator Int
primeGenerator = Random.int 10000000 1000000000000000 |> Random.andThen (\n -> if isPrime n then Random.constant n else primeGenerator)

-- -- Generate a list of two random prime numbers
-- twoPrimes : List Prime
-- twoPrimes =
--    twoPrimesGenerator |> step Random.initialSeed |> head |> Maybe.withDefault []

generatePrimes : Cmd Msg
generatePrimes = Random.generate PrimePQ (Random.pair primeGenerator primeGenerator)

