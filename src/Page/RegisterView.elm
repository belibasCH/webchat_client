module Page.RegisterView exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)

registerView :  Html Msg
registerView = 
      div [class "login-wrapper"] [
      div [class "login-content"] [
      h1 [] [text "Register"],
      p [] [text "Welcome at SaveChat! Please register to continue."],
      input [class "login-input",  type_ "text", placeholder "Username", onInput SetUsername] [],
      input [class "login-input", type_ "password", placeholder "Password", onInput SetPassword] [],
      input [class "login-input", type_ "password", placeholder "Confirm password", onInput SetPassword] []
      ],
      button [class "primary-button login", onClick SubmitRegistration] [text "Create account"]
    ]
  

