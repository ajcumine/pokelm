module Page.Types exposing (Model, fetch, init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
import RemoteData exposing (WebData)
import Route



-- MODEL


type alias Model =
    WebData Types


type alias Types =
    List Type


type alias Type =
    { name : String
    , id : Int
    }


init : Model
init =
    RemoteData.NotAsked



-- VIEW


viewType : Type -> Styled.Html msg
viewType pokemonType =
    Styled.div
        [ css
            [ textTransform capitalize
            , width (px 72)
            ]
        ]
        [ Styled.a
            [ Route.styledHref (Route.PokemonType pokemonType.name)
            ]
            [ Styled.div
                [ css
                    [ textTransform capitalize
                    ]
                ]
                [ Styled.text pokemonType.name
                ]
            ]
        ]


viewTypes : Model -> Styled.Html msg
viewTypes model =
    case model of
        RemoteData.NotAsked ->
            Styled.text "Not Asked"

        RemoteData.Loading ->
            Styled.text "Loading Pokemon..."

        RemoteData.Failure error ->
            Styled.text "There was an error fetching your Pokemon"

        RemoteData.Success pokemonType ->
            Styled.div
                [ css
                    [ displayFlex
                    , flexWrap wrap
                    , justifyContent center
                    ]
                ]
                (List.map viewType pokemonType)


view : Model -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div
            [ css
                [ displayFlex
                , flexDirection column
                , fontFamilies [ "Verdana" ]
                , marginTop (px 40)
                ]
            ]
            [ Styled.h2
                [ css [ margin3 (px 0) auto (px 20) ] ]
                [ Styled.text "Types" ]
            , viewTypes model
            ]



-- SERIALISATION


getId : String -> Int
getId url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "0" |> String.toInt |> Maybe.withDefault 0


typeDecoder : Decoder Type
typeDecoder =
    Decode.succeed Type
        |> Pipeline.required "name" Decode.string
        |> Pipeline.required "url" (Decode.string |> Decode.map getId)


typesDecoder : Decoder (List Type)
typesDecoder =
    Decode.at [ "results" ] (Decode.list typeDecoder)



-- HTTP


fetch : Cmd Model
fetch =
    Http.get
        { url = "https://pokeapi.co/api/v2/type"
        , expect = Http.expectJson RemoteData.fromResult typesDecoder
        }
