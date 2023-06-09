module Page.NewChatView exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)
import Maybe exposing (withDefault)

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