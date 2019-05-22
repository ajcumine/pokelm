module Page.Team exposing (init, view)

import Html exposing (Html)
import Html.Styled as Styled
import Model exposing (Pokemon, Team)
import RemoteData exposing (WebData)
import View



--- INIT


init : Team
init =
    { members = []
    , pokemonTypes = []
    }



--- VIEW


viewTeamMembers : List Pokemon -> Styled.Html msg
viewTeamMembers members =
    Styled.div
        []
        (List.map (\pokemon -> View.pokemon pokemon.name pokemon.id) members)


view : Team -> Html msg
view team =
    Styled.toUnstyled <|
        Styled.div
            []
            [ View.pageTitle "Team"
            , viewTeamMembers team.members
            ]
