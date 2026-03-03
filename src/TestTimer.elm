module TestTimer exposing (main)

import Html exposing (Html)
import Timer

main : Html msg
main =
    Timer.timer { label = "test", onTick = \_ -> () }
