module Page.ProfileView exposing (..)
import Browser
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)
import Html exposing (textarea)
import Html.Events exposing (targetValue)
import Maybe exposing (withDefault)
import Types exposing (..)
import Json.Decode as D
import File exposing (..)




profileView : User -> Html Msg
profileView user = 
  div [class "profile-container"] [
    h1 [] [text "Profile"],
    div [class "profile-avatar-box"] [
      img [src ((withDefault "" user.avatar)), class "profile-avatar"] [] ,
      label [class "file-upload"][
        input [class "form-control", type_ "file", on "change" (D.map GotFile filesDecoder) ] [],
        div [class "edit-icon"][]
      ]
    
    ],
 
     div [class "change-profile-box"] [
    div [class "input-group"] [
      label [] [text "Username"],
      input [class "form-control", type_ "text", value user.name, onInput SetUsername] []
    ],
    button [class "primary-button send", onClick ChangeUserName] [div [class "save-icon"][]]
    ],
    
    div [class "change-profile-box"] [
    div [class "input-group"] [
      label [] [text "Set new password"],
      input [class "form-control", type_ "text", placeholder "***", onInput SetPassword] []
    ],
    button [class "primary-button send", onClick ChangePassword] [div [class "save-icon"][]]
    ]
   
  ]

filesDecoder : D.Decoder File
filesDecoder =
  D.at ["target","files"] (D.index 0 File.decoder)
