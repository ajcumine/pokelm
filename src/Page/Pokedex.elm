module Page.Pokedex exposing (Model, fetch, init, view)

import Css exposing (..)
import Css.Transitions exposing (transition)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (WebData)
import Route
import View



-- MODEL


type alias Model =
    WebData Pokedex


type alias Pokedex =
    List Pokemon


type alias Pokemon =
    { name : String
    , url : String
    , id : Int
    }


init : Model
init =
    RemoteData.NotAsked



-- VIEW


viewPokemon : Pokemon -> Styled.Html msg
viewPokemon pokemon =
    View.pokemon pokemon.name pokemon.id


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
                (List.map viewPokemon pokedex)


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


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    Decode.map3 Pokemon
        (Decode.field "name" Decode.string)
        (Decode.field "url" Decode.string)
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
