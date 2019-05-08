module View exposing (pageContent, pageTitle, pokemon)

import Css exposing (..)
import Css.Transitions exposing (transition)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css, src)
import Route


pokemonImageSrc : Int -> String
pokemonImageSrc id =
    "/assets/images/pokemon/" ++ String.fromInt id ++ ".png"


shinyImageSrc : Int -> String
shinyImageSrc id =
    "/assets/images/shiny/" ++ String.fromInt id ++ ".png"


pokemon : String -> Int -> Styled.Html msg
pokemon name id =
    Styled.a
        [ css
            [ display inlineBlock
            , margin (px 8)
            , width (px 120)
            , height (px 160)
            , borderRadius (px 3)
            , boxShadow5 (px 0) (px 1) (px 1) (px 0) (rgba 60 64 67 0.08)
            , boxShadow5 (px 0) (px 1) (px 3) (px 1) (rgba 60 64 67 0.16)
            , paddingTop (px 16)
            , textDecoration none
            , textTransform capitalize
            , color (hex "#000000")
            , textAlign center
            , backgroundImage (url (pokemonImageSrc id))
            , backgroundPosition center
            , backgroundRepeat noRepeat
            , hover
                [ boxShadow5 (px 0) (px 1) (px 3) (px 1) (rgba 60 64 67 0.2)
                , boxShadow5 (px 0) (px 2) (px 8) (px 4) (rgba 60 64 67 0.1)
                , backgroundImage (url (shinyImageSrc id))
                ]
            , transition
                [ Css.Transitions.boxShadow3 135 0 (Css.Transitions.cubicBezier 0.4 0 0.2 1)
                , Css.Transitions.background3 135 0 (Css.Transitions.cubicBezier 0.4 0 0.2 1)
                ]
            ]
        , Route.styledHref (Route.Pokemon (String.fromInt id))
        ]
        [ Styled.span
            [ css
                [ display block
                , backgroundColor (hex "#f1f1f1")
                , padding2 (px 4) (px 0)
                ]
            ]
            [ Styled.text name ]
        ]


pageTitle : String -> Styled.Html msg
pageTitle title =
    Styled.h1
        [ css
            []
        ]
        [ Styled.text title ]


pageContent : Html msg -> Html msg
pageContent content =
    Styled.toUnstyled <|
        Styled.div
            [ css
                [ displayFlex
                , justifyContent center
                ]
            ]
            [ Styled.fromUnstyled content ]
