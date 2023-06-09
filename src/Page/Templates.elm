module Page.Templates exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import Types exposing (..)


withLoginContainer : Model -> Html Msg  -> Html Msg
withLoginContainer model content = 
  div [] [
    div [class "login-container"] [
      nav [class "login-nav"] [
        ul [class "login-nav-list"] [
          li 
            [classList [
              ("login-nav-item", True),
              ("left", True),
              ("active", model.page == LoginPage)
              ],
            onClick (SetPage LoginPage)] [a [class "login-nav-item"] [text "Login"]],
          li 
            [classList [
              ("login-nav-item", True),
              ("right", True),
              ("active", model.page == RegisterPage)
              ],
              onClick (SetPage RegisterPage )] [a [class "login-nav-item"] [text "Register"]] 
          ]
         ],
    content
    ],
    div [id "bubble1"] [],
    div [ class "server-message "] [text model.receivedMessageFromServer.msgType],
    withErrorMessage model.errorMessage
  ]

withContainer : Model -> Html Msg  -> Html Msg
withContainer model content = 
 div [ class "container"] [
  navigation model.page,
  content,
  secureSign,
  div [ class "server-message "] [text model.receivedMessageFromServer.msgType],
  withErrorMessage model.errorMessage
 ]

withErrorMessage : String -> Html Msg
withErrorMessage s = case s of 
  "" -> div [] []
  _ -> div [class "error-message"][
        div [class "error-border"] [],
        div [class "error-icon"] [],
        div [class "error-text"] [
          h2 [] [text "Error"],
          p [] [text s]]
      ]

navigation : Page -> Html Msg
navigation page = nav [class "sidebar"][
      ul [][
        li [ classList [
          ("active", page == ProfilePage)
          ],
          onClick (SetPage ProfilePage)
        ][div [class "user-icon"] []],
        li [classList [
          ("active", page == ChatPage)
           ],
          onClick (SetPage ChatPage)
          ][div [class "chats-icon"] []],
        li [classList [
          ("active", page == NewChatPage)
           ],
          onClick (SetPage NewChatPage)
          ][div [class "new-icon"] []]
      ]
    ]

secureSign : Html Msg
secureSign = div [class "secure", title "This chat is End-to-End Encrypted"] [div [class "secure-icon"] []]

