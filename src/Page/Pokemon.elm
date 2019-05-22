module Page.Pokemon exposing (fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Html.Styled.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Model exposing (BasePokemon, BasePokemonType, EvolutionChain, Evolutions(..), Pokemon, PokemonDetail, PokemonWebData, Species, Team, Variety)
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


viewPokemonDetails : Pokemon -> Team -> Styled.Html Msg
viewPokemonDetails pokemon team =
    Styled.div []
        [ View.pageTitle (String.fromInt pokemon.id ++ ": " ++ pokemon.name)
        , Styled.img [ src (pokemonImageSrc pokemon.id) ] []
        , Styled.img [ src (shinyImageSrc pokemon.id) ] []
        , if List.member pokemon team then
            Styled.button
                [ onClick <| RemoveFromTeam pokemon ]
                [ Styled.text "Remove from Team" ]

          else
            Styled.button
                [ onClick <| AddToTeam pokemon ]
                [ Styled.text "Add to Team" ]
        , Styled.h3 [] [ Styled.text "Types" ]
        , Styled.div
            [ css
                []
            ]
            (List.map (\pokemonType -> View.pokemonType pokemonType.name) pokemon.types)
        , Styled.h3 [] [ Styled.text "Evolution Chain" ]
        , Styled.div []
            [ viewEvolution pokemon.evolutionChain ]
        , Styled.h3 [] [ Styled.text "Varieties" ]
        , Styled.div
            [ css
                [ displayFlex
                , flexWrap wrap
                , justifyContent center
                ]
            ]
            (List.map (\variety -> View.pokemon variety.name variety.id) pokemon.varieties)
        ]


viewPokemon : PokemonWebData -> Team -> Styled.Html Msg
viewPokemon model team =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
            Styled.text "There was an error fetching your Pokemon"

        RemoteData.Success pokemon ->
            viewPokemonDetails pokemon team


view : PokemonWebData -> Team -> Html Msg
view model team =
    Styled.toUnstyled <|
        viewPokemon model team



-- SERIALISATION


pokemonTypeDecoder : Decoder BasePokemonType
pokemonTypeDecoder =
    Decode.succeed BasePokemonType
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


varietyDecoder : Decoder Variety
varietyDecoder =
    Decode.succeed Variety
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
