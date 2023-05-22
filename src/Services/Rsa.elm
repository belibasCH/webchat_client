module Services.Rsa exposing (..)

import Arithmetic exposing (isPrime)
import Crypto.Strings.Types exposing (RandomGenerator)
import Random exposing (Generator, andThen, map, step, int, list)
import List exposing (filter, head)

type alias Prime = Int
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

-- Define a generator for prime numbers
primeGenerator : Generator Int
primeGenerator =
    int 1 1000 |> andThen (\x -> if isPrime x then liftM x else primeGenerator)

-- Define a generator for a list of two prime numbers
twoPrimesGenerator : Generator (List Prime)
twoPrimesGenerator =
    list 2 primeGenerator |> map (filter isPrime)

-- Generate a list of two random prime numbers
twoPrimes : List Prime
twoPrimes =
    twoPrimesGenerator |> step Random.initialSeed |> head |> Maybe.withDefault []



