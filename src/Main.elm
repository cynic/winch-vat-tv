module Main exposing (main)

import Browser
import Html exposing (Html, div, img, text)
import Html.Attributes exposing (src, class, id)
import Json.Decode exposing (Decoder)
import Json.Decode as D
import Task
import Time
import Http
import Platform.Cmd as Cmd


-- MODEL


type alias Model =
    { pictures : List Picture, class : String }


type alias Picture =
    { picture : String, name : String, position : String, description : String }


initialModel : Model
initialModel =
    { pictures = [] , class = "" }


-- UPDATE


type Msg
    = NewPictures (List Picture)
    | Tick Time.Posix
    | Oops

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        NewPictures newPictures ->
            ( { model | pictures = newPictures }, Cmd.none )
        Tick tick ->
          case (model.pictures, (modBy 20 <| Time.toSecond Time.utc tick)) of
            ([], 19) ->
              ( model, fetchPictures )
            ([], _) ->
              ( model, Cmd.none )
            (h::t, 0) ->
              ( { model | pictures = t ++ [h], class = "fade-in" }, Cmd.none )
            (_, 19) ->
              ( { model | class = "fade-out" }, Cmd.none )
            (_, _) ->
              ( { model | class = "" }, Cmd.none )
            
        Oops ->
          ( model, fetchPictures )

-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Winchester House"
    , body =
        [ case model.pictures of
            [] ->
              text "Loading..."

            _ ->
              case List.head model.pictures of
                Nothing ->
                  text "Waiting for pictures…"
                Just pic ->
                  div
                    []
                    [ img [ src pic.picture, class model.class ] []
                    , div
                      [ id "name-and-position" ]
                      [ div [ id "name" ] [ text pic.name ]
                      , div [ id "position" ] [ text pic.position ]
                      ]
                    , div [ id "description" ] [ text pic.description ]
                    ]
        ]
    }


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Time.every 1000 Tick


-- HTTP


pictureDecoder : Decoder Picture
pictureDecoder =
  D.map4 Picture
    (D.field "picture" D.string)
    (D.field "name" D.string)
    (D.field "position" D.string)
    (D.field "description" D.string)

fetchPictures : Cmd Msg
fetchPictures =
    -- You need to implement an HTTP request that fetches the JSON data from your backend and then decodes it using `pictureDecoder`
    -- This is a placeholder for where that logic would go.
    Http.get
        { url = "http://localhost:5000/pictures"
        , expect = Http.expectJson (Result.map NewPictures >> Result.withDefault Oops) (D.list pictureDecoder)
        }

-- MAIN

main : Program () Model Msg
main =
    Browser.document
        { init = \_ -> ( initialModel, fetchPictures )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
