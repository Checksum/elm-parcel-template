port module Ports exposing (ReceiveMessage(..), SendMessage(..), decode, encode, receive, send, toElm)

import Json.Decode as Decode
import Json.Encode as Encode



-- Incoming port


port toElm : (Decode.Value -> msg) -> Sub msg


type ReceiveMessage a
    = ReceiveMessage (Message a)



-- Outgoing port


port fromElm : Encode.Value -> Cmd msg


type SendMessage
    = SendMessage (Message Encode.Value)



-- Message


type alias Message a =
    { event : String
    , data : Maybe a
    }


encode : SendMessage -> Encode.Value
encode (SendMessage { event, data }) =
    Encode.object
        [ ( "event", Encode.string event )
        , ( "data", Maybe.withDefault Encode.null data )
        ]


send : String -> Maybe Encode.Value -> Cmd msg
send event data =
    let
        message =
            encode (SendMessage { event = event, data = data })
    in
    fromElm message


dataDecoder : String -> (String -> Decode.Decoder a) -> Decode.Decoder (Maybe a)
dataDecoder event decoder =
    Decode.maybe (Decode.field "data" (decoder event))


messageDecoder : (String -> Decode.Decoder a) -> Decode.Decoder (Message a)
messageDecoder decoder =
    Decode.map2 Message
        (Decode.field "event" Decode.string)
        (Decode.field "event" Decode.string |> Decode.andThen (\event -> dataDecoder event decoder))


decode : (String -> Decode.Decoder a) -> Decode.Decoder (ReceiveMessage a)
decode decoder =
    Decode.map ReceiveMessage (messageDecoder decoder)


receive : Decode.Value -> (String -> Decode.Decoder a) -> Result Decode.Error (ReceiveMessage a)
receive json customDecoder =
    Decode.decodeValue (decode customDecoder) json
