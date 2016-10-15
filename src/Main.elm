module Main exposing (..)

import Html exposing (Html, button, div, h1, text)
import Html.App
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Json.Decode
import Json.Decode.Pipeline
import Markdown
import Task


-- MODEL


type alias Model =
    Joke


init : ( Model, Cmd Msg )
init =
    ( { joke = "" }, fetchJoke )



-- MESSAGES


type Msg
    = FetchAllDone Joke
    | FetchAllFail Http.Error
    | Submit



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "margin", "75px" )
            , ( "font-family", "Arial, 'Helvetica Neue', Helvetica, sans-serif" )
            ]
        ]
        [ h1 [] [ text "Reasons to not mess with Chuck Norris:" ]
        , div
            [ style
                [ ( "padding-bottom", "30px" )
                , ( "font-size", "26px" )
                ]
            ]
            [ Markdown.toHtml [] model.joke ]
        , div
            [ style
                [ ( "text-align", "right" ) ]
            ]
            [ button
                [ onClick Submit
                , style
                    [ ( "padding", "15px" )
                    , ( "border", "none" )
                    , ( "font", "inherit" )
                    , ( "line-height", "20px" )
                    , ( "background-color", "lightseagreen" )
                    ]
                ]
                [ text "Next Reason" ]
            ]
        ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FetchAllDone joke ->
            joke ! [ Cmd.none ]

        FetchAllFail error ->
            model ! []

        Submit ->
            model ! [ fetchJoke ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


fetchJoke : Cmd Msg
fetchJoke =
    Http.get decodeJoke "https://api.icndb.com/jokes/random"
        |> Task.perform FetchAllFail FetchAllDone


type alias JokeRawJson =
    { value : Joke
    }


type alias Joke =
    { joke : String
    }


decodeRawJoke : Json.Decode.Decoder JokeRawJson
decodeRawJoke =
    Json.Decode.Pipeline.decode JokeRawJson
        |> Json.Decode.Pipeline.required "value" (decodeJokeValue)


decodeJokeValue : Json.Decode.Decoder Joke
decodeJokeValue =
    Json.Decode.Pipeline.decode Joke
        |> Json.Decode.Pipeline.required "joke" (Json.Decode.string)


decodeJoke : Json.Decode.Decoder Joke
decodeJoke =
    Json.Decode.map mapToJoke decodeRawJoke


mapToJoke : JokeRawJson -> Joke
mapToJoke rawJoke =
    rawJoke.value
