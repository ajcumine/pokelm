module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Http
import Page.Pokedex as Pokedex
import Page.Pokemon as Pokemon
import Route exposing (Route)
import Url exposing (Url)



-- MODEL


type alias Model =
    { key : Nav.Key
    , route : Route
    , pokedex : Pokedex.Model
    , pokemon : Pokemon.Model
    }


init : a -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    let
        route =
            Route.fromUrl url

        model =
            { key = navKey
            , route = route
            , pokedex = Pokedex.init
            , pokemon = Pokemon.init
            }

        cmd =
            fetchRouteData model route
    in
    ( model, cmd )



-- MSG


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | PokedexFetchResponse Pokedex.Model
    | PokemonFetchResponse Pokemon.Model



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlRequest urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        UrlChange url ->
            let
                route =
                    Route.fromUrl url

                cmd =
                    fetchRouteData model route
            in
            ( { model | route = route }
            , cmd
            )

        PokedexFetchResponse response ->
            ( { model | pokedex = response }
            , Cmd.none
            )

        PokemonFetchResponse response ->
            ( { model | pokemon = response }
            , Cmd.none
            )


fetchRouteData : Model -> Route -> Cmd Msg
fetchRouteData model route =
    case route of
        Route.Pokedex ->
            Pokedex.fetch |> Cmd.map PokedexFetchResponse

        Route.Pokemon number ->
            Pokemon.fetch number |> Cmd.map PokemonFetchResponse

        _ ->
            Cmd.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "PokElm"
    , body =
        [ H.div []
            [ contentView model ]
        ]
    }


contentView : Model -> Html Msg
contentView model =
    case model.route of
        Route.NotFound ->
            H.div [] [ H.text "Not Found" ]

        Route.Pokedex ->
            H.div [] [ Pokedex.view model.pokedex ]

        Route.Pokemon number ->
            H.div [] [ H.text "POKEMON PAGE" ]



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlChange = UrlChange
        , onUrlRequest = UrlRequest
        }
