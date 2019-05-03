module Navigation exposing (view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Route exposing (Route)


viewNavLink : Route -> String -> Styled.Html msg
viewNavLink route name =
    Styled.a
        [ css [ marginRight (px 20) ]
        , Route.styledHref route
        ]
        [ Styled.text name ]


view : Html msg
view =
    Styled.toUnstyled <|
        Styled.nav
            [ css
                [ displayFlex
                , height (px 60)
                , alignItems center
                ]
            ]
            [ viewNavLink Route.Pokedex "Home"
            , viewNavLink Route.Types "Types"
            ]
