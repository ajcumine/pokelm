module Model exposing (Model)

import Browser.Navigation as Nav
import Page.Pokedex as Pokedex
import Page.Pokemon as Pokemon
import Page.PokemonType as PokemonType
import Page.PokemonTypes as PokemonTypes
import RemoteData exposing (WebData)
import Route exposing (Route)


type alias Model =
    { key : Nav.Key
    , route : Route
    , pokedex : Pokedex.Model
    , pokemon : Pokemon.Model
    , pokemonTypes : PokemonTypes.Model
    , pokemonType : PokemonType.Model
    , query : String
    }
