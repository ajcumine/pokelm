module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)


type Route
    = Pokedex
    | NotFound


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Pokedex Parser.top ]


fromUrl : Url -> Route
fromUrl url =
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse parser
        |> Maybe.withDefault NotFound
