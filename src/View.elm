module View exposing (pageContent, pageTitle, pokemon, pokemonType, subTitle)

import Css exposing (..)
import Css.Transitions exposing (transition)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Route


pokemonImageSrc : Int -> String
pokemonImageSrc id =
    "assets/images/pokemon/" ++ String.fromInt id ++ ".png"


shinyImageSrc : Int -> String
shinyImageSrc id =
    "assets/images/shiny/" ++ String.fromInt id ++ ".png"


pokemon : String -> Int -> Styled.Html msg
pokemon name id =
    Styled.a
        [ css
            [ display block
            , margin (px 8)
            , width (px 120)
            , height (px 160)
            , borderRadius (px 3)
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
                [ boxShadow5 (px 0) (px 2) (px 8) (px 4) (rgba 60 64 67 0.1)
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
            [ textAlign center
            , textTransform capitalize
            ]
        ]
        [ Styled.text title ]


subTitle : String -> Styled.Html msg
subTitle text =
    Styled.h2
        [ css
            [ textAlign center
            , textTransform capitalize
            ]
        ]
        [ Styled.text text ]


pageContent : Html msg -> Html msg
pageContent content =
    Styled.toUnstyled <|
        Styled.div
            [ css
                [ displayFlex
                , justifyContent center
                , marginTop (px 40)
                , marginBottom (px 60)
                ]
            ]
            [ Styled.fromUnstyled content ]


typeColor : String -> String
typeColor typeName =
    case typeName of
        "normal" ->
            "#A8A77A"

        "fire" ->
            "#EE8130"

        "water" ->
            "#6390F0"

        "electric" ->
            "#F7D02C"

        "grass" ->
            "#7AC74C"

        "ice" ->
            "#96D9D6"

        "fighting" ->
            "#C22E28"

        "poison" ->
            "#A33EA1"

        "ground" ->
            "#E2BF65"

        "flying" ->
            "#A98FF3"

        "psychic" ->
            "#F95587"

        "bug" ->
            "#A6B91A"

        "rock" ->
            "#B6A136"

        "ghost" ->
            "#735797"

        "dragon" ->
            "#6F35FC"

        "dark" ->
            "#705746"

        "steel" ->
            "#B7B7CE"

        "fairy" ->
            "#D685AD"

        _ ->
            "#000000"


pokemonType : String -> Styled.Html msg
pokemonType typeName =
    Styled.a
        [ Route.styledHref (Route.PokemonType typeName)
        , css
            [ backgroundColor (hex (typeColor typeName ++ "80"))
            , display block
            , margin (px 8)
            , width (px 120)
            , padding2 (px 12) (px 16)
            , textAlign center
            , textTransform uppercase
            , textDecoration none
            , color (hex "#000000")
            , borderRadius (px 3)
            , boxShadow5 (px 0) (px 1) (px 3) (px 1) (rgba 60 64 67 0.16)
            , hover
                [ backgroundColor (hex (typeColor typeName ++ "95"))
                , boxShadow5 (px 0) (px 2) (px 8) (px 4) (rgba 60 64 67 0.1)
                ]
            , transition
                [ Css.Transitions.backgroundColor3 135 0 (Css.Transitions.cubicBezier 0.4 0 0.2 1)
                , Css.Transitions.background3 135 0 (Css.Transitions.cubicBezier 0.4 0 0.2 1)
                ]
            ]
        ]
        [ Styled.div []
            [ Styled.text typeName
            ]
        ]
