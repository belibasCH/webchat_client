module Page.LoginView exposing (..)
import Browser
import Html exposing (Html, button, div, text, h1, p, h2)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Types exposing (..)
import Html.Events exposing (onInput)

loginView : User -> Html Msg
loginView u  = 
    div [class "login-wrapper"] [
      div [class "login-content"] [
      h1 [] [text "Login"],
      input [class "login-input", type_ "text", value u.name, placeholder "Username", onInput SetUsername] [],
      input [class "login-input", type_ "password", placeholder "Password", onInput SetPassword] []
      ],
      button [class "primary-button login", onClick SubmitLogin] [text "Login"]
    
    ]
  
