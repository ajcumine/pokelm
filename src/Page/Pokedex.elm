module Page.Pokedex exposing (fetch, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import Model exposing (Base, Pokedex, PokedexWebData)
import Parse
import RemoteData exposing (WebData)
import View



-- VIEW


viewPokedex : PokedexWebData -> Styled.Html msg
viewPokedex model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Initialising..."

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
            Styled.text "There was an error fetching your Pokemon"

        RemoteData.Success pokedex ->
            Styled.div
                [ css
                    [ displayFlex
                    , flexWrap wrap
                    , justifyContent center
                    ]
                ]
                (List.map (\pokemon -> View.pokemon pokemon.name pokemon.id) pokedex)


view : PokedexWebData -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div
            []
            [ View.pageTitle "Pokédex"
            , viewPokedex model
            ]



-- SERIALISATION


pokemonDecoder : Decoder Base
pokemonDecoder =
    Decode.map2 Base
        (Decode.field "name" Decode.string)
        (Decode.field "url" (Decode.string |> Decode.map Parse.idFromPokeApiUrlString))


pokedexDecoder : Decoder Pokedex
pokedexDecoder =
    Decode.at [ "results" ] (Decode.list pokemonDecoder)



-- HTTP


fetch : Cmd PokedexWebData
fetch =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon-species?limit=809"
        , expect = Http.expectJson RemoteData.fromResult pokedexDecoder
        }
