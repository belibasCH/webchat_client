module Page.LoginView exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)

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
  
