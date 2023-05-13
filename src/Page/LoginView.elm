module Page.LoginView exposing (..)
import Browser
import Html exposing (Html, button, div, text, h1, p)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Types exposing (..)
import Html.Events exposing (onInput)

loginView : LoginInfo -> Html Msg
loginView l = 
    div [class "login-wrapper"] [
      div [class "login-content"] [
      h1 [] [text "Login"],
      input [class "login-input", type_ "text", value l.username, placeholder "Username", onInput SetUsername] [],
      input [class "login-input", type_ "password", value l.password, placeholder "Password", onInput SetPassword] [],
      p [] [text "Error message"]
      ],
      button [class "primary-button login", onClick Submit] [text "Login"]
    ]
  
