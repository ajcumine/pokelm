module Navigation exposing (view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, placeholder, src, value)
import Html.Styled.Events exposing (onInput)
import Model exposing (Model)
import Msg exposing (Msg(..))
import Page.Pokedex as Pokedex
import RemoteData exposing (WebData)
import Route exposing (Route)



--- SEARCH


isMatch : String -> Model.Pokemon -> Bool
isMatch queryString pokemon =
    String.contains (String.toLower queryString) pokemon.name


findMatches : String -> List Model.Pokemon -> List Model.Pokemon
findMatches queryString pokedex =
    List.filter (isMatch queryString) pokedex



--- VIEW


viewMatch : Model.Pokemon -> Styled.Html msg
viewMatch pokemon =
    Styled.a
        [ css
            [ display block
            , padding2 (px 8) (px 12)
            , borderTop3 (px 1) solid (hex "#f1f1f1")
            , color (hex "#000000")
            , textDecoration none
            , textTransform capitalize
            , firstOfType
                [ borderTop3 (px 2) solid (hex "#f1f1f1")
                ]
            , hover
                [ backgroundColor (hex "#f1f1f1")
                ]
            ]
        , Route.styledHref (Route.Pokemon (String.fromInt pokemon.id))
        ]
        [ Styled.text pokemon.name ]


viewSearchResults : String -> Model.Pokedex -> Styled.Html msg
viewSearchResults queryString pokedexModel =
    case pokedexModel of
        RemoteData.Success pokedex ->
            if String.isEmpty queryString then
                Styled.div [] []

            else
                Styled.div
                    [ css
                        [ position absolute
                        , width inherit
                        , backgroundColor (hex "#ffffff")
                        , boxShadow5 (px 0) (px 4) (px 10) (px -1) (rgba 0 0 0 0.2)
                        , borderRadius (px 3)
                        ]
                    ]
                    (List.map (\match -> viewMatch match) (findMatches queryString pokedex))

        _ ->
            Styled.div [] []


viewSearch : String -> Model.Pokedex -> Styled.Html Msg
viewSearch queryString pokedex =
    Styled.div
        [ css
            [ width (px 160)
            , marginRight (px 40)
            ]
        ]
        [ Styled.input
            [ placeholder "Search"
            , value queryString
            , onInput SearchQueryChange
            , css
                [ width inherit
                , padding2 (px 8) (px 12)
                , border (px 0)
                , borderRadius (px 3)
                ]
            ]
            []
        , viewSearchResults queryString pokedex
        ]


viewNavLink : Route -> String -> Styled.Html msg
viewNavLink route name =
    Styled.a
        [ css
            [ marginRight (px 20)
            , color (hex "#ffffff")
            ]
        , Route.styledHref route
        ]
        [ Styled.text name ]


view : Model -> Html Msg
view model =
    Styled.toUnstyled <|
        Styled.nav
            [ css
                [ displayFlex
                , height (px 72)
                , alignItems center
                , justifyContent flexEnd
                , backgroundColor (hex "#202124")
                , boxShadow5 (px 0) (px 4) (px 10) (px -1) (rgba 0 0 0 0.2)
                ]
            ]
            [ viewSearch model.query model.pokedex
            , viewNavLink Route.Pokedex "Home"
            , viewNavLink Route.PokemonTypes "Types"
            ]
