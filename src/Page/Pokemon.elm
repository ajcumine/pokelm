module Page.Pokemon exposing (Model, fetch, init, view)

import Html exposing (Html)
import Html.Styled as Styled
import Http
import Json.Decode as Decode exposing (Decoder)
import RemoteData exposing (WebData)



-- MODEL


type alias Model =
    WebData Pokemon


type alias Pokemon =
    { name : String
    }


init : Model
init =
    RemoteData.NotAsked



--VIEW


viewPokemon : Model -> Styled.Html msg
viewPokemon model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
            Styled.text "There was an error fetching your Pokemon"

        RemoteData.Success pokemon ->
            Styled.div
                []
                [ Styled.text pokemon.name ]


view : Model -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div []
            [ viewPokemon model ]



-- SERIALISATION


pokemonDecoder : Decoder Pokemon
pokemonDecoder =
    Decode.map Pokemon
        (Decode.field "name" Decode.string)



-- HTTP


fetch : String -> Cmd Model
fetch pokemonNumber =
    Http.get
        { url = "https://pokeapi.co/api/v2/pokemon/" ++ pokemonNumber
        , expect = Http.expectJson RemoteData.fromResult pokemonDecoder
        }
