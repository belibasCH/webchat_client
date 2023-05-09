module Page.LoginView exposing (..)
import Browser
import Html exposing (Html, button, div, text, h1)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Types exposing (..)

loginView : LoginInfo -> Html Msg
loginView l = div [class "login-container"] [
    div [class "login-wrapper"] [
      h1 [] [text "Login"],
      input [class "login-input", placeholder "Username" ] [],
      input [class "login-input", placeholder "Password"] [],
      button [class "primary-button", onClick SendMessage] [text "Login"]
    ]
  ]