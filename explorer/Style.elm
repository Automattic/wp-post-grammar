module Style exposing (..)

import Css exposing (..)
import Css.Elements exposing (body)
import Css.Namespace exposing (namespace)
import Html.CssHelpers exposing (withNamespace)
import List exposing (append)


{ class } =
    withNamespace ns
ns : String
ns =
    "wppg"


type CssClasses
    = GrammarPane
    | InputPane
    | Layout
    | NoHighlight
    | OutputPane
    | ParseBad
    | ParseGood


css : Stylesheet
css =
    (stylesheet << namespace ns)
        [ body
            [ overflow hidden
            ]
        , (.) InputPane inputPane
        , (.) Layout layout
        , (.) NoHighlight
            [ noHighlight
            , descendants [ everything [ noHighlight ] ]
            ]
        , (.) OutputPane outputPane
        , (.) ParseBad [ color red ]
        , (.) ParseGood [ color green ]
        ]


red : Color
red =
    rgb 200 0 0


green : Color
green =
    rgb 0 128 0


inputPane : List Mixin
inputPane =
    [ width (pct 95)
    , height (pct 100)
    , padding (em 1)
    , fontFamily monospace
    , fontSize (px 16)
    ]


layout : List Mixin
layout =
    [ displayFlex
    , flexDirection row
    , fontFamily monospace
    , fontSize (px 16)
    ]


outputPane : List Mixin
outputPane =
    [ height (pct 90)
    , overflow scroll
    , padding (em 1)
    ]


noHighlight : Mixin
noHighlight =
    mixin
        [ color <| rgb 208 208 208
        ]
