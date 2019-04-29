module Page.Pokemon exposing (Model, fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import RemoteData exposing (WebData)
import RemoteData.Http
import Task exposing (Task)



-- MODEL


type alias Model =
    WebData Pokemon


type alias Sprites =
    { default : String
    , shiny : String
    }


type alias PokemonType =
    { name : String }


type alias Pokemon =
    { name : String
    , order : Int
    , types : List PokemonType
    , sprites : Sprites
    }


init : Model
init =
    RemoteData.NotAsked



--VIEW


viewPokemonType : PokemonType -> Styled.Html msg
viewPokemonType pokemonType =
    Styled.div []
        [ Styled.text pokemonType.name ]


viewPokemonDetails : Pokemon -> Styled.Html msg
viewPokemonDetails pokemon =
    Styled.div []
        [ Styled.h2
            [ css [ margin3 (px 0) auto (px 20) ]
            ]
            [ Styled.text (String.fromInt pokemon.order ++ ": " ++ pokemon.name) ]
        , Styled.img [ src pokemon.sprites.default ] []
        , Styled.img [ src pokemon.sprites.shiny ] []
        , Styled.div []
            (List.map viewPokemonType pokemon.types)
        ]


viewPokemon : Model -> Styled.Html msg
viewPokemon model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
            let
                errorLog =
                    Debug.log "Error" error
            in
            Styled.text "There was an error fetching your Pokemon"

        RemoteData.Success pokemon ->
            Styled.div
                [ css
                    [ displayFlex
                    , flexWrap wrap
                    , justifyContent center
                    ]
                ]
                [ viewPokemonDetails pokemon ]


view : Model -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div
            [ css
                [ displayFlex
                , flexDirection column
                , fontFamilies [ "Verdana" ]
                , marginTop (px 40)
                ]
            ]
            [ viewPokemon model ]



-- SERIALISATION


spriteDecoder : Decoder Sprites
spriteDecoder =
    Decode.succeed Sprites
        |> Pipeline.required "front_default" Decode.string
        |> Pipeline.required "front_shiny" Decode.string


pokemonTypeDecoder : Decoder PokemonType
pokemonTypeDecoder =
    Decode.succeed PokemonType
        |> Pipeline.requiredAt [ "type", "name" ] Decode.string


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    Decode.succeed Pokemon
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "order" Decode.int
        |> Pipeline.required "types" (Decode.list pokemonTypeDecoder)
        |> Pipeline.required "sprites" spriteDecoder



-- TASK BASED DATA FETCH
-- type alias StandardPokemon =
--     { name : String
--     , order : Int
--     , types : List PokemonType
--     , sprites : Sprites
--     , evolutionChainUrl : String
--     }
-- type alias BasicPokemon =
--     { name : String
--     , order : Int
--     , types : List PokemonType
--     , sprites : Sprites
--     }
-- type alias Species =
--     { evolutionChainUrl : String
--     }
-- buildPokemon : BasicPokemon -> Species -> StandardPokemon
-- buildPokemon pokemon species =
--     { name = pokemon.name
--     , order = pokemon.order
--     , types = pokemon.types
--     , sprites = pokemon.sprites
--     , evolutionChainUrl = species.evolutionChainUrl
--     }
-- HTTP


type alias Msg =
    Model


getPokemon : String -> Task () (WebData Pokemon)
getPokemon order =
    RemoteData.Http.getTask ("https://pokeapi.co/api/v2/pokemon/" ++ order) pokemonDecoder


fetch : String -> Cmd Msg
fetch string =
    getPokemon string
        |> Task.attempt
            (\result ->
                case result of
                    Ok response ->
                        response

                    Err _ ->
                        RemoteData.NotAsked
            )
