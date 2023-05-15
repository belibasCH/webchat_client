module Page.NewChatView exposing (..)
import Browser
import Html exposing (Html, button, div, text, li, h2, a, h1 , h3, ul,p,nav,textarea, img)
import Html.Events exposing (onClick)
import Html.Attributes exposing (class)
import Html.Attributes exposing (..)
import Html exposing (input, Attribute)
import Html.Events exposing (onInput)
import Html exposing (textarea)
import Html.Events exposing (targetValue)
import Maybe exposing (withDefault)
import Types exposing (..)

newChatView : List UserPreview -> Html Msg
newChatView data = 
  div [] (List.map userView data)

userView : UserPreview -> Html Msg
userView user = 
  div [] [
    div [] [text user.user.name],
    div [] [text (if user.is_online then "online" else "offline")],
    button [onClick (StartChat user.user.id)] [text "start chat"]
  ]