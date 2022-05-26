module Msg exposing (Msg(..))

import Browser
import Model exposing (PokedexWebData, Pokemon, PokemonTypeWebData, PokemonTypesWebData, PokemonWebData)
import Url exposing (Url)


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | PokedexFetchResponse PokedexWebData
    | PokemonFetchResponse PokemonWebData
    | PokemonTypeFetchResponse PokemonTypeWebData
    | PokemonTypesFetchResponse PokemonTypesWebData
    | SearchQueryChange String
    | AddToTeam Pokemon
    | RemoveFromTeam Pokemon
    | TeamPokemonTypeFetchResponse PokemonTypeWebData
