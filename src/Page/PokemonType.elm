module Page.PokemonType exposing (fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Model exposing (Base, DamageRelations, PokemonType, PokemonTypeWebData)
import RemoteData exposing (WebData)
import View



-- MODEL


init : PokemonTypeWebData
init =
    RemoteData.NotAsked



-- VIEW


viewDamageRelation : String -> List Base -> Styled.Html msg
viewDamageRelation sectionTitle pokemonTypes =
    case List.isEmpty pokemonTypes of
        True ->
            Styled.div [] []

        False ->
            Styled.div
                [ css
                    [ margin (px 4)
                    , width (px 250)
                    , padding3 (px 0) (px 20) (px 16)
                    , border3 (px 1) solid (hex "#dedede")
                    ]
                ]
                [ Styled.h4
                    [ css
                        [ textTransform capitalize
                        , textAlign center
                        ]
                    ]
                    [ Styled.text sectionTitle ]
                , Styled.div
                    [ css
                        [ displayFlex
                        , flexDirection column
                        , alignItems center
                        ]
                    ]
                    (List.map (\pokemonType -> View.pokemonType pokemonType.name) pokemonTypes)
                ]


viewDamageRelations : DamageRelations -> Styled.Html msg
viewDamageRelations damageRelations =
    Styled.div
        [ css
            [ displayFlex
            , flexWrap wrap
            , justifyContent center
            ]
        ]
        [ viewDamageRelation "take double damage from" damageRelations.doubleDamageFrom
        , viewDamageRelation "deal double damage to" damageRelations.doubleDamageTo
        , viewDamageRelation "take half damage from" damageRelations.halfDamageFrom
        , viewDamageRelation "deal half damage to" damageRelations.halfDamageTo
        , viewDamageRelation "take no damage from" damageRelations.noDamageFrom
        , viewDamageRelation "deal no damage to" damageRelations.noDamageTo
        ]


viewType : PokemonType -> Styled.Html msg
viewType pokemonType =
    Styled.div []
        [ View.pageTitle pokemonType.name
        , Styled.div
            []
            [ View.subTitle "Damage Relations"
            , viewDamageRelations pokemonType.damageRelations
            ]
        , View.subTitle (pokemonType.name ++ " type Pokemon")
        , Styled.div
            [ css
                [ displayFlex
                , flexWrap wrap
                , justifyContent center
                ]
            ]
            (List.map (\pokemon -> View.pokemon pokemon.name pokemon.id) pokemonType.pokemon)
        ]


viewPokemonType : PokemonTypeWebData -> Styled.Html msg
viewPokemonType model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon Type..."

        RemoteData.Failure error ->
            Styled.text "There was an error fetching your Pokemon Type"

        RemoteData.Success pokemonType ->
            viewType pokemonType


view : PokemonTypeWebData -> Html msg
view model =
    Styled.toUnstyled <|
        viewPokemonType model



-- SERIALISATION


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



-- HTTP


fetch : String -> Cmd PokemonTypeWebData
fetch idOrName =
    Http.get
        { url = "https://pokeapi.co/api/v2/type/" ++ idOrName
        , expect = Http.expectJson RemoteData.fromResult pokemonTypeDecoder
        }
