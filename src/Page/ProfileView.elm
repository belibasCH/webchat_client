module Page.ProfileView exposing (..)
import Browser
import Html exposing (Html, button, div, text, li, h2, a, h1 , h3, ul,p,nav,textarea, img, label)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)
import Html exposing (textarea)
import Html.Events exposing (targetValue)
import Maybe exposing (withDefault)
import Types exposing (..)

profileView : User -> Html Msg
profileView user = 
  div [class "profile-container"] [
    h1 [] [text "Profile"],
    div [class "input-group"] [
      label [] [text "Name"],
      input [class "form-control", type_ "text", value user.name, onInput ChangeUserName] []
    ],
    div [class "input-group"] [
      label [] [text "Set new password"],
      input [class "form-control", type_ "text", placeholder "***", onInput ChangePassword] []
    ],
    div [class "input-group"] [
        label [] [text "Confirm new password"],
        input [class "form-control", type_ "text",  onInput ChangeUserName] []
     ],
     p [] [text user.id]
  ]
