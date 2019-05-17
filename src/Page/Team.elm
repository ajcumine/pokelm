module Page.Team exposing (init, view)

import Css exposing (..)
import Html exposing (Html)
import Html.Styled as Styled
import Html.Styled.Attributes exposing (css)
import Model exposing (Model, Pokemon, Team)
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
