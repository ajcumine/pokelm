module Navigation exposing (view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Route exposing (Route)


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


view : Html msg
view =
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
            [ viewNavLink Route.Pokedex "Home"
            , viewNavLink Route.Types "Types"
            ]
