module Page.RegisterView exposing (..)
import Browser
import Html exposing (Html, button, div, text, h1, p)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Types exposing (..)
import Html.Events exposing (onInput)

registerView : String -> Html Msg
registerView errorMessage= 
      div [class "login-wrapper"] [
      div [class "login-content"] [
      h1 [] [text "Register"],
      p [] [text "Welcome at SaveChat! Please register to continue."],
      input [class "login-input", type_ "text", placeholder "Username", onInput SetUsername] [],
      input [class "login-input", type_ "password", placeholder "Password", onInput SetPassword] [],
      input [class "login-input", type_ "password", placeholder "Confirm password", onInput SetPassword] [],
      input [class "login-input", type_ "text", placeholder "Avatar_url", onInput SetAvatar] []
      ],
      button [class "primary-button login", onClick SubmitRegistration] [text "Create account"]
    ]
  

