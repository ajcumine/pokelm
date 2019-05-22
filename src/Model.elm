module Model exposing (Base, BasePokemon, EvolutionChain, Evolutions(..), Model, Pokemon, PokemonDetail, PokemonWebData, Species, Team)

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


type alias Base =
    { name : String
    , id : Int
    }


type alias BasePokemon =
    { name : String
    , id : Int
    , types : List Base
    , speciesUrl : String
    }


type alias Species =
    { evolutionChainUrl : String
    , varieties : List Base
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
    , varieties : List Base
    }


type alias Pokemon =
    { name : String
    , id : Int
    , types : List Base
    , evolutionChain : EvolutionChain
    , varieties : List Base
    }


type alias Team =
    List Pokemon
