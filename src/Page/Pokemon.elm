module Page.Pokemon exposing (Model, fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import RemoteData exposing (WebData)



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
            [ Styled.text pokemon.name ]
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
        |> Pipeline.required "types" (Decode.list pokemonTypeDecoder)
        |> Pipeline.required "sprites" spriteDecoder



-- HTTP


fetch : String -> Cmd Model
fetch pokemonNumber =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon/" ++ pokemonNumber
        , expect = Http.expectJson RemoteData.fromResult pokemonDecoder
        }
