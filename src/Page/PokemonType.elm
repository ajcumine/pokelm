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


type alias PokemonType =
    { name : String
    , id : Int
    , pokemon : List Pokemon
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


viewType : PokemonType -> Styled.Html msg
viewType pokemonType =
    Styled.div []
        [ View.pageTitle pokemonType.name
        , Styled.div
            [ css
                []
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


pokemonTypeDecoder : Decoder PokemonType
pokemonTypeDecoder =
    Decode.succeed PokemonType
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "pokemon" (Decode.list pokemonDecoder)



-- HTTP


fetch : String -> Cmd Model
fetch idOrName =
    Http.get
        { url = "https://pokeapi.co/api/v2/type/" ++ idOrName
        , expect = Http.expectJson RemoteData.fromResult pokemonTypeDecoder
        }
