module Services.Rsa exposing (..)

import Arithmetic exposing (isPrime)
import Crypto.Strings.Types exposing (RandomGenerator)
import Random exposing (Generator, andThen, map, step, int, list)
import List exposing (filter, head)
import Browser

type alias Prime = Int
type alias P = Prime
type alias Q = Prime
-- p & q bestimmen

type alias Model = { primzahl1: Prime }

type Msg = NewNumber Int

-- Define a function to check if a number is prime
isPrime : Int -> Bool
isPrime n = 
    let
        helper d =
            d * d > n || modBy d n /= 0 && helper (d + 1)
    in
    n > 1 && helper 2

-- Define a generator for two prime numbers
primeGenerator : Generator Prime
primeGenerator =
    int 2 1000 |> andThen (\n -> if isPrime n then Random.constant n else primeGenerator)

-- Define a generator for a list of two prime numbers
twoPrimesGenerator : Generator (List Prime)
twoPrimesGenerator =
    list 2 primeGenerator |> map (filter isPrime)

-- -- Generate a list of two random prime numbers
-- twoPrimes : List Prime
-- twoPrimes =
--    twoPrimesGenerator |> step Random.initialSeed |> head |> Maybe.withDefault []

newNumber : Cmd Msg
newNumber =
  Random.generate NewNumber primeGenerator

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewNumber n ->
      ( { model | primzahl1 = n }, Cmd.none )

main : Program () Model Msg 
main = Browser.element
	{ init = \_ -> (initialModel, requestFortune) 
	, view = view 
	, update = update 
	, subscriptions = \_ -> Sub.none }

view : Model -> Html Msg 
view model = div []
	[ div [] [ text (Debug.toString model.fortune) ] 
	, button [ onClick GetFortune ] [ text "Next" ] 
	]