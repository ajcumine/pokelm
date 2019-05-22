module Page.Team exposing (fetch, init, view)

import Html exposing (Html)
import Html.Styled as Styled
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Model exposing (Base, DamageRelations, Pokemon, PokemonType, PokemonTypeWebData, Team)
import RemoteData exposing (WebData)
import Set exposing (Set)
import View



--- INIT


init : Team
init =
    { members = []
    , pokemonTypes = []
    }



--- VIEW


viewTeamMembers : List Pokemon -> Styled.Html msg
viewTeamMembers members =
    Styled.div
        []
        (List.map (\pokemon -> View.pokemon pokemon.name pokemon.id) members)


viewTeamPokemonTypes : List PokemonType -> Styled.Html msg
viewTeamPokemonTypes pokemonTypes =
    Styled.div
        []
        (List.map (\pokemonType -> View.pokemonType pokemonType.name) pokemonTypes)


viewTeamWeaknesses : List PokemonType -> Styled.Html msg
viewTeamWeaknesses pokemonTypes =
    Styled.div
        []
        []


view : Team -> Html msg
view team =
    Styled.toUnstyled <|
        Styled.div
            []
            [ View.pageTitle "Team"
            , viewTeamMembers team.members
            , View.subTitle "Team Types"
            , viewTeamPokemonTypes team.pokemonTypes
            , View.subTitle "Team Weaknesses"
            , viewTeamWeaknesses team.pokemonTypes
            ]



--- SERIALIZATION


getId : String -> Int
getId url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "0" |> String.toInt |> Maybe.withDefault 0


pokemonDecoder : Decoder Base
pokemonDecoder =
    Decode.succeed Base
        |> Pipeline.requiredAt [ "pokemon", "name" ] Decode.string
        |> Pipeline.requiredAt [ "pokemon", "url" ] (Decode.string |> Decode.map getId)


basePokemonTypeDecoder : Decoder Base
basePokemonTypeDecoder =
    Decode.succeed Base
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "url" (Decode.string |> Decode.map getId)


damageRelationDecoder : Decoder DamageRelations
damageRelationDecoder =
    Decode.succeed DamageRelations
        |> Pipeline.required "double_damage_from" (Decode.list basePokemonTypeDecoder)
        |> Pipeline.required "double_damage_to" (Decode.list basePokemonTypeDecoder)
        |> Pipeline.required "half_damage_from" (Decode.list basePokemonTypeDecoder)
        |> Pipeline.required "half_damage_to" (Decode.list basePokemonTypeDecoder)
        |> Pipeline.required "no_damage_from" (Decode.list basePokemonTypeDecoder)
        |> Pipeline.required "no_damage_to" (Decode.list basePokemonTypeDecoder)


pokemonTypeDecoder : Decoder PokemonType
pokemonTypeDecoder =
    Decode.succeed PokemonType
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "pokemon" (Decode.list pokemonDecoder)
        |> Pipeline.required "damage_relations" damageRelationDecoder



--- HTTP


pokemonTypeIds : List Pokemon -> Set Int
pokemonTypeIds members =
    members
        |> List.map (\member -> member.types)
        |> List.concat
        |> List.map (\pokemonType -> pokemonType.id)
        |> Set.fromList


filterExistingFetchedPokemonTypes : List PokemonType -> Set Int -> Set Int
filterExistingFetchedPokemonTypes existingPokemonTypes pokemonTypes =
    List.map (\existing -> existing.id) existingPokemonTypes
        |> Set.fromList
        |> Set.diff pokemonTypes


fetchPokemonType : Int -> Cmd PokemonTypeWebData
fetchPokemonType id =
    Http.get
        { url = "https://pokeapi.co/api/v2/type/" ++ String.fromInt id
        , expect = Http.expectJson RemoteData.fromResult pokemonTypeDecoder
        }


fetchPokemonTypes : Set Int -> List (Cmd PokemonTypeWebData)
fetchPokemonTypes ids =
    Set.toList ids
        |> List.map (\pokemonTypeId -> fetchPokemonType pokemonTypeId)


fetch : Team -> Cmd PokemonTypeWebData
fetch team =
    pokemonTypeIds team.members
        |> filterExistingFetchedPokemonTypes team.pokemonTypes
        |> fetchPokemonTypes
        |> Cmd.batch
