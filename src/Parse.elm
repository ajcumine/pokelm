module Parse exposing (idFromPokeApiUrlString)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


parser : Parser (Int -> a) a
parser =
    Parser.oneOf
        [ Parser.s "api" </> Parser.s "v2" </> Parser.s "pokemon-species" </> Parser.int
        , Parser.s "api" </> Parser.s "v2" </> Parser.s "type" </> Parser.int
        , Parser.s "api" </> Parser.s "v2" </> Parser.s "pokemon" </> Parser.int
        ]


urlFromString : String -> Url
urlFromString urlString =
    urlString
        |> Url.fromString
        |> Maybe.withDefault
            { protocol = Url.Https
            , host = "pokeapi.co"
            , port_ = Nothing
            , path = "/api/v2/pokemon-species/132/"
            , query = Nothing
            , fragment = Nothing
            }


idFromPokeApiUrlString : String -> Int
idFromPokeApiUrlString urlString =
    urlString
        |> urlFromString
        |> Parser.parse parser
        |> Maybe.withDefault 132
