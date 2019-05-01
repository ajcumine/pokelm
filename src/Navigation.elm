module Navigation exposing (view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Route exposing (Route)


view : Html msg
view =
    Styled.toUnstyled <|
        Styled.nav []
            [ Styled.a
                [ Route.styledHref Route.Pokedex
                ]
                [ Styled.text "Home"
                ]
            ]
