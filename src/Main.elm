module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html as H exposing (Html)
import Http
import Model exposing (Model, Pokemon, PokemonTypeWebData, Team)
import Msg exposing (Msg(..))
import Navigation
import Page.Pokedex as Pokedex
import Page.Pokemon as Pokemon
import Page.PokemonType as PokemonType
import Page.PokemonTypes as PokemonTypes
import Page.Team as Team
import RemoteData
import Route exposing (Route)
import Url exposing (Url)
import View


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
            , pokemonTypes = PokemonTypes.init
            , pokemonType = PokemonType.init
            , query = ""
            , team = Team.init
            }

        cmd =
            Cmd.batch
                [ fetchRouteData model route
                , Pokedex.fetch |> Cmd.map PokedexFetchResponse -- fetch pokedex for search
                ]
    in
    ( model, cmd )



-- UPDATE


addPokemonToTeam : Team -> Pokemon -> Team
addPokemonToTeam team pokemon =
    { team | members = List.append team.members [ pokemon ] }


removePokemonFromTeam : Team -> Pokemon -> Team
removePokemonFromTeam team pokemon =
    { team | members = List.filter (\member -> member /= pokemon) team.members }


addPokemonTypeToTeam : Team -> PokemonTypeWebData -> Team
addPokemonTypeToTeam team pokemonTypeWebData =
    case pokemonTypeWebData of
        RemoteData.Success pokemonType ->
            { team | pokemonTypes = List.append team.pokemonTypes [ pokemonType ] }

        _ ->
            team


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
            ( { model | route = route, query = "" }
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

        PokemonTypesFetchResponse response ->
            ( { model | pokemonTypes = response }
            , Cmd.none
            )

        PokemonTypeFetchResponse response ->
            ( { model | pokemonType = response }
            , Cmd.none
            )

        SearchQueryChange query ->
            ( { model | query = query }
            , Cmd.none
            )

        AddToTeam pokemon ->
            ( { model | team = addPokemonToTeam model.team pokemon }
            , Cmd.none
            )

        RemoveFromTeam pokemon ->
            ( { model | team = removePokemonFromTeam model.team pokemon }
            , Cmd.none
            )

        TeamPokemonTypeFetchResponse pokemonType ->
            ( { model | team = addPokemonTypeToTeam model.team pokemonType }
            , Cmd.none
            )


fetchRouteData : Model -> Route -> Cmd Msg
fetchRouteData model route =
    case route of
        Route.Pokemon nameOrId ->
            Pokemon.fetch nameOrId |> Cmd.map PokemonFetchResponse

        Route.PokemonTypes ->
            if RemoteData.isNotAsked model.pokemonTypes then
                PokemonTypes.fetch |> Cmd.map PokemonTypesFetchResponse

            else
                Cmd.none

        Route.PokemonType nameOrId ->
            PokemonType.fetch nameOrId |> Cmd.map PokemonTypeFetchResponse

        Route.Team ->
            Team.fetch model.team |> Cmd.map TeamPokemonTypeFetchResponse

        _ ->
            Cmd.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "PokElm"
    , body =
        [ H.div []
            [ Navigation.view model
            , View.pageContent (contentView model)
            ]
        ]
    }


contentView : Model -> Html Msg
contentView model =
    case model.route of
        Route.NotFound ->
            H.text "Not Found"

        Route.Pokedex ->
            Pokedex.view model.pokedex

        Route.Pokemon id ->
            Pokemon.view model.pokemon model.team.members

        Route.PokemonTypes ->
            PokemonTypes.view model.pokemonTypes

        Route.PokemonType id ->
            PokemonType.view model.pokemonType

        Route.Team ->
            Team.view model.team



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
