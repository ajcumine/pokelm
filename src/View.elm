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
            []
        , Route.styledHref (Route.Pokemon (String.fromInt id))
        ]
        [ Styled.span
            [ css
                []
            ]
            [ Styled.text name ]
        , Styled.div
            [ css
                [ backgroundImage (url (pokemonImageSrc id))
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


pageTitle : String -> Styled.Html msg
pageTitle title =
    Styled.h1
        [ css []
        ]
        [ Styled.text title ]


pageContent : Html msg -> Html msg
pageContent content =
    Styled.toUnstyled <|
        Styled.div
            [ css
                []
            ]
            [ Styled.fromUnstyled content ]
