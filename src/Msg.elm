module Msg exposing (Msg(..))

import Browser
import Model exposing (PokedexWebData, Pokemon, PokemonTypeWebData, PokemonWebData)
import Page.PokemonTypes as PokemonTypes
import Url exposing (Url)


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | PokedexFetchResponse PokedexWebData
    | PokemonFetchResponse PokemonWebData
    | PokemonTypeFetchResponse PokemonTypeWebData
    | PokemonTypesFetchResponse PokemonTypes.Model
    | SearchQueryChange String
    | AddToTeam Pokemon
    | RemoveFromTeam Pokemon
