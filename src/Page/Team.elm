module Page.Team exposing (fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Model exposing (Base, DamageRelations, Pokemon, PokemonType, PokemonTypeWebData, PokemonTypesWebData, Team)
import Parse
import RemoteData
import Set exposing (Set)
import View



--- INIT


init : Team
init =
    { members = []
    , pokemonTypes = []
    }



--- VIEW


viewTeamNumber : List Pokemon -> Styled.Html msg
viewTeamNumber members =
    Styled.div
        [ css
            [ displayFlex
            , justifyContent center
            ]
        ]
        [ Styled.text ((members |> List.length |> String.fromInt) ++ " of 6")
        ]


viewTeamMembers : List Pokemon -> Styled.Html msg
viewTeamMembers members =
    Styled.div
        [ css
            [ displayFlex
            , justifyContent center
            , flexWrap wrap
            ]
        ]
        (List.map (\pokemon -> View.pokemon pokemon.name pokemon.id) members)


viewTeamPokemonTypes : List PokemonType -> Styled.Html msg
viewTeamPokemonTypes pokemonTypes =
    Styled.div
        [ css
            [ displayFlex
            , justifyContent center
            , flexWrap wrap
            ]
        ]
        (List.map (\pokemonType -> View.pokemonType pokemonType.name) pokemonTypes)


teamWeaknesses : List PokemonType -> Set String
teamWeaknesses pokemonTypes =
    pokemonTypes
        |> List.map
            (\pokemonType ->
                pokemonType.damageRelations.doubleDamageFrom
                    |> List.append pokemonType.damageRelations.halfDamageTo
                    |> List.append pokemonType.damageRelations.noDamageTo
                    |> List.map (\base -> base.name)
            )
        |> List.concat
        |> Set.fromList


teamStrengths : List PokemonType -> Set String
teamStrengths pokemonTypes =
    pokemonTypes
        |> List.map
            (\pokemonType ->
                pokemonType.damageRelations.doubleDamageTo
                    |> List.append pokemonType.damageRelations.halfDamageFrom
                    |> List.append pokemonType.damageRelations.noDamageFrom
                    |> List.map (\base -> base.name)
            )
        |> List.concat
        |> Set.fromList


viewTeamWeaknesses : List PokemonType -> Styled.Html msg
viewTeamWeaknesses pokemonTypes =
    Styled.div
        [ css
            [ displayFlex
            , justifyContent center
            , flexWrap wrap
            ]
        ]
        (Set.diff (teamWeaknesses pokemonTypes) (teamStrengths pokemonTypes)
            |> Set.toList
            |> List.map (\filteredType -> View.pokemonType filteredType)
        )


teamSTABCoverage : List PokemonType -> Set String
teamSTABCoverage pokemonTypes =
    pokemonTypes
        |> List.map
            (\pokemonType ->
                pokemonType.damageRelations.doubleDamageTo
                    |> List.map (\base -> base.name)
            )
        |> List.concat
        |> Set.fromList


viewTeamSTABCoverage : List PokemonType -> Styled.Html msg
viewTeamSTABCoverage pokemonTypes =
    Styled.div
        [ css
            [ displayFlex
            , justifyContent center
            , flexWrap wrap
            ]
        ]
        (teamSTABCoverage pokemonTypes
            |> Set.toList
            |> List.map (\stabType -> View.pokemonType stabType)
        )


missingSTABCoverage : List PokemonType -> List Base -> Set String
missingSTABCoverage teamPokemonTypes allPokemonTypes =
    Set.diff
        (allPokemonTypes
            |> List.map (\base -> base.name)
            |> Set.fromList
            |> Set.remove "shadow"
            |> Set.remove "unknown"
        )
        (teamSTABCoverage teamPokemonTypes)


viewMissingSTABCoverage : List PokemonType -> PokemonTypesWebData -> Styled.Html msg
viewMissingSTABCoverage teamPokemonTypes pokemonTypesWebData =
    case pokemonTypesWebData of
        RemoteData.Success allPokemonTypes ->
            Styled.div
                [ css
                    [ displayFlex
                    , justifyContent center
                    , flexWrap wrap
                    ]
                ]
                (missingSTABCoverage teamPokemonTypes allPokemonTypes
                    |> Set.toList
                    |> List.map (\missingSTABType -> View.pokemonType missingSTABType)
                )

        _ ->
            Styled.div
                []
                [ Styled.text "Loading Pokemon Types..." ]


view : Team -> PokemonTypesWebData -> Html msg
view team pokemonTypesWebData =
    Styled.toUnstyled <|
        Styled.div
            []
            [ View.pageTitle "Team"
            , viewTeamNumber team.members
            , viewTeamMembers team.members
            , View.subTitle "Team Types"
            , viewTeamPokemonTypes team.pokemonTypes
            , View.subTitle "Team Weaknesses"
            , viewTeamWeaknesses team.pokemonTypes
            , View.subTitle "Team STAB Coverage"
            , viewTeamSTABCoverage team.pokemonTypes
            , View.subTitle "Missing STAB Coverage"
            , viewMissingSTABCoverage team.pokemonTypes pokemonTypesWebData
            ]



--- SERIALIZATION


pokemonDecoder : Decoder Base
pokemonDecoder =
    Decode.succeed Base
        |> Pipeline.requiredAt [ "pokemon", "name" ] Decode.string
        |> Pipeline.requiredAt [ "pokemon", "url" ] (Decode.string |> Decode.map Parse.idFromPokeApiUrlString)


basePokemonTypeDecoder : Decoder Base
basePokemonTypeDecoder =
    Decode.succeed Base
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "url" (Decode.string |> Decode.map Parse.idFromPokeApiUrlString)


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
        |> fetchPokemonTypes
        |> Cmd.batch
