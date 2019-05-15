module Msg exposing (Msg(..))

import Browser
import Page.Pokedex as Pokedex
import Page.Pokemon as Pokemon
import Page.PokemonType as PokemonType
import Page.PokemonTypes as PokemonTypes
import Url exposing (Url)


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | PokedexFetchResponse Pokedex.Model
    | PokemonFetchResponse Pokemon.Model
    | PokemonTypesFetchResponse PokemonTypes.Model
    | PokemonTypeFetchResponse PokemonType.Model
    | SearchQueryChange String
