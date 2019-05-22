module Page.Pokedex exposing (Base, Model, Pokedex, fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (WebData)
import View



-- MODEL


type alias Model =
    WebData Pokedex


type alias Pokedex =
    List Base


type alias Base =
    { name : String
    , id : Int
    }


init : Model
init =
    RemoteData.NotAsked



-- VIEW


viewPokedex : Model -> Styled.Html msg
viewPokedex model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

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


view : Model -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div
            []
            [ View.pageTitle "Pokédex"
            , viewPokedex model
            ]



-- SERIALISATION


getId : String -> Int
getId url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "0" |> String.toInt |> Maybe.withDefault 0


pokemonDecoder : Decoder Base
pokemonDecoder =
    Decode.map2 Base
        (Decode.field "name" Decode.string)
        (Decode.field "url" (Decode.string |> Decode.map getId))


pokedexDecoder : Decoder Pokedex
pokedexDecoder =
    Decode.at [ "results" ] (Decode.list pokemonDecoder)



-- HTTP


fetch : Cmd Model
fetch =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon-species?limit=809"
        , expect = Http.expectJson RemoteData.fromResult pokedexDecoder
        }
