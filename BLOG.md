This document, whatever it may end up as, is to outline my journey in learning elm.

I decided to learn elm, the strongly typed, functional programming language.

### Why?

Because I've been using typescript for a year now and although I thing it's type system is fantastic for reducing bugs in your code, you're still writing javascript. I'm not saying that's bad at all, just that javascript was written to be an object oriented laguage and I've been writing it in a functional way for a few years now. Maybe it's time to use a language that was built for what I want rather than using tooling to force another language to do what I think I want.

I'm currently between projects at work and this "bench" time is used for getting skilled up for the next project, helping out internal projects, or learning new things. After two weeks building an app for our product strategy team, and another week of getting to grips with some tools for my next project, I was ready to learn something new.

A number of my colleagues had been singing the praises of elm in the past few years, and on my last trip to St Louis in 2017 for StrangeLoop conference, the elm conference was happening in the days before it where I also heard fantastic things about it.

### First Steps

So here we go, where to learn elm?

I asked some friends in the elm channel of my company's public slack whether there was some kind of standard starting point, like [create-react-app]() has almost become in React apps, for elm or whether to just use the official guide and use `elm init`. They told me:

> I'd probably go with `elm init` IMO, as it suits my own learning style to learn from the ground up. `elm init` from what I remember is great, and'll prettty much set you up with a basic Elm app. There's none of the additional tooling (Webpack, Flow/Typescript, Babel, etc) that you get with JS-based projects, so it'll take you from 0 - 100 real quick

I realised that webpack has made me sick of starting up any project from nothing. I feel like it says a lot about the modern javascript environment that we need all these extra tools just to make javascript fit what we want it to be. This realisation got me excited to use a language without all that initial start up cost.

Going to the official website [elm-lang.org](https://elm-lang.org/) and finding an up to date, official guide for learning elm.

I followed this guide and it got me going surprisingly quickly. Having editor configuration at the start of the official guide and making it so simple is fantastic. Coming from the ESLint/Prettier environments of modern javascript, this it right at the top of my priorites when picking up a new language. I'm someone who tends to self-format anyway but having a tool that teaches me this "correct" way to format my code from the start is very satisfying.

Learning about the Model - Update - View path of elm architecture reminded me of the main reason I like Redux as a state library but also about the massive amounts of boilerplate around it and how much of my own React/Redux applications are copy -> paste boilerplate code. Thankfully elm doesn't seem to have as much of this boilerplate.

I read along through guide learning about elm types, types versus type aliases, pattern matching, and error handling. I followed along with the `elm repl`. It all seemed to make sense. I made a fetch request to display a cat gif from giphy. Here I decided to start recording what I was doing and started a little git repository with this as my [first commit](https://github.com/ajcumine/pokelm/tree/0feb63134d77ddc9212ba715b41102736208bbf8).

At this point I decided to build something with what I had learnt and what I could see was coming up in this guide.

### PokElm

Feel free to skip readibg this paragraph as it's just some background info on me. I've been play the pokemon games since I was 9 when a friend from Hong Kong brought a bootleg copy of pokemon red to school. That followed with getting my own gameboy and playing every main series pokemon game in the series of and on for years. When pokemon go came out I played that too. The website [serebii.net](https://www.serebii.net/) is where I go to for any pokemon related news and it has excellent resources for the games. I wondered how they built it and if they had an public API so I had a quick look at the network requests on the site and was disappointed to see nothing I could use. So I had a little google and found [PokéAPI](https://pokeapi.co/) which allows for 100 requests per IP address per minute, more than enough for a little fun learning elm.

So I decided to build a Pokedex in elm. A pokedex is like a little encyclopedia for pokemon. It has pictures and detailed information about each one. Using the [PokéAPI](https://pokeapi.co/) I would have a single page app, routing, Http requests, JSON decoding, storing data in application state, multiple views, chained http requests. These are the basis of most web applications I have made, usually followed by user state/log in and forms. A nice little project to start with.

I followed on with the official elm guide replacing their logic with my pokemon based logic. Still using elm reactor and a Main.elm file I printed out a list of all the pokemon names ([github](https://github.com/ajcumine/pokelm/tree/52de5ce610c43a9af97d5ca5862ab75368234505)).

I then did some string parsing on the JSON pokemon url data to get the pokemon id which made me able to get an image for each pokemon and present that with the names for a very basic pokedex with some basic styling ([github](https://github.com/ajcumine/pokelm/tree/383499e5c0b03eea61600dcf95b64aaa02e21735)).
There is a little snippet of code here that I am not proud of:

```elm
getUuid : String -> String
getUuid url =
    String.split "/" url |> List.reverse |> List.tail |> Maybe.withDefault [ "1" ] |> List.head |> Maybe.withDefault "1"
```

I struggled with understanding the correct way to parse a url string and as it was the only thing blocking me I found a dirty way to handle the string and moved on. Something that I will return to at some point.

### Typed CSS (CS-YES!)

But the rest of the code was working as I would have wanted it to so I was happy at this stage. One thing I wanted to know about was styling. My current basic elm styling had no type safety, you could type whatever you wanted after `style` and so long as it was two strings, the compiler would run successfully. As far as I know `style "hot" "potato"` is not valid css.

In modern javascript we have libraries to handle this such as [styled components](). I had a look around the [elm package library](https://package.elm-lang.org/) and decided to try [elm-css](https://package.elm-lang.org/packages/rtfeldman/elm-css/latest/). This gives the css typings so my attempt at invalid css with `css [ hot potato ]` had the compiler up in arms not knowing what `hot` or `potato` were, even as strings `css [ "hot" "potato" ]` the compiler errored correctly as this was still invalid.

There were some problems though as I tried to `display flex`. As `flex` is already a css property it cannot also be an attribute, so `displayFlex` is used instead. There are similar things throughout the `elm-css` package and sometimes it takes a little digging to find out why something won't work when you think it should. There is a fallback property `property : String -> String -> Style` which allows you to give it any custom style that might be missing.

I was pretty happy with this so after converting my css over to `elm-css` moved on ([github](https://github.com/ajcumine/pokelm/tree/ddccce1a7152d4f0bce406919133378c77edd5aa)).

### Elm Application

So far I had been running my code using elm reactor and that is great, but I was at a point where I was done with the pokedex listing and wanted to make a page for each pokemon. I made a link for each pokemon to their page and then...

What now?

Well at this point in the official elm guide on Web Apps there are 4 subsections. I continued through on those converting my single Main.elm file to use `Browser.application` instead of `Browser.document` and built the url update logic. Then something happened that I did not expect, a great big section missing and a `TODO` in it's place. So far I had been muddling along this guide like a tutorial and felt a bit lost without it.

Luckily there were links to a [elm single page application example](https://github.com/rtfeldman/elm-spa-example), part of the [RealWorld example](https://github.com/gothinkster/realworld) apps, and I started pouring over the code. This is when it hit me.

I didn't some of the fundamental parts of elm. I'd been following guides thinking I understood how things worked because I had used what someone else had made work. I didn't actually understand what each line of code meant, I had just assumed I did.

We're about to go off on a little tangent here, away from the Elm Application for a while.

### Where did I do wrong?

Below are some of the things I thought I understood while starting my journey in elm but I really did not, or things I struggled with and ended up realising I had got very wrong. The reason I may have done these things could be anything, from the documentation wasn't there, to, I was tired and didn't read it properly.

#### Imports

From the very beginning of the official guide I had been importing package modules into my Main.elm and exposing everything. For example:

```elm
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
```

This meant that I could type:

```elm
viewBasePokemon : BasePokemon -> Html Msg
viewBasePokemon basePokemon =
    div
        [ style "border" "solid #ddd 1px"
        , style "margin" "4px"
        , style "padding" "8px"
        , style "display" "flex"
        , style "flex-direction" "column"
        ]
        [ span
            [ style "text-align" "center"
            , style "text-transform" "capitalize"
            ]
            [ text basePokemon.name ]
        , img
            [ src (pokemonSpriteUrl basePokemon.uuid)
            , style "align-self" "center"
            ]
            []
        ]
```

and without having to say explicitly which module each of `div`, `style`, `span`, `text`, and `src` came from. I could also just replace `div` with `a` to create a link without having to update my import statement.

But it meant that finding the documentation for each thing was very difficult as I didn't know where to look. Hunting down this documentation when I was new to elm was very frustrating.

What I learnt quickly was that you don't have to expose anything, personally now I tend not to. The instances where I do are very rare but when I do I almost never expose everything at once with `(..)`. When I added `elm-css` I started to change this and now I tend to import modules `as` something so I don't have to write so much, but then it is clear what module owns what and documentation is easy to find.

#### Function type signatures

Now this is a really odd one, because not understanding type signatures in a strongly types language is a critical failure. I'm not saying I didn't understand them at all, what I'm really saying is that the syntax took a lot of getting used to.

I'm fairly used to them now and it was really just a mental block in my head which took some time to get used to. To make sure I understood how each function worked I would look at the signature write it down on paper to make sure I understood. I'm going to use an example for Task.map2 as I use it later in the project and it was the function that helped me make sure I understood function type signatures.

In the [documentation](https://package.elm-lang.org/packages/elm/core/latest/Task#map2) for `Task.map2` we have the type signature and description of what the function does along with a small example. The type signature is what we will look at:

```elm
Task.map2 : (a -> b -> result) -> Task x a -> Task x b -> Task x result
```

I found that initially I couldn't split these function signatures apart in my head so I would often rewrite them on paper and then annotate them myself to something like the following:

```elm
Task.map2 :
            (a -> b -> result)  --- argument 1
            -> Task x a         --- argument 2
            -> Task x b         --- argument 3
            -> Task x result    --- return value
```

I will explain why I end up using `Task.map2` now so this is easier to understand. In my pokemon page I need make three `Http.get` requests to return the whole pokemon model that I need to show what I want on that page. One of these requests is dependant on the result of a previous request. All of the decoded data needs to be merged into a single pokemon record.

In order to get all this data I decided to turn my requests into `Tasks`, map the two tasks into one `Task`, then that would them be attempted.

Arguments 2, 3, and the return value of map all have a similar type signature, `Task x a`. Looking at the type [documentation](https://package.elm-lang.org/packages/elm/core/latest/Task#Task) for `Task` we can see that a `Task` will:

> resolve successfully with an `a` value or unsuccessfully with and `x` value.

This explains that argument 1, `(a -> b -> result)` is a function that maps the successful values of `a` and `b` to `result`. This is where we would construct our whole pokemon data model from our two separate data responses. Now we know what the successful return value of `map2` will be. The unsuccessful return value `x` is then whatever failure happens in either of the two tasks passed into `map2` for `Task x a` or `Task x b`.

Arguments 2 and 3 are then just the tasks that need to be passed into the `map2` function.

It seems so simple when I write it out like this on separate lines, but for some reason it took me a while to easily read and understand.

### Back to Elm Application

I had a number of problems getting the elm application to work as I wanted in the end. I ended up working with a colleague who was familiar with elm and having him explain some of the things that I was struggling with. He shared one of his personal projects with me and I used that along with his guidance and some other open source projects to get to [this point ](https://github.com/ajcumine/pokelm/tree/92b62586fd9eb737fe803581939069d5abf21de5). As you can see from the Main.elm in the code at this point, all of the update logic and model changes are handled here. All pokedex and route logic are handled in their own separate modules, with only a thin layer exposed between them.

### Page 2

I added a second page on the `/pokemon` route and had that give me the name and id of the pokemon for the route. Fairly simple so far. But I wanted more details, things that could only be provided by a series of Http.get requests chained together. This is where I started investigating [Tasks](https://package.elm-lang.org/packages/elm/core/latest/Task).

With a little help pairing with a colleague I converted my single get request into a Task and had the same visual logic but with Task based requests. This way I could add more get request tasks without having to update more core logic.

I then added two more chained requests and mapped the data out into a model I wanted using `Task.andThen` and `Task.map2`. There was even a recursive type for decoding in there which took a little bit of work but I managed to get working. With all this I had my pokemon page ready ([github](https://github.com/ajcumine/pokelm/tree/48fb0490cfd47a1ff62f508b49c3c769ac818e5f)).

### Refactoring

**TLDR:** _Don't worry about refactoring unless there's a problem to solve with it. Long files are ok in elm._

[At this point](https://github.com/ajcumine/pokelm/commit/48fb0490cfd47a1ff62f508b49c3c769ac818e5f) I had 2 seperate pages, a pokedex page and a pokemon page. I realised I needed to do some refactoring, or at least the old coding school habits started to kick in and I was itching to do some anyway. I looked across my codebase and saw long files (Pokedex.elm at almost 170 lines and Pokemon.elm at almost 300 lines), repeated code, and large view functions.

The usual things I would think of when refactoring from my background of JS/ruby are:

- splitting code into seperate files
- moving reusable view html into "Component" files
- split reused helper functions into some kind of helper library
- sort out my file structure before I have a real mess on my hands

I wrote down these questions and went on the hunt for some answers.

I found a talk from Elm Europe 2017 by the creator of elm himself[Evan Czaplicki - The life of a file](https://www.youtube.com/watch?v=XpDsk374LDE) and here are the notes I made from it around this:

- Line count doesn't matter in elm
- Split files around data structures
  - could evolution be a seperate file as it seems to be a seperate data structure?
- only expose what is needed from a module as a public api
  - "Reduce Public API: If implementation is hidden and if the public API works, the code works everywhere"
- Don't overdo it
  - "Wait until you have a problem in practice, and then solve that problem", eg "How do I make this sidebar reusable? Why do you need a reusable sidebar?"

Another talk in from Elm Europe 2017 along the same vein is [Richard Feldman - Scaling Elm Apps](https://www.youtube.com/watch?v=DoA4Txr4GUs)

Problem: code gets hard to find
Solution: make code more organised

- split large views in to helper functions to organise them better, I've done this regularly with React while making components
- rename modules to help organise your files and help them make more sense

Problem: code gets too big to fit in your head
Solution: umm...

- solve one problem at a time
- use the simplest api that works
- reduce the types as much as possible

... to be honest I couldn't make it to the end of this talk, it got quite rambly and wasn't particularly focussed. I decided rather than not really pay attention I would just move on

I spent some time reading about reusable view functions for refactoring some of my repeated code and I read a lot of elm community posts saying that "Components are objects" and not to use them. This confused me a little as I've been using components in React/Redux for a while and never thought of them as objects, luckily this [tweet](https://twitter.com/czaplic/status/903266544544878592) from Evan Czaplicki cleared things up. React's functional stateless components, or what I like to call "dumb components", are what I was thinking of and it seems like this kind of thing is ok in elm, now just where to put them.

In many React/Redux projects I've worked on there has been `/components` directory and all the "dumb" presentational components have gone here. Time for some more digging and maybe to ask some people who know more than me.

The main questions I wanted answers to were:

1. Do you split out reused components (stateless functional ones) like in React? Where would you put them?
2. When providing default/fallback data types is it better to use constructors or define the record? Is there a performance benefit to either?
3. Where would you put reused helper functions?
4. What kind of file structure would you use?

3, and 4 were mostly answered by now. Place things where makes sense when you have a problem, don't try and solve the problem before there is one. These questions result from years on modern javascript projects.

I ended up removing the empty data type so question 2 became redundant. From conversations around the topic it became clear that having a function that returns the data type is the way to go.

The answer to question 1 was to have some kind of View module which can return some styling. For a repeated but of view html to display a pokemon something like:

```elm
type alias Pokemon =
    { name : String
    , id : Int
    }

View.pokemon : Pokemon -> Html msg
View.pokemon pokemon =
    div []
        [ text (String.fromInt pokemon.id ++ ": " ++ pokemon.name) ]
```

It should be noted that something like this is only worth doing if you are reusing the same view and styling. It could even be worth narrowing down the `Pokemon` type to specific attributes so other similar models can use it.

```elm
View.pokemon : Int -> String -> Html msg
View.pokemon id name =
    div []
        [ text (String.fromInt id ++ ": " ++ name) ]
```

With all this research into refactoring in elm, it seemed like I didn't really have a problem to solve yet and that I can just keep going.