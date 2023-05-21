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
    img [src "data:image/jpeg;base64,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", class "avatar"] [],
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