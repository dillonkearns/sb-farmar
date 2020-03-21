module Request.Item exposing (..)

import Json.Decode.Exploration as Decode exposing (Decoder)
import Pages.Secrets as Secrets
import Pages.StaticHttp as StaticHttp


type alias Item =
    { name : String

    --, description : String
    }


request : StaticHttp.Request (List Item)
request =
    --StaticHttp.get
    --        (Secrets.succeed "https://api.github.com/repos/dillonkearns/elm-pages")
    --        (Decode.field "stargazers_count" Decode.int)
    let
        details =
            Secrets.succeed
                (\squareToken squareHost ->
                    { url = "https://" ++ squareHost ++ "/v2/catalog/list?types=ITEM"
                    , method = "GET"
                    , headers = [ ( "Authorization", "Bearer " ++ squareToken ) ]
                    , body = StaticHttp.emptyBody
                    }
                 -- Use secrets to construct request
                )
                -- get secrets (SQUARE_TOKEN and SQUARE_HOST)
                |> Secrets.with "SQUARE_TOKEN"
                |> Secrets.with "SQUARE_HOST"
    in
    StaticHttp.request details decoder


decoder : Decoder (List Item)
decoder =
    Decode.field "objects" <|
        Decode.list <|
            Decode.map Item
                (Decode.at [ "item_data", "name" ] Decode.string)



-- Send it
-- Decode the data
{-
   {
       "objects": [
           {
               "type": "ITEM",
               "id": "ULVDF56LHRMBBAUV7YHQB5JA",
               "updated_at": "2020-03-21T01:32:02.236Z",
               "version": 1584754322236,
               "is_deleted": false,
               "present_at_all_locations": true,
               "image_id": "AW4JZGU34O7ZKPUXWLIX4WAN",
               "item_data": {
                   "name": "Raw Honey - Chaparral",
                   "description": "Foraged in the wild mountains of Santa Barbara County, this is the honey that made us famous.  Our diverse flora includes 15 varieties of buckwheat, sumac,  toyon, poppies, yerba santa,  and of course, black, purple and white sage.  This is delicious honey.  Raw and unfiltered.  Color varies depending on what flowers the bees visited.",
                   "abbreviation": "H",
                   "label_color": "e5bf00",
                   "visibility": "PRIVATE",
                   "category_id": "6LTVVJB6K4SRLGMXIVC5YLTP",
                   "variations": [
                       {
                           "type": "ITEM_VARIATION",
                           "id": "TFW4GNIHOEOAERBLDO5EXGY6",
                           "updated_at": "2020-03-21T01:32:02.236Z",
                           "version": 1584754322236,
                           "is_deleted": false,
                           "present_at_all_locations": true,
                           "item_variation_data": {
                               "item_id": "ULVDF56LHRMBBAUV7YHQB5JA",
                               "name": "12 oz.",
                               "sku": "",
                               "ordinal": 2,
                               "pricing_type": "FIXED_PRICING",
                               "price_money": {
                                   "amount": 1000,
                                   "currency": "USD"
                               }
                           }
                       },
                       {
                           "type": "ITEM_VARIATION",
                           "id": "T5RJ2GZCHOMGZB7ERDX7EYWI",
                           "updated_at": "2020-03-21T01:32:02.236Z",
                           "version": 1584754322236,
                           "is_deleted": false,
                           "present_at_all_locations": true,
                           "item_variation_data": {
                               "item_id": "ULVDF56LHRMBBAUV7YHQB5JA",
                               "name": "1.5 lb.",
                               "sku": "",
                               "ordinal": 3,
                               "pricing_type": "FIXED_PRICING",
                               "price_money": {
                                   "amount": 1800,
                                   "currency": "USD"
                               }
                           }
                       },
                       {
                           "type": "ITEM_VARIATION",
                           "id": "TPH25X64D36LDUABK5HCZMMY",
                           "updated_at": "2020-03-21T01:32:02.236Z",
                           "version": 1584754322236,
                           "is_deleted": false,
                           "present_at_all_locations": true,
                           "item_variation_data": {
                               "item_id": "ULVDF56LHRMBBAUV7YHQB5JA",
                               "name": "3 lb.",
                               "sku": "",
                               "ordinal": 4,
                               "pricing_type": "FIXED_PRICING",
                               "price_money": {
                                   "amount": 3400,
                                   "currency": "USD"
                               }
                           }
                       }
                   ],
                   "product_type": "REGULAR",
                   "skip_modifier_screen": false
               }
           },
           {
               "type": "ITEM",
               "id": "LTLXCREUR44ZJFAAMTXK3RJN",
               "updated_at": "2020-03-21T01:35:08.407Z",
               "version": 1584754508407,
               "is_deleted": false,
               "present_at_all_locations": true,
               "item_data": {
                   "name": "Hummus",
                   "visibility": "PRIVATE",
                   "variations": [
                       {
                           "type": "ITEM_VARIATION",
                           "id": "3PHGSZ6PS5T4I7DGO2YVQIBP",
                           "updated_at": "2020-03-21T01:35:08.407Z",
                           "version": 1584754508407,
                           "is_deleted": false,
                           "present_at_all_locations": true,
                           "item_variation_data": {
                               "item_id": "LTLXCREUR44ZJFAAMTXK3RJN",
                               "name": "Regular",
                               "ordinal": 1,
                               "pricing_type": "VARIABLE_PRICING"
                           }
                       }
                   ],
                   "product_type": "REGULAR",
                   "skip_modifier_screen": false
               }
           },
           {
               "type": "ITEM",
               "id": "TDIRPRPDPZOAKZ7KTQ63O3TE",
               "updated_at": "2020-03-21T01:35:18.13Z",
               "version": 1584754518130,
               "is_deleted": false,
               "present_at_all_locations": true,
               "item_data": {
                   "name": "Oranges",
                   "visibility": "PRIVATE",
                   "variations": [
                       {
                           "type": "ITEM_VARIATION",
                           "id": "WK3PY6YYO44GJCV7WFM7VBNP",
                           "updated_at": "2020-03-21T01:35:18.13Z",
                           "version": 1584754518130,
                           "is_deleted": false,
                           "present_at_all_locations": true,
                           "item_variation_data": {
                               "item_id": "TDIRPRPDPZOAKZ7KTQ63O3TE",
                               "name": "Regular",
                               "ordinal": 1,
                               "pricing_type": "VARIABLE_PRICING"
                           }
                       }
                   ],
                   "product_type": "REGULAR",
                   "skip_modifier_screen": false
               }
           }
       ]
   }
-}
