module Main exposing (main)

import Color
import Date
import DropdownSvg
import Feed
import FontAwesome as Fa
import Head
import Head.Seo as Seo
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Layout
import Markdown
import MenuSvg
import Metadata exposing (Metadata)
import MySitemap
import Pages exposing (images, pages)
import Pages.Directory as Directory exposing (Directory)
import Pages.Document
import Pages.ImagePath as ImagePath exposing (ImagePath)
import Pages.Manifest as Manifest
import Pages.Manifest.Category
import Pages.PagePath as PagePath exposing (PagePath)
import Pages.Platform exposing (Page)
import Pages.StaticHttp as StaticHttp
import Request.Item



-- SQUARE_TOKEN
-- SQUARE_HOST


type alias Item =
    { name : String

    --, description : String
    }


manifest : Manifest.Config Pages.PathKey
manifest =
    { backgroundColor = Just Color.white
    , categories = [ Pages.Manifest.Category.education ]
    , displayMode = Manifest.Standalone
    , orientation = Manifest.Portrait
    , description = "elm-pages Tailwind Starter"
    , iarcRatingId = Nothing
    , name = "elm-pages Tailwind Starter"
    , themeColor = Just Color.white
    , startUrl = pages.index
    , shortName = Nothing
    , sourceIcon = images.iconPng
    }


type alias Rendered =
    Html Msg


main : Pages.Platform.Program Model Msg Metadata Rendered
main =
    Pages.Platform.application
        { init = \_ -> init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , documents =
            [ markdownDocument
            ]
        , manifest = manifest
        , canonicalSiteUrl = canonicalSiteUrl
        , onPageChange = \_ -> OnPageChange
        , generateFiles = generateFiles
        , internals = Pages.internals
        }


generateFiles :
    List
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        , body : String
        }
    ->
        List
            (Result String
                { path : List String
                , content : String
                }
            )
generateFiles siteMetadata =
    [ Feed.fileToGenerate { siteTagline = siteTagline, siteUrl = canonicalSiteUrl } siteMetadata |> Ok
    , MySitemap.build { siteUrl = canonicalSiteUrl } siteMetadata |> Ok
    ]


markdownDocument : ( String, Pages.Document.DocumentHandler Metadata Rendered )
markdownDocument =
    Pages.Document.parser
        { extension = "md"
        , metadata = Metadata.decoder
        , body =
            \markdownBody ->
                Html.div [] [ Markdown.toHtml [] markdownBody ]
                    |> Ok
        }


type alias Model =
    { menuOpen : Bool
    }


init : ( Model, Cmd Msg )
init =
    ( { menuOpen = False
      }
    , Cmd.none
    )


type Msg
    = OnPageChange
    | ToggleMenu


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnPageChange ->
            ( { model | menuOpen = False }, Cmd.none )

        ToggleMenu ->
            ( { model | menuOpen = not model.menuOpen }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view :
    List ( PagePath Pages.PathKey, Metadata )
    ->
        { path : PagePath Pages.PathKey
        , frontmatter : Metadata
        }
    ->
        StaticHttp.Request
            { view : Model -> Rendered -> { title : String, body : Html Msg }
            , head : List (Head.Tag Pages.PathKey)
            }
view siteMetadata page =
    StaticHttp.map
        (\squareItems ->
            { view =
                \model viewForPage ->
                    let
                        { title, body } =
                            pageView model siteMetadata page viewForPage
                    in
                    { title = title
                    , body =
                        Layout.view model
                            ToggleMenu
                            [ itemsView squareItems ]
                    }
            , head = head page.frontmatter
            }
        )
        Request.Item.request


itemsView : List Request.Item.Item -> Html msg
itemsView items =
    items
        |> List.map itemView
        |> Html.div []


itemView item =
    Html.li []
        [ Html.text item.name
        , Html.img [ Attr.src item.imageUrl ] []
        , variationsView item
        ]


variationsView item =
    Html.div [ Attr.class "relative" ]
        [ Html.select [ Attr.class "block appearance-none w-full bg-gray-200 border border-gray-200 text-gray-700 py-3 px-4 pr-8 rounded leading-tight focus:outline-none focus:bg-white focus:border-gray-500" ]
            ((item.variations.default :: item.variations.other)
                |> List.map
                    (\variation ->
                        Html.option
                            [ -- TODO this should use SKU
                              Attr.value variation.name
                            ]
                            [ Html.text variation.name ]
                    )
            )
        , div [ class "pointer-events-none absolute inset-y-0 right-0 flex items-center px-2 text-gray-700" ]
            [ DropdownSvg.view
            ]
        ]


landingPageBody =
    [ div [ class "md:flex flex-grow" ]
        [ div [ class "md:flex-shrink-0 md:w-1/2 p-6 md:p-12 lg:p-24" ]
            []
        , div [ class "lg:w-1/2 sm:flex-shrink p-6 md:p-12 lg:p-24 text-lg" ]
            []
        ]
    ]


pageView : Model -> List ( PagePath Pages.PathKey, Metadata ) -> { path : PagePath Pages.PathKey, frontmatter : Metadata } -> Rendered -> { title : String, body : Rendered }
pageView model siteMetadata page viewForPage =
    case page.frontmatter of
        Metadata.Page metadata ->
            { title = metadata.title
            , body = Html.text ""
            }


commonHeadTags : List (Head.Tag Pages.PathKey)
commonHeadTags =
    [ Head.rssLink "/blog/feed.xml"
    , Head.sitemapLink "/sitemap.xml"
    ]


{-| <https://developer.twitter.com/en/docs/tweets/optimize-with-cards/overview/abouts-cards>
<https://htmlhead.dev>
<https://html.spec.whatwg.org/multipage/semantics.html#standard-metadata-names>
<https://ogp.me/>
-}
head : Metadata -> List (Head.Tag Pages.PathKey)
head metadata =
    commonHeadTags
        ++ (case metadata of
                Metadata.Page meta ->
                    Seo.summaryLarge
                        { canonicalUrlOverride = Nothing
                        , siteName = "elm-pages-starter"
                        , image =
                            { url = images.iconPng
                            , alt = "elm-pages logo"
                            , dimensions = Nothing
                            , mimeType = Nothing
                            }
                        , description = siteTagline
                        , locale = Nothing
                        , title = meta.title
                        }
                        |> Seo.website
           )


canonicalSiteUrl : String
canonicalSiteUrl =
    "https://elm-pages-tailwind-starter.netlify.com"


siteTagline : String
siteTagline =
    "Starter blog for elm-pages"
