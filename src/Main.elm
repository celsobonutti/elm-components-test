module Main exposing (main)

import Browser
import Counter
import Html exposing (Html, div, h1, h2, hr, p, text)
import Timer
import Wrapper


type alias Model =
    { parentCount : Int
    , timerTicks : Int
    , resetCount : Int
    }


type Msg
    = Ticked Int
    | Increment
    | WrapperInnerIncrement
    | ResetFromWrapper


main : Program () Model Msg
main =
    Browser.sandbox
        { init =
            { parentCount = 0
            , timerTicks = 0
            , resetCount = 0
            }
        , update = update
        , view = view
        }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Ticked n ->
            { model | timerTicks = n }

        Increment ->
            { model | parentCount = model.parentCount + 1 }

        WrapperInnerIncrement ->
            { model | parentCount = model.parentCount + 1 }

        ResetFromWrapper ->
            { model | resetCount = model.resetCount + 1 }


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Elm Components Demo" ]
        , p []
            [ text
                ("Parent count: "
                    ++ String.fromInt model.parentCount
                    ++ " | Timer ticks: "
                    ++ String.fromInt model.timerTicks
                    ++ " | Resets: "
                    ++ String.fromInt model.resetCount
                )
            ]
        , hr [] []
        , h2 [] [ text "Timer (JS effects)" ]
        , Timer.timer { label = "Timer", onTick = Ticked }
        , hr [] []
        , h2 [] [ text "Counter (local + parent state)" ]
        , Counter.counter { value = model.parentCount, onIncrement = Increment }
        , hr [] []
        , h2 [] [ text "Wrapper (nested component)" ]
        , Wrapper.wrapper { label = "Wrapper", onReset = ResetFromWrapper, onInnerIncrement = WrapperInnerIncrement }
        ]
