module Main exposing (main)

import Browser
import Html


type alias Flags =
    ()


type alias Model =
    ()


type alias Message =
    ()


main : Program Flags Model Message
main =
    Browser.sandbox
        { init = ()
        , view = \() -> Html.text "Bartleby"
        , update = \() () -> ()
        }
