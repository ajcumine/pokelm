module Page.Pokedex exposing (Model, fetch, init, view)

import Browser
import Html exposing (Html)
import Html.Styled as Styled
import Http
import Json.Decode as Decode exposing (Decoder)
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


viewPokemon : Pokemon -> Styled.Html msg
viewPokemon pokemon =
    Styled.div
        []
        [ Styled.span
            []
            [ Styled.text pokemon.name ]
        ]


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
                []
                (List.map viewPokemon pokedex)


view : Model -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div
            []
            [ Styled.h2
                []
                [ Styled.text "Pokédex" ]
            , viewPokedex model
            ]



-- SERIALISATION


getUuid : String -> String
getUuid url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "1"


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    Decode.map3 Pokemon
        (Decode.field "name" Decode.string)
        (Decode.field "url" Decode.string)
        (Decode.field "url" (Decode.string |> Decode.map getUuid))


pokedexDecoder : Decoder Pokedex
pokedexDecoder =
    Decode.at [ "results" ] (Decode.list pokemonDecoder)



-- HTTP


fetch : Cmd Model
fetch =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon?limit=151"
        , expect = Http.expectJson RemoteData.fromResult pokedexDecoder
        }
