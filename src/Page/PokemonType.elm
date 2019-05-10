module Page.PokemonType exposing (Model, fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import RemoteData exposing (WebData)
import Route
import View



-- MODEL


type alias Model =
    WebData PokemonType


type alias BaseType =
    { name : String }


type alias BaseTypes =
    List BaseType


type alias DamageRelations =
    { doubleDamageFrom : BaseTypes
    , doubleDamageTo : BaseTypes
    , halfDamageFrom : BaseTypes
    , halfDamageTo : BaseTypes
    , noDamageFrom : BaseTypes
    , noDamageTo : BaseTypes
    }


type alias PokemonType =
    { name : String
    , id : Int
    , pokemon : List Pokemon
    , damageRelations : DamageRelations
    }


type alias Pokemon =
    { name : String
    , id : Int
    }


init : Model
init =
    RemoteData.NotAsked



-- VIEW


pokemonImageSrc : Int -> String
pokemonImageSrc id =
    "/assets/images/pokemon/" ++ String.fromInt id ++ ".png"


viewPokemon : Pokemon -> Styled.Html msg
viewPokemon pokemon =
    View.pokemon pokemon.name pokemon.id


viewDamageRelation : BaseType -> Styled.Html msg
viewDamageRelation baseType =
    Styled.div
        [ css
            []
        ]
        [ Styled.a
            [ Route.styledHref (Route.PokemonType baseType.name)
            ]
            [ Styled.div
                [ css
                    []
                ]
                [ Styled.text baseType.name
                ]
            ]
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
        [ Styled.div
            [ css
                [ margin (px 4)
                , padding2 (px 16) (px 20)
                ]
            ]
            [ Styled.text "take double damage from"
            , Styled.div
                []
                (List.map viewDamageRelation damageRelations.doubleDamageFrom)
            ]
        , Styled.div
            [ css
                [ margin (px 4)
                , padding2 (px 16) (px 20)
                ]
            ]
            [ Styled.text "deal double damage to"
            , Styled.div
                []
                (List.map viewDamageRelation damageRelations.doubleDamageTo)
            ]
        , Styled.div
            [ css
                [ margin (px 4)
                , padding2 (px 16) (px 20)
                ]
            ]
            [ Styled.text "take half damage from"
            , Styled.div
                []
                (List.map viewDamageRelation damageRelations.halfDamageFrom)
            ]
        , Styled.div
            [ css
                [ margin (px 4)
                , padding2 (px 16) (px 20)
                ]
            ]
            [ Styled.text "deal half damage to"
            , Styled.div
                []
                (List.map viewDamageRelation damageRelations.halfDamageTo)
            ]
        , Styled.div
            [ css
                [ margin (px 4)
                , padding2 (px 16) (px 20)
                ]
            ]
            [ Styled.text "take no damage from"
            , Styled.div
                []
                (List.map viewDamageRelation damageRelations.noDamageFrom)
            ]
        , Styled.div
            [ css
                [ margin (px 4)
                , padding2 (px 16) (px 20)
                ]
            ]
            [ Styled.text "deal no damage to"
            , Styled.div
                []
                (List.map viewDamageRelation damageRelations.noDamageTo)
            ]
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
            (List.map viewPokemon pokemonType.pokemon)
        ]


viewPokemonType : Model -> Styled.Html msg
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


view : Model -> Html msg
view model =
    Styled.toUnstyled <|
        viewPokemonType model



-- SERIALISATION


getId : String -> Int
getId url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "0" |> String.toInt |> Maybe.withDefault 0


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    Decode.succeed Pokemon
        |> Pipeline.requiredAt [ "pokemon", "name" ] Decode.string
        |> Pipeline.requiredAt [ "pokemon", "url" ] (Decode.string |> Decode.map getId)


baseTypeDecoder : Decoder BaseType
baseTypeDecoder =
    Decode.succeed BaseType
        |> Pipeline.required "name" Decode.string


damageRelationDecoder : Decoder DamageRelations
damageRelationDecoder =
    Decode.succeed DamageRelations
        |> Pipeline.required "double_damage_from" (Decode.list baseTypeDecoder)
        |> Pipeline.required "double_damage_to" (Decode.list baseTypeDecoder)
        |> Pipeline.required "half_damage_from" (Decode.list baseTypeDecoder)
        |> Pipeline.required "half_damage_to" (Decode.list baseTypeDecoder)
        |> Pipeline.required "no_damage_from" (Decode.list baseTypeDecoder)
        |> Pipeline.required "no_damage_to" (Decode.list baseTypeDecoder)


pokemonTypeDecoder : Decoder PokemonType
pokemonTypeDecoder =
    Decode.succeed PokemonType
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "pokemon" (Decode.list pokemonDecoder)
        |> Pipeline.required "damage_relations" damageRelationDecoder



-- HTTP


fetch : String -> Cmd Model
fetch idOrName =
    Http.get
        { url = "https://pokeapi.co/api/v2/type/" ++ idOrName
        , expect = Http.expectJson RemoteData.fromResult pokemonTypeDecoder
        }
