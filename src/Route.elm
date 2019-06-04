module Route exposing (Route(..), fromUrl, styledHref)

import Html.Styled
import Html.Styled.Attributes as Attr
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = NotFound
    | Pokedex
    | Pokemon String
    | PokemonTypes
    | PokemonType String
    | Team


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Pokedex Parser.top
        , Parser.map Pokemon (Parser.s "pokemon" </> Parser.string)
        , Parser.map PokemonTypes (Parser.s "types")
        , Parser.map PokemonType (Parser.s "types" </> Parser.string)
        , Parser.map Team (Parser.s "team")
        ]


styledHref : Route -> Html.Styled.Attribute msg
styledHref targetRoute =
    Attr.href (routeToString targetRoute)


fromUrl : Url -> Route
fromUrl url =
    let
        fragmentList =
            url.fragment
                |> Maybe.withDefault ""
                |> String.split "?"

        path =
            fragmentList
                |> List.head
                |> Maybe.withDefault ""

        query =
            fragmentList
                |> List.reverse
                |> List.head
    in
    { url | path = path, fragment = Nothing, query = query }
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

                PokemonTypes ->
                    [ "types" ]

                PokemonType nameOrId ->
                    [ "types", nameOrId ]

                Team ->
                    [ "team" ]
    in
    "#/" ++ String.join "/" pieces
