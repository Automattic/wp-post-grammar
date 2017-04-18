port module Explorer exposing (..)

import Html exposing (code, div, pre, text, textarea)
import Html.Attributes exposing (style)
import Html.Attributes.Extra exposing (innerHtml)
import Html.Events exposing (onInput)
import Style exposing (class, CssClasses(..))


port submitPost : String -> Cmd msg


port receiveParse : (String -> msg) -> Sub msg


type Msg
    = UpdateInput String
    | ReceiveParse String


type ParseStatus
    = ParseGood
    | ParseBad


type alias Model =
    { input : String
    , parse : String
    , status : ParseStatus
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateInput input ->
            ( { model
                | input = input
                , status = ParseBad
              }
            , submitPost input
            )

        ReceiveParse parse ->
            case parse of
                "" ->
                    ( { model | status = ParseBad }, Cmd.none )

                _ ->
                    ( { model | parse = parse, status = ParseGood }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    receiveParse ReceiveParse


statusMessage : ParseStatus -> Html.Html Msg
statusMessage status =
    case status of
        ParseGood ->
            div [ class [ ParseGood ] ] [ text "Complete parse" ]

        ParseBad ->
            div [ class [ ParseBad ] ] [ text "No valid parse" ]


highlightClass : ParseStatus -> List CssClasses
highlightClass status =
    case status of
        ParseGood ->
            []

        ParseBad ->
            [ NoHighlight ]


view : Model -> Html.Html Msg
view { input, parse, status } =
    div
        [ class [ Layout ] ]
        [ div
            [ style
                [ ( "flex", "1 0 0" )
                , ( "min-width", "50%" )
                ]
            ]
            [ textarea
                [ class [ InputPane ]
                , onInput UpdateInput
                ]
                [ text input ]
            ]
        , div
            [ style
                [ ( "flex", "1 0 0" )
                ]
            ]
            [ div [] [ statusMessage status ]
            , pre
                [ highlightClass status
                    |> List.append
                        [ OutputPane
                        ]
                    |> class
                ]
                [ code [ innerHtml parse ] [] ]
            ]
        ]


main : Program Never Model Msg
main =
    Html.program
        { init = ( Model initialInput "" ParseBad, submitPost initialInput )
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


initialInput : String
initialInput =
    """<!-- wp:core/text id="a98b469" data='{"version":1.0,"name":"wp-post-grammar","deps":["a","b",{"name":"c","devOnly":true}]}' -->
Content
<!-- /wp -->

### Text
<!-- wp:text -->
The quick brown fox jumps over the lazy dog.
<!-- /wp -->

<!-- wp:text -->
<p>The quick brown fox jumps over the lazy dog.</p>
<!-- /wp -->

<!-- wp:text -->
<p style="text-align: right;">The quick brown fox jumps over the lazy dog.</p>
<!-- /wp -->

### Image
<!-- wp:image -->
<img class="" src="/">
<!-- /wp -->

<!-- wp:image -->
<figure class="">
  <img src="/">
</figure>
<!-- /wp -->

### Image with caption
<!-- wp:image -->
[caption]<img src="/"> A picture is worth a thousand words.[/caption]
<!-- /wp -->

<!-- wp:image -->
<figure>
  <img src="/">
  <figcaption>A picture is worth a thousand words.</figcaption>
</figure>
<!-- /wp -->

### Quote
<!-- wp:quote -->
<blockquote>
  <p>The quick brown fox jumps over the lazy dog.</p>
  <footer>by Author</footer>
</blockquote>
<!-- /wp -->

### HTML
<!-- wp:html -->
<div class="custom-stuff">
  <canvas></canvas>
  <p>Look, Ma, canvas!</p>
</div>
<!-- /wp -->"""
