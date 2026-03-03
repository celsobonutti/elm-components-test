component module Counter where { msg = Msg, props = Props } exposing (counter)

import Browser.Component exposing (ComponentMsg(..), emit)
import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)


type alias Props parentMsg =
    { value : Int
    , onIncrement : parentMsg
    }


type Msg
    = LocalIncrement


type alias Model =
    { local : Int
    }


init : Props parentMsg -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
init _ =
    ( { local = 0 }, Cmd.none )


update : Msg -> Props parentMsg -> Model -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
update msg _ model =
    case msg of
        LocalIncrement ->
            ( { model | local = model.local + 1 }, Cmd.none )


view : Props parentMsg -> Model -> Html (ComponentMsg Msg parentMsg)
view props model =
    div []
        [ text ("Prop: " ++ String.fromInt props.value ++ ", Local: " ++ String.fromInt model.local)
        , button [ onClick (Internal LocalIncrement) ] [ text "+local" ]
        , button [ onClick (Emit props.onIncrement) ] [ text "+parent" ]
        ]


subscriptions : Props parentMsg -> Model -> Sub (ComponentMsg Msg parentMsg)
subscriptions _ _ =
    Sub.none


onPropsChange : Props parentMsg -> Props parentMsg -> Model -> ( Model, Cmd (ComponentMsg Msg parentMsg) )
onPropsChange _ _ model =
    ( model, Cmd.none )
