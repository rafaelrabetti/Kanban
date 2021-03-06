module Pages.Kanban exposing (Model, init, main)

import Browser
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Utils exposing (..)
import Json.Decode as D
import Json.Encode as E


main =
    Browser.sandbox
        { init = example
        , view = view
        , update = update
        }



--------------------------------------------------------------------------------
-- MODEL
--------------------------------------------------------------------------------


type Status
    = Backlog
    | Todo
    | Doing
    | Done
    | Archived


type alias Model =
    { issues : List Issue
    , index : Int
    , input : String
    }


type alias Issue =
    { description : String
    , status : Status
    }


init : Model
init =
    { issues = [], index = 0, input = "" }


{-| Create simple flag element
-}
issue : String -> Issue
issue title =
    Issue title Todo


incr : Status -> Status
incr status =
    case status of
        Backlog ->
            Todo

        Todo ->
            Doing

        Doing ->
            Done

        Done ->
            Archived
        
        Archived ->
            Archived


decr : Status -> Status
decr status =
    case status of
        Backlog ->
            Backlog

        Todo ->
            Backlog

        Doing ->
            Todo

        Done ->
            Doing

        Archived ->
            Done

--------------------------------------------------------------------------------
-- MESSAGES
--------------------------------------------------------------------------------


type Msg
    = NoOp
    | Incr Int
    | Decr Int
    | Add
    | Input String


update : Msg -> Model -> Model
update msg m =
    case msg of
        Incr i ->
            { m
                | issues =
                    mapAt i
                        (\x -> { x | status = incr x.status })
                        m.issues
            }

        Decr i ->
            { m
                | issues =
                    mapAt i
                        (\x -> { x | status = decr x.status })
                        m.issues
            }

        Add ->
            { m
                | index = m.index + 1
                , issues = issue m.input :: m.issues
                , input = ""
            }

        Input st ->
            { m | input = st }

        _ ->
            m



--------------------------------------------------------------------------------
-- VIEW FUNCTIONS
--------------------------------------------------------------------------------


view : Model -> Html Msg
view m =
    let
        issueViews =
            List.indexedMap (\i x -> ( x.status, viewIssue i x )) m.issues

        board : Status -> Html Msg
        board s =
            viewList ul li <|
                List.map Tuple.second <|
                    List.filter (Tuple.first >> (==) s) issueViews
    in
    div []
        [ h1 [] [ text "Kanban board" ]
        , viewBoard "Backlog" (board Backlog)
        , viewBoard "To-do" (board Todo)
        , viewBoard "Doing" (board Doing)
        , viewBoard "Done" (board Done)
        , viewBoard "Archived" (board Archived)
        , Html.form [ onSubmit Add ]
            [ input [ placeholder "New issue", value m.input, onInput Input ] []
            , input [ type_ "submit" ] []
            ]
        ]


viewBoard : String -> Html Msg -> Html Msg
viewBoard title issues =
    div []
        [ h2 [] [ text title ]
        , issues
        ]


viewIssue : Int -> Issue -> Html Msg
viewIssue i obj =
    div []
        [ arrow "<= " Backlog (Decr i) obj.status
        , text obj.description
        , arrow " =>" Archived (Incr i) obj.status
        ]


arrow : String -> Status -> a -> Status -> Html a
arrow arr except msg status =
    let
        cmds =
            if status == except then
                [ class "fade" ]

            else
                [ onClick msg ]
    in
    span cmds [ text arr ]



--------------------------------------------------------------------------------
-- EXAMPLES
--------------------------------------------------------------------------------


example : Model
example =
    { init
        | issues =
            [ issue "Start board"
            , issue "Create CSS"
            , issue "Learn Haskell"
            ]
    }
