module Main exposing (main)

import Browser
import Dict exposing (Dict)
import Flags exposing (Flags)
import Html
import Json.Decode as Decode
import Ports


main : Program Decode.Value Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias Model =
    { flags : Flags
    }


type Msg
    = OnReceiveFromPort Decode.Value


type IncomingMessage
    = AppInit String
    | UnknownMessage


init : Decode.Value -> ( Model, Cmd Msg )
init json =
    let
        flags =
            Flags.decode json
    in
    ( { flags = flags }
    , Ports.send "elm.init" Nothing
    )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Ports.toElm OnReceiveFromPort


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnReceiveFromPort json ->
            let
                _ =
                    case
                        Ports.receive json
                            (\event ->
                                case event of
                                    "app.init" ->
                                        Decode.map AppInit Decode.string

                                    _ ->
                                        Decode.succeed UnknownMessage
                            )
                    of
                        Ok val ->
                            Debug.log "Ok" (Debug.toString val)

                        Err err ->
                            Debug.log "Error" (Decode.errorToString err)
            in
            ( model, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    { title = model.flags.appName ++ " - " ++ "Home"
    , body = [ Html.text "hello" ]
    }
