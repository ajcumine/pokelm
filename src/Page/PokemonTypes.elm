module Page.PokemonTypes exposing (fetch, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import Model exposing (Base, PokemonTypesWebData)
import RemoteData exposing (WebData)
import Set
import View



-- VIEW


viewTypes : PokemonTypesWebData -> Styled.Html msg
viewTypes model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
            Styled.text "There was an error fetching your Pokemon"

        RemoteData.Success pokemonTypes ->
            Styled.div
                [ css
                    [ displayFlex
                    , flexWrap wrap
                    , justifyContent center
                    ]
                ]
                (pokemonTypes
                    |> List.map (\pokemonType -> pokemonType.name)
                    |> Set.fromList
                    |> Set.remove "shadow"
                    |> Set.remove "unknown"
                    |> Set.toList
                    |> List.map (\filteredType -> View.pokemonType filteredType)
                )


view : PokemonTypesWebData -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div
            []
            [ View.pageTitle "Types"
            , viewTypes model
            ]



-- SERIALISATION


getId : String -> Int
getId url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "0" |> String.toInt |> Maybe.withDefault 0


typeDecoder : Decoder Base
typeDecoder =
    Decode.succeed Base
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "url" (Decode.string |> Decode.map getId)


typesDecoder : Decoder (List Base)
typesDecoder =
    Decode.at [ "results" ] (Decode.list typeDecoder)



-- HTTP


fetch : Cmd PokemonTypesWebData
fetch =
    Http.get
        { url = "https://pokeapi.co/api/v2/type"
        , expect = Http.expectJson RemoteData.fromResult typesDecoder
        }
