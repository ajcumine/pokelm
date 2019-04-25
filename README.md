# PokElm

run `elm reactor`

```
        , div
            [ css
                [ alignSelf center
                , width (px 96)
                , height (px 96)
                , backgroundImage (url (pokemonSpriteUrl pokemon.uuid))
                , transition
                    [ Css.Transitions.background 500
                    ]
                , hover
                    [ backgroundImage (url (pokemonShinySpriteUrl pokemon.uuid))
                    ]
                ]
            ]
            []
        ]
```
