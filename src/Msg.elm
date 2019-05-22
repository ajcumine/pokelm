module Msg exposing (Msg(..))

import Browser
import Model exposing (PokedexWebData, Pokemon, PokemonWebData)
import Page.PokemonType as PokemonType
import Page.PokemonTypes as PokemonTypes
import Url exposing (Url)


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | PokedexFetchResponse PokedexWebData
    | PokemonFetchResponse PokemonWebData
    | PokemonTypesFetchResponse PokemonTypes.Model
    | PokemonTypeFetchResponse PokemonType.Model
    | SearchQueryChange String
    | AddToTeam Pokemon
    | RemoveFromTeam Pokemon
