module Page.Team exposing (init, view)

import Html exposing (Html)
import Html.Styled as Styled
import Model exposing (Team)
import View



--- INIT


init : Team
init =
    []



--- VIEW


view : Team -> Html msg
view model =
    Styled.toUnstyled <|
        Styled.div
            []
            (List.append
                [ View.pageTitle "Team" ]
                (List.map (\pokemon -> View.pokemon pokemon.name pokemon.id) model)
            )
