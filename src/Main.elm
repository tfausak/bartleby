module Main exposing (main)

import Bartleby.Type.FileData as FileData
import Bartleby.Type.Flags as Flags
import Bartleby.Type.Message as Message
import Bartleby.Type.Model as Model
import Bartleby.Update as Update
import Bartleby.View as View
import Browser
import Task


main : Program Flags.Flags Model.Model Message.Message
main =
    Browser.document
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }


init : Flags.Flags -> ( Model.Model, Cmd Message.Message )
init _ =
    ( { chunks = []
      , index = Nothing
      , job = FileData.NotAsked
      }
    , Task.perform identity (Task.succeed Message.Ignore)
    )


subscriptions : Model.Model -> Sub Message.Message
subscriptions _ =
    Sub.none
