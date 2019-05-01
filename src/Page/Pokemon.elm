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
import Route
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


type alias BasePokemon =
    { name : String
    , order : Int
    , types : List PokemonType
    , sprites : Sprites
    }


type alias Species =
    { evolutionChainUrl : String
    }


type alias EvolutionChain =
    { name : String
    , order : String
    , evolutionChain : Evolutions
    }


type Evolutions
    = Evolutions (List EvolutionChain)


type alias Pokemon =
    { name : String
    , order : Int
    , types : List PokemonType
    , sprites : Sprites
    , evolutionChain : EvolutionChain
    }


init : Model
init =
    RemoteData.NotAsked



--VIEW


viewEvolution : EvolutionChain -> Styled.Html msg
viewEvolution evolution =
    Styled.div
        []
        [ Styled.a
            [ Route.styledHref (Route.Pokemon evolution.order)
            ]
            [ Styled.div
                [ css
                    [ textTransform capitalize
                    ]
                ]
                [ Styled.text evolution.name
                , case evolution.evolutionChain of
                    Evolutions evolutions ->
                        Styled.div
                            [ css
                                [ display inlineBlock
                                , marginLeft (px 20)
                                ]
                            ]
                            (List.map viewEvolution evolutions)
                ]
            ]
        ]


viewType : PokemonType -> Styled.Html msg
viewType pokemonType =
    Styled.div
        [ css
            [ textTransform capitalize
            , width (px 72)
            ]
        ]
        [ Styled.text pokemonType.name ]


viewPokemonDetails : Pokemon -> Styled.Html msg
viewPokemonDetails pokemon =
    Styled.div []
        [ Styled.h2
            [ css
                [ margin3 (px 0) auto (px 20)
                , textTransform capitalize
                ]
            ]
            [ Styled.text (String.fromInt pokemon.order ++ ": " ++ pokemon.name) ]
        , Styled.img [ src pokemon.sprites.default ] []
        , Styled.img [ src pokemon.sprites.shiny ] []
        , Styled.h3 [] [ Styled.text "Types" ]
        , Styled.div
            [ css
                [ displayFlex
                ]
            ]
            (List.map viewType pokemon.types)
        , Styled.h3 [] [ Styled.text "Evolution Chain" ]
        , Styled.div []
            [ viewEvolution pokemon.evolutionChain ]
        ]


viewPokemon : Model -> Styled.Html msg
viewPokemon model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
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


pokemonDecoder : Decoder BasePokemon
pokemonDecoder =
    Decode.succeed BasePokemon
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "order" Decode.int
        |> Pipeline.required "types" (Decode.list pokemonTypeDecoder)
        |> Pipeline.required "sprites" spriteDecoder


getOrder : String -> String
getOrder url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "1"


evolutionDecoder : Decoder EvolutionChain
evolutionDecoder =
    Decode.succeed EvolutionChain
        |> Pipeline.requiredAt [ "species", "name" ] Decode.string
        |> Pipeline.requiredAt [ "species", "url" ] (Decode.string |> Decode.map getOrder)
        |> Pipeline.required "evolves_to" (Decode.map Evolutions (Decode.list (Decode.lazy (\_ -> evolutionDecoder))))


evolutionsDecoder : Decoder EvolutionChain
evolutionsDecoder =
    Decode.succeed EvolutionChain
        |> Pipeline.requiredAt [ "chain", "species", "name" ] Decode.string
        |> Pipeline.requiredAt [ "chain", "species", "url" ] (Decode.string |> Decode.map getOrder)
        |> Pipeline.requiredAt [ "chain", "evolves_to" ] (Decode.map Evolutions (Decode.list (Decode.lazy (\_ -> evolutionDecoder))))


speciesDecoder : Decoder Species
speciesDecoder =
    Decode.succeed Species
        |> Pipeline.requiredAt [ "evolution_chain", "url" ] Decode.string


buildPokemon : BasePokemon -> EvolutionChain -> Pokemon
buildPokemon basePokemon evolutionChain =
    let
        _ =
            Debug.log "evolutionChain" evolutionChain
    in
    { name = basePokemon.name
    , order = basePokemon.order
    , types = basePokemon.types
    , sprites = basePokemon.sprites
    , evolutionChain = evolutionChain
    }


buildPokemonResponse : WebData BasePokemon -> WebData EvolutionChain -> WebData Pokemon
buildPokemonResponse pokemonResponse evolutionsResponse =
    RemoteData.map2 buildPokemon pokemonResponse evolutionsResponse



-- HTTP


emptyEvolutionChain : EvolutionChain
emptyEvolutionChain =
    { name = ""
    , order = "0"
    , evolutionChain = Evolutions []
    }


getEvolutions : String -> Task () (WebData EvolutionChain)
getEvolutions order =
    getSpecies order
        |> Task.andThen
            (\speciesData ->
                case speciesData of
                    RemoteData.Success result ->
                        RemoteData.Http.getTask result.evolutionChainUrl evolutionsDecoder

                    RemoteData.Failure error ->
                        Task.fail error |> RemoteData.fromTask

                    _ ->
                        Task.succeed emptyEvolutionChain |> RemoteData.fromTask
            )


getSpecies : String -> Task () (WebData Species)
getSpecies order =
    RemoteData.Http.getTask ("https://pokeapi.co/api/v2/pokemon-species/" ++ order) speciesDecoder


getPokemon : String -> Task () (WebData BasePokemon)
getPokemon order =
    RemoteData.Http.getTask ("https://pokeapi.co/api/v2/pokemon/" ++ order) pokemonDecoder


fetch : String -> Cmd Model
fetch order =
    Task.map2 buildPokemonResponse (getPokemon order) (getEvolutions order)
        |> Task.attempt
            (\result ->
                case result of
                    Ok response ->
                        response

                    Err _ ->
                        RemoteData.NotAsked
            )
