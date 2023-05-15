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
  div [class "change-profile-box"] [
    img [src "https://images.pexels.com/photos/220453/pexels-photo-220453.jpeg?cs=srgb&dl=pexels-pixabay-220453.jpg&fm=jpg", class "profile-avatar"] [],
    div [class "profile-details"][
    h1 [] [text "Profile"],
    p [] [text ("Id: "++user.id)],
    div [class "changeProfilebox"] [
    div [class "input-group"] [
      label [] [text "Name"],
      input [class "form-control", type_ "text", value user.name, onInput ChangeUserName] []
    ],
    button [class "new", onClick SendNewPW] [text "save"]
    ],
    div [class "change-profile-box"] [
    div [class "input-group"] [
      label [] [text "Set new password"],
      input [class "form-control", type_ "text", placeholder "***", onInput ChangePassword] []
    ],
    button [class "new", onClick SendNewPW] [text "save"]
    ]
    ]
     
  ]
  
