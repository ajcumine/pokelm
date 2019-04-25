module Page.Pokedex exposing (Model, fetch, init, view)

import Browser
import Html as H exposing (Html)
import Http
import Json.Decode as Decode exposing (Decoder, andThen, at, field, list, map, map3, string)
import RemoteData exposing (WebData)



-- MODEL


type alias Model =
    WebData Pokedex


type alias Pokedex =
    List Pokemon


type alias Pokemon =
    { name : String
    , url : String
    , uuid : String
    }


init : Model
init =
    RemoteData.NotAsked



-- VIEW


pokemonShinySpriteUrl : String -> String
pokemonShinySpriteUrl pokemonUuid =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/" ++ pokemonUuid ++ ".png"


pokemonSpriteUrl : String -> String
pokemonSpriteUrl pokemonUuid =
    "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/" ++ pokemonUuid ++ ".png"


viewPokemon : Pokemon -> Html msg
viewPokemon pokemon =
    H.div
        []
        [ H.span
            []
            [ H.text pokemon.name ]
        ]


viewPokedex : Model -> Html msg
viewPokedex model =
    case model of
        RemoteData.NotAsked ->
            H.text "Not Asked"

        RemoteData.Loading ->
            H.text "Loading Pokemon..."

        RemoteData.Failure error ->
            H.text "There was an error fetching your Pokemon"

        RemoteData.Success pokedex ->
            H.div
                []
                (List.map viewPokemon pokedex)


view : Model -> Html msg
view model =
    H.div
        []
        [ H.h2
            []
            [ H.text "Pokédex" ]
        , viewPokedex model
        ]



-- SERIALISATION


getUuid : String -> String
getUuid url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "1"


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    map3 Pokemon
        (field "name" string)
        (field "url" string)
        (field "url" (string |> map getUuid))


pokedexDecoder : Decoder Pokedex
pokedexDecoder =
    at [ "results" ] (list pokemonDecoder)



-- HTTP


fetch : Cmd Model
fetch =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon?limit=151"
        , expect = Http.expectJson RemoteData.fromResult pokedexDecoder
        }
