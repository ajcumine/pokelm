module Msg exposing (Msg(..))

import Browser
import Model exposing (Pokemon)
import Page.Pokedex as Pokedex
import Page.PokemonType as PokemonType
import Page.PokemonTypes as PokemonTypes
import RemoteData exposing (WebData)
import Url exposing (Url)


type Msg
    = UrlChange Url
    | UrlRequest Browser.UrlRequest
    | PokedexFetchResponse Pokedex.Model
    | PokemonFetchResponse (WebData Pokemon)
    | PokemonTypesFetchResponse PokemonTypes.Model
    | PokemonTypeFetchResponse PokemonType.Model
    | SearchQueryChange String
    | AddToTeam Pokemon
