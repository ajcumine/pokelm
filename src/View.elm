module View exposing (pokemon)

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
            [ displayFlex
            , flexDirection column
            , padding (px 8)
            , margin (px 4)
            , border3 (px 1) solid (hex "#ddd")
            , textDecoration none
            , color (hex "#000")
            , width (px 100)
            , height (px 120)
            ]
        , Route.styledHref (Route.Pokemon (String.fromInt id))
        ]
        [ Styled.span
            [ css
                [ textAlign center
                , textTransform capitalize
                , textDecoration none
                ]
            ]
            [ Styled.text name ]
        , Styled.div
            [ css
                [ alignSelf center
                , width (px 96)
                , height (px 96)
                , backgroundImage (url (pokemonImageSrc id))
                , backgroundSize contain
                , backgroundPosition center
                , backgroundRepeat noRepeat
                , transition
                    [ Css.Transitions.background 500
                    ]
                , hover
                    [ backgroundImage (url (shinyImageSrc id))
                    ]
                ]
            ]
            []
        ]
