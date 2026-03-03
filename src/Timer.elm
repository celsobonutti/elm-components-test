component module Timer where { msg = Msg, props = Props } exposing (timer)

import Browser.Component exposing (ComponentMsg(..), emit)
import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)


type alias Props parentMsg =
    { label : String
    , onTick : Int -> parentMsg
    }


type Msg
    = Tick Int
    | StartClicked
    | StopClicked


type alias Model =
    { tickCount : Int
    , running : Bool
    }


init : Props parentMsg -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
init _ =
    ( { tickCount = 0, running = False }, Cmd.none )


update : Msg -> Props parentMsg -> Model -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
update msg props model =
    case msg of
        Tick n ->
            ( { model | tickCount = n }
            , emit (props.onTick n)
            )

        StartClicked ->
            ( { model | running = True }
            , startTimer 1000
            )

        StopClicked ->
            ( { model | running = False }
            , stopTimer
            )


view : Props parentMsg -> Model -> Html (ComponentMsg Msg parentMsg)
view props model =
    div []
        [ text (props.label ++ ": " ++ String.fromInt model.tickCount ++ " ticks")
        , if model.running then
            button [ onClick (Internal StopClicked) ] [ text "Stop" ]

          else
            button [ onClick (Internal StartClicked) ] [ text "Start" ]
        ]


subscriptions : Props parentMsg -> Model -> Sub (ComponentMsg Msg parentMsg)
subscriptions _ _ =
    onTick Tick


onPropsChange : Props parentMsg -> Props parentMsg -> Model -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
onPropsChange _ _ model =
    ( model, Cmd.none )


-- Component command: starts the timer with given interval in ms
startTimer : Int -> Cmd (ComponentMsg Msg parentMsg)


-- Component command: stops the timer
stopTimer : Cmd (ComponentMsg Msg parentMsg)


-- Component subscription: receives tick count from JS
onTick : (Int -> Msg) -> Sub (ComponentMsg Msg parentMsg)
