module Flags exposing (Flags, decode)

import Json.Decode as Decode


type alias Flags =
    { appName : String
    , apiUrl : Maybe String
    }


flagsDecoder : Decode.Decoder Flags
flagsDecoder =
    Decode.map2 Flags
        (Decode.field "appName" Decode.string)
        (Decode.maybe (Decode.field "apiUrl" Decode.string))


decode : Decode.Value -> Flags
decode json =
    case Decode.decodeValue flagsDecoder json of
        Ok flags ->
            flags

        Err _ ->
            { appName = ""
            , apiUrl = Nothing
            }
