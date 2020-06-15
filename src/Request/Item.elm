module Request.Item exposing (..)

import Airtable
import List.NonEmpty exposing (NonEmpty)
import OptimizedDecoder as Decode exposing (Decoder)
import Pages.Secrets as Secrets
import Pages.StaticHttp as StaticHttp
import Url.Builder


type alias Item =
    { name : String
    }


type alias Variations =
    NonEmpty Variation


type alias Variation =
    { name : String
    , imageUrl : String
    , price : Float

    --, price : Int
    }


request : StaticHttp.Request (List ( Item, Variations ))
request =
    --StaticHttp.succeed []
    Airtable.staticRequest
        { viewId = "tblJUmz2eBvAcdmcy"
        , maxRecords = 100
        , airtableAccountId = "appY586DbPQTGLbiW"
        , recordType = "Items"
        , viewName = "All%20furniture"
        , decodeItem = itemDecoder
        }
        |> StaticHttp.andThen
            (\items ->
                items
                    |> List.map
                        (\item ->
                            variationsRequest item.name
                                |> StaticHttp.map (\variations -> ( item, variations ))
                        )
                    |> StaticHttp.combine
            )



--|> StaticHttp.combine


itemDecoder : Decoder Item
itemDecoder =
    Decode.map Item
        (Decode.at [ "fields", "Name" ] Decode.string)


variationsRequest : String -> StaticHttp.Request Variations
variationsRequest itemName =
    StaticHttp.request
        (Secrets.succeed
            (\airtableToken ->
                { url =
                    Url.Builder.crossOrigin "https://api.airtable.com"
                        [ "v0"
                        , "appY586DbPQTGLbiW"
                        , "Item%20Variants"
                        ]
                        [ Url.Builder.int "maxRecords" 100
                        , Url.Builder.string "view" "Grid view"
                        , Url.Builder.string "filterByFormula" <| "Item = \"" ++ itemName ++ "\""
                        ]
                , method = "GET"
                , headers = [ ( "Authorization", "Bearer " ++ airtableToken ), ( "view", "tblJUmz2eBvAcdmcy" ) ]
                , body = StaticHttp.emptyBody
                }
            )
            |> Secrets.with "AIRTABLE_TOKEN"
        )
        (Decode.field "records" variationsDecoder)


variationsDecoder : Decoder Variations
variationsDecoder =
    Decode.list variationDecoder
        |> Decode.andThen
            (\variations ->
                case List.NonEmpty.fromList variations of
                    Just okResult ->
                        Decode.succeed okResult

                    Nothing ->
                        Decode.fail "Expecting at least one item in variations"
            )


variationDecoder : Decoder Variation
variationDecoder =
    Decode.map3 Variation
        (Decode.at [ "fields", "Name" ] Decode.string)
        (Decode.at [ "fields", "Image" ] (Decode.index 0 (Decode.field "url" Decode.string)))
        --(Decode.at [ "fields", "Unit Price" ] Decode.float)
        (Decode.succeed 0)
