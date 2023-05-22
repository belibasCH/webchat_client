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

newChatView : Model -> Html Msg
newChatView data = 
  div [class "new-chat-container"] [
    input [onInput Search, type_ "text", placeholder "Search", class "search"] [text "tse"],
  div [class "user-list"] (List.map (userView data) data.filteredUsers)
  ]


userView : Model -> UserPreview -> Html Msg
userView model user = 
  div [classList [("user-preview", True),("me", user.user.id == model.user.id)] ] [
   img [src (withDefault "" user.user.avatar), class "avatar"] [],
     div [class "user-col"] [
      div [class "user-label"] [text "Name"],
      div [class "user-content"] [text user.user.name]
    ],

    div [class "user-col"] [
      div [class "user-label"] [text "Id"],
      div [class "user-content"] [text user.user.id]
    ],
    div [class "user-col"] [
      div [class "user-label"] [text "Status"],

    div [classList[
      ( "user-content", True),
      ( "online", user.is_online),
      ( "offline", not user.is_online)
      ]] [text (if user.is_online then "online" else "offline")]],
    if user.user.id == model.user.id then
    button [onClick (SetPage ProfilePage), class "primary-button start-chat"] [div [class "user-icon"][]]
    else
    button [onClick (StartChat user), class "primary-button start-chat"] [div [class "start-icon"][]]

  ]