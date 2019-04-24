module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Css exposing (..)
import Css.Transitions exposing (easeInOut, transition)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (css, href, src)
import Http
import Json.Decode as Decode exposing (Decoder, andThen, at, field, list, map, map3, string, succeed)
import List
import Maybe
import String



-- MAIN


main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> toUnstyledDocument
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


pokemonShinySpriteUrl : String -> String
pokemonShinySpriteUrl pokemonUuid =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/" ++ pokemonUuid ++ ".png"


pokemonSpriteUrl : String -> String
pokemonSpriteUrl pokemonUuid =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" ++ pokemonUuid ++ ".png"


viewBasePokemon : BasePokemon -> Html Msg
viewBasePokemon basePokemon =
    a
        [ css
            [ displayFlex
            , flexDirection column
            , padding (px 8)
            , margin (px 4)
            , border3 (px 1) solid (hex "#ddd")
            , textDecoration none
            , color (hex "#000")
            ]
        , href ("/pokemon/" ++ basePokemon.uuid)
        ]
        [ span
            [ css
                [ textAlign center
                , textTransform capitalize
                , textDecoration none
                ]
            ]
            [ text basePokemon.name ]
        , div
            [ css
                [ alignSelf center
                , width (px 96)
                , height (px 96)
                , backgroundImage (url (pokemonSpriteUrl basePokemon.uuid))
                , transition
                    [ Css.Transitions.background 500
                    ]
                , hover
                    [ backgroundImage (url (pokemonShinySpriteUrl basePokemon.uuid))
                    ]
                ]
            ]
            []
        ]


viewAllBasePokemon : Model -> Html Msg
viewAllBasePokemon model =
    case model of
        Failure ->
            text "I could not any Pokemon for some reason. "

        Loading ->
            text "Loading Pokemon..."

        Success allPokemon ->
            div
                [ css
                    [ displayFlex
                    , flexWrap wrap
                    , justifyContent center
                    ]
                ]
                (List.map viewBasePokemon allPokemon)


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


toUnstyledDocument : Document Msg -> Browser.Document Msg
toUnstyledDocument doc =
    { title = doc.title
    , body = List.map Html.Styled.toUnstyled doc.body
    }


view : Model -> Document Msg
view model =
    { title = "PokElm"
    , body =
        [ div
            [ css
                [ displayFlex
                , flexDirection column
                , fontFamilies [ "Verdana" ]
                , marginTop (px 40)
                ]
            ]
            [ h2
                [ css [ margin3 (px 0) auto (px 20) ]
                ]
                [ text "Pokémon" ]
            , viewAllBasePokemon model
            ]
        ]
    }



-- HTTP


getAllPokemon : Cmd Msg
getAllPokemon =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon?limit=151"
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
