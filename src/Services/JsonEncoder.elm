module Services.JsonEncoder exposing (..)
import Json.Encode as E
import Types exposing (..)

encodeRegisterUser : User -> E.Value
encodeRegisterUser u =
  E.object
    [ ("type", E.string "create_user")
    , ("username", E.string u.name)
    , ("password", E.string u.password)
    ]

encodeLogin : User -> E.Value
encodeLogin u =
  E.object
    [ ("type", E.string "login")
    , ("username", E.string u.name)
    , ("password", E.string u.password)
    ]

encodeLoadChats : E.Value
encodeLoadChats =
  E.object
    [ ("type", E.string "load_chats")
    ]