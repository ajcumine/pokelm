module Route exposing (Route(..), fromUrl, styledHref)

import Html.Styled
import Html.Styled.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = NotFound
    | Pokedex
    | Pokemon String
    | Types


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Pokedex Parser.top
        , Parser.map Pokemon (Parser.s "pokemon" </> Parser.string)
        , Parser.map Types (Parser.s "types")
        ]


styledHref : Route -> Html.Styled.Attribute msg
styledHref targetRoute =
    Attr.href (routeToString targetRoute)


fromUrl : Url -> Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser
        |> Maybe.withDefault NotFound


routeToString : Route -> String
routeToString route =
    let
        pieces =
            case route of
                NotFound ->
                    [ "404" ]

                Pokedex ->
                    []

                Pokemon nameOrId ->
                    [ "pokemon", nameOrId ]

                Types ->
                    [ "types" ]
    in
    "#/" ++ String.join "/" pieces
