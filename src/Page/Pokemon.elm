module Page.Pokemon exposing (fetch, init, view)

import Css exposing (..)
import Css.Transitions exposing (transition)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Html.Styled.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Model exposing (Base, BasePokemon, EvolutionChain, Evolutions(..), Pokemon, PokemonDetail, PokemonWebData, Species, Team)
import Msg exposing (Msg(..))
import RemoteData exposing (WebData)
import RemoteData.Http
import Route
import Task exposing (Task)
import View



-- MODEL


init : PokemonWebData
init =
    RemoteData.NotAsked



--VIEW


viewEvolution : EvolutionChain -> Styled.Html msg
viewEvolution evolution =
    Styled.div
        [ css
            [ displayFlex
            , alignItems center
            , justifyContent center
            ]
        ]
        [ View.pokemon evolution.name evolution.id
        , case evolution.evolutionChain of
            Evolutions evolutions ->
                Styled.div
                    []
                    (List.map viewEvolution evolutions)
        ]


pokemonImageSrc : Int -> String
pokemonImageSrc id =
    "assets/images/pokemon/" ++ String.fromInt id ++ ".png"


shinyImageSrc : Int -> String
shinyImageSrc id =
    "assets/images/shiny/" ++ String.fromInt id ++ ".png"


viewPokemonDetails : Pokemon -> List Pokemon -> Styled.Html Msg
viewPokemonDetails pokemon teamMembers =
    Styled.div []
        [ View.pageTitle (String.fromInt pokemon.id ++ ": " ++ pokemon.name)
        , Styled.div
            [ css
                [ displayFlex
                , justifyContent center
                ]
            ]
            [ Styled.img [ src (pokemonImageSrc pokemon.id) ] []
            , Styled.img [ src (shinyImageSrc pokemon.id) ] []
            ]
        , Styled.button
            [ onClick <|
                if List.member pokemon teamMembers then
                    RemoveFromTeam pokemon

                else
                    AddToTeam pokemon
            , css
                [ backgroundColor (hex "#ffffff")
                , display block
                , margin2 (px 8) auto
                , padding2 (px 12) (px 16)
                , textAlign center
                , textDecoration none
                , color (hex "#000000")
                , borderRadius (px 3)
                , boxShadow5 (px 0) (px 1) (px 3) (px 1) (rgba 60 64 67 0.16)
                , hover
                    [ backgroundColor (hex "#00000005")
                    , boxShadow5 (px 0) (px 2) (px 8) (px 4) (rgba 60 64 67 0.1)
                    ]
                , transition
                    [ Css.Transitions.backgroundColor3 135 0 (Css.Transitions.cubicBezier 0.4 0 0.2 1)
                    , Css.Transitions.background3 135 0 (Css.Transitions.cubicBezier 0.4 0 0.2 1)
                    ]
                ]
            ]
            [ Styled.text
                (if List.member pokemon teamMembers then
                    "Remove from Team"

                 else
                    "Add to Team"
                )
            ]
        , View.subTitle "Types"
        , Styled.div
            [ css
                [ displayFlex
                , justifyContent center
                ]
            ]
            (List.map (\pokemonType -> View.pokemonType pokemonType.name) pokemon.types)
        , View.subTitle "Evolution Chain"
        , Styled.div []
            [ viewEvolution pokemon.evolutionChain ]
        , View.subTitle "Varieties"
        , Styled.div
            [ css
                [ displayFlex
                , flexWrap wrap
                , justifyContent center
                ]
            ]
            (List.map (\variety -> View.pokemon variety.name variety.id) pokemon.varieties)
        ]


viewPokemon : PokemonWebData -> List Pokemon -> Styled.Html Msg
viewPokemon model teamMembers =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
            Styled.text "There was an error fetching your Pokemon"

        RemoteData.Success pokemon ->
            viewPokemonDetails pokemon teamMembers


view : PokemonWebData -> List Pokemon -> Html Msg
view model teamMembers =
    Styled.toUnstyled <|
        viewPokemon model teamMembers



-- SERIALISATION


pokemonTypeDecoder : Decoder Base
pokemonTypeDecoder =
    Decode.succeed Base
        |> Pipeline.requiredAt [ "type", "name" ] Decode.string
        |> Pipeline.requiredAt [ "type", "url" ] (Decode.string |> Decode.map getId)


pokemonDecoder : Decoder BasePokemon
pokemonDecoder =
    Decode.succeed BasePokemon
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "types" (Decode.list pokemonTypeDecoder)
        |> Pipeline.requiredAt [ "species", "url" ] Decode.string


getId : String -> Int
getId url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "0" |> String.toInt |> Maybe.withDefault 0


evolutionDecoder : Decoder EvolutionChain
evolutionDecoder =
    Decode.succeed EvolutionChain
        |> Pipeline.requiredAt [ "species", "name" ] Decode.string
        |> Pipeline.requiredAt [ "species", "url" ] (Decode.string |> Decode.map getId)
        |> Pipeline.required "evolves_to" (Decode.map Evolutions (Decode.list (Decode.lazy (\_ -> evolutionDecoder))))


evolutionsDecoder : Decoder EvolutionChain
evolutionsDecoder =
    Decode.succeed EvolutionChain
        |> Pipeline.requiredAt [ "chain", "species", "name" ] Decode.string
        |> Pipeline.requiredAt [ "chain", "species", "url" ] (Decode.string |> Decode.map getId)
        |> Pipeline.requiredAt [ "chain", "evolves_to" ] (Decode.map Evolutions (Decode.list (Decode.lazy (\_ -> evolutionDecoder))))


varietyDecoder : Decoder Base
varietyDecoder =
    Decode.succeed Base
        |> Pipeline.requiredAt [ "pokemon", "name" ] Decode.string
        |> Pipeline.requiredAt [ "pokemon", "url" ] (Decode.string |> Decode.map getId)


speciesDecoder : Decoder Species
speciesDecoder =
    Decode.succeed Species
        |> Pipeline.requiredAt [ "evolution_chain", "url" ] Decode.string
        |> Pipeline.required "varieties" (Decode.list varietyDecoder)


buildPokemonData : BasePokemon -> WebData PokemonDetail -> WebData Pokemon
buildPokemonData basePokemon pokemonDetailResponse =
    case pokemonDetailResponse of
        RemoteData.Success pokemonDetail ->
            RemoteData.succeed
                { name = basePokemon.name
                , id = basePokemon.id
                , types = basePokemon.types
                , evolutionChain = pokemonDetail.evolutionChain
                , varieties = pokemonDetail.varieties
                }

        RemoteData.Failure error ->
            RemoteData.Failure error

        RemoteData.NotAsked ->
            RemoteData.NotAsked

        RemoteData.Loading ->
            RemoteData.Loading


buildSpeciesEvolution : Species -> WebData EvolutionChain -> WebData PokemonDetail
buildSpeciesEvolution species evolutionChainResponse =
    case evolutionChainResponse of
        RemoteData.Success evolutionChain ->
            RemoteData.succeed
                { evolutionChain = evolutionChain
                , varieties = species.varieties
                }

        RemoteData.Failure error ->
            RemoteData.Failure error

        RemoteData.NotAsked ->
            RemoteData.NotAsked

        RemoteData.Loading ->
            RemoteData.Loading



-- HTTP


getPokemonDetails : String -> Task () (WebData PokemonDetail)
getPokemonDetails nameOrId =
    getSpecies nameOrId
        |> Task.andThen
            (\speciesResponse ->
                case speciesResponse of
                    RemoteData.Success species ->
                        Task.map2 buildSpeciesEvolution (Task.succeed species) (getEvolutions species.evolutionChainUrl)

                    RemoteData.Failure error ->
                        Task.succeed (RemoteData.Failure error)

                    RemoteData.NotAsked ->
                        Task.succeed RemoteData.NotAsked

                    RemoteData.Loading ->
                        Task.succeed RemoteData.Loading
            )


getEvolutions : String -> Task () (WebData EvolutionChain)
getEvolutions evolutionChainUrl =
    RemoteData.Http.getTask evolutionChainUrl evolutionsDecoder


getSpecies : String -> Task () (WebData Species)
getSpecies speciesUrl =
    RemoteData.Http.getTask speciesUrl speciesDecoder


getPokemon : String -> Task () (WebData BasePokemon)
getPokemon nameOrId =
    RemoteData.Http.getTask ("https://pokeapi.co/api/v2/pokemon/" ++ nameOrId) pokemonDecoder


fetch : String -> Cmd PokemonWebData
fetch nameOrId =
    getPokemon nameOrId
        |> Task.andThen
            (\basePokemonResponse ->
                case basePokemonResponse of
                    RemoteData.Success basePokemon ->
                        Task.map2 buildPokemonData (Task.succeed basePokemon) (getPokemonDetails basePokemon.speciesUrl)

                    RemoteData.Failure error ->
                        Task.succeed (RemoteData.Failure error)

                    RemoteData.NotAsked ->
                        Task.succeed RemoteData.NotAsked

                    RemoteData.Loading ->
                        Task.succeed RemoteData.Loading
            )
        |> Task.attempt
            (\result ->
                case result of
                    Ok response ->
                        response

                    Err _ ->
                        RemoteData.NotAsked
            )
