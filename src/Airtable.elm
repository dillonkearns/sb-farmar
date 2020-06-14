module Airtable exposing (..)

import OptimizedDecoder as Decode exposing (Decoder)
import Pages.Secrets as Secrets
import Pages.StaticHttp as StaticHttp


type alias CreatePagePayload =
    { path : List String
    , json : Decode.Value
    }


type alias Config =
    { viewId : String
    , maxRecords : Int
    , airtableAccountId : String
    , viewName : String
    , entryToRoute : Decoder (List String)
    }


staticRequest :
    { viewId : String
    , maxRecords : Int
    , airtableAccountId : String
    , viewName : String
    , decodeItem : Decoder item
    }
    -> StaticHttp.Request (List item)
staticRequest config =
    StaticHttp.request
        (Secrets.succeed
            (\airtableToken ->
                { url =
                    "https://api.airtable.com/v0/"
                        ++ config.airtableAccountId
                        ++ "/"
                        --++ config.viewName
                        ++ "Items"
                        ++ "?maxRecords="
                        ++ String.fromInt config.maxRecords
                        ++ "&view="
                        ++ config.viewName
                , method = "GET"
                , headers = [ ( "Authorization", "Bearer " ++ airtableToken ), ( "view", config.viewId ) ]
                , body = StaticHttp.emptyBody
                }
            )
            |> Secrets.with "AIRTABLE_TOKEN"
        )
        (Decode.field "records" (Decode.list config.decodeItem))
