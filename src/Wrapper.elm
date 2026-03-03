component module Wrapper where { msg = Msg, props = Props } exposing (wrapper)

import Browser.Component exposing (ComponentMsg(..), emit)
import Counter
import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)


type alias Props parentMsg =
    { label : String
    , onReset : parentMsg
    , onInnerIncrement : parentMsg
    }


type Msg
    = IncrementInner
    | ToggleVisible


type alias Model =
    { innerCount : Int
    , visible : Bool
    }


init : Props parentMsg -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
init _ =
    ( { innerCount = 0, visible = True }, Cmd.none )


update : Msg -> Props parentMsg -> Model -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
update msg props model =
    case msg of
        IncrementInner ->
            ( { model | innerCount = model.innerCount + 1 }
            , emit props.onInnerIncrement
            )

        ToggleVisible ->
            ( { model | visible = not model.visible }, Cmd.none )


view : Props parentMsg -> Model -> Html (ComponentMsg Msg parentMsg)
view props model =
    div []
        [ text ("Wrapper: " ++ props.label)
        , button [ onClick (Internal ToggleVisible) ] [ text "toggle counter" ]
        , button [ onClick (Emit props.onReset) ] [ text "reset (parent)" ]
        , if model.visible then
            Counter.counter
                { value = model.innerCount
                , onIncrement = Internal IncrementInner
                }

          else
            text "(hidden)"
        ]


subscriptions : Props parentMsg -> Model -> Sub (ComponentMsg Msg parentMsg)
subscriptions _ _ =
    Sub.none


onPropsChange : Props parentMsg -> Props parentMsg -> Model -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
onPropsChange _ _ model =
    ( model, Cmd.none )
