module Model exposing (BasePokemon, EvolutionChain, Evolutions(..), Model, Pokemon, PokemonDetail, PokemonType, PokemonWebData, Species, Team, Variety)

import Browser.Navigation as Nav
import Page.Pokedex as Pokedex
import Page.PokemonType as PokemonType
import Page.PokemonTypes as PokemonTypes
import RemoteData exposing (WebData)
import Route exposing (Route)


type alias Model =
    { key : Nav.Key
    , route : Route
    , pokedex : Pokedex.Model
    , pokemon : PokemonWebData
    , pokemonTypes : PokemonTypes.Model
    , pokemonType : PokemonType.Model
    , query : String
    , team : Team
    }


type alias PokemonWebData =
    WebData Pokemon


type alias PokemonType =
    { name : String }


type alias BasePokemon =
    { name : String
    , id : Int
    , types : List PokemonType
    , speciesUrl : String
    }


type alias Variety =
    { name : String
    , id : Int
    }


type alias Species =
    { evolutionChainUrl : String
    , varieties : List Variety
    }


type alias EvolutionChain =
    { name : String
    , id : Int
    , evolutionChain : Evolutions
    }


type Evolutions
    = Evolutions (List EvolutionChain)


type alias PokemonDetail =
    { evolutionChain : EvolutionChain
    , varieties : List Variety
    }


type alias Pokemon =
    { name : String
    , id : Int
    , types : List PokemonType
    , evolutionChain : EvolutionChain
    , varieties : List Variety
    }


type alias Team =
    List Pokemon
