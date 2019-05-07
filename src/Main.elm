module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Http
import Navigation
import Page.Pokedex as Pokedex
import Page.Pokemon as Pokemon
import Page.PokemonType as PokemonType
import Page.Types as Types
import RemoteData
import Route exposing (Route)
import Url exposing (Url)



-- MODEL


type alias Model =
    { key : Nav.Key
    , route : Route
    , pokedex : Pokedex.Model
    , pokemon : Pokemon.Model
    , types : Types.Model
    , pokemonType : PokemonType.Model
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
            , types = Types.init
            , pokemonType = PokemonType.init
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
    | TypesFetchResponse Types.Model
    | PokemonTypeFetchResponse PokemonType.Model



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

        TypesFetchResponse response ->
            ( { model | types = response }
            , Cmd.none
            )

        PokemonTypeFetchResponse response ->
            ( { model | pokemonType = response }
            , Cmd.none
            )


fetchRouteData : Model -> Route -> Cmd Msg
fetchRouteData model route =
    case route of
        Route.Pokedex ->
            if RemoteData.isNotAsked model.pokedex then
                Pokedex.fetch |> Cmd.map PokedexFetchResponse

            else
                Cmd.none

        Route.Pokemon nameOrId ->
            Pokemon.fetch nameOrId |> Cmd.map PokemonFetchResponse

        Route.Types ->
            if RemoteData.isNotAsked model.types then
                Types.fetch |> Cmd.map TypesFetchResponse

            else
                Cmd.none

        Route.PokemonType nameOrId ->
            PokemonType.fetch nameOrId |> Cmd.map PokemonTypeFetchResponse

        _ ->
            Cmd.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "PokElm"
    , body =
        [ H.div []
            [ Navigation.view
            , contentView model
            ]
        ]
    }


contentView : Model -> Html Msg
contentView model =
    case model.route of
        Route.NotFound ->
            H.div [] [ H.text "Not Found" ]

        Route.Pokedex ->
            H.div [] [ Pokedex.view model.pokedex ]

        Route.Pokemon id ->
            H.div [] [ Pokemon.view model.pokemon ]

        Route.Types ->
            H.div [] [ Types.view model.types ]

        Route.PokemonType id ->
            H.div [] [ PokemonType.view model.pokemonType ]



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
