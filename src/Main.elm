module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Decode exposing (Decoder, andThen, at, field, list, map, map3, string, succeed)
import List
import Maybe
import String



-- MAIN


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias BasePokemon =
    { name : String, url : String, uuid : String }


type alias AllBasePokemon =
    List BasePokemon


type Model
    = Failure
    | Loading
    | Success AllBasePokemon


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading, getAllPokemon )



-- UPDATE


type Msg
    = GotAllPokemon (Result Http.Error AllBasePokemon)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotAllPokemon result ->
            case result of
                Ok allPokemon ->
                    ( Success allPokemon, Cmd.none )

                Err _ ->
                    ( Failure, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


pokemonSpriteUrl : String -> String
pokemonSpriteUrl pokemonUuid =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" ++ pokemonUuid ++ ".png"


viewBasePokemon : BasePokemon -> Html Msg
viewBasePokemon basePokemon =
    div []
        [ text basePokemon.name, img [ src (pokemonSpriteUrl basePokemon.uuid) ] [] ]


viewAllBasePokemon : Model -> Html Msg
viewAllBasePokemon model =
    case model of
        Failure ->
            text "I could not any Pokemon for some reason. "

        Loading ->
            text "Loading Pokemon..."

        Success allPokemon ->
            div []
                (List.map viewBasePokemon allPokemon)


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text "Pokemon" ]
        , viewAllBasePokemon model
        ]



-- HTTP


getAllPokemon : Cmd Msg
getAllPokemon =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon?limit=10000"
        , expect = Http.expectJson GotAllPokemon allPokemonDecoder
        }


getUuid : String -> String
getUuid url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "1"


pokemonDecoder : Decoder BasePokemon
pokemonDecoder =
    map3 BasePokemon
        (field "name" string)
        (field "url" string)
        (field "url" (string |> map getUuid))


allPokemonDecoder : Decoder AllBasePokemon
allPokemonDecoder =
    at [ "results" ] (list pokemonDecoder)
