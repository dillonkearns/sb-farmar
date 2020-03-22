module DropdownSvg exposing (..)

import Svg exposing (path, svg)
import Svg.Attributes exposing (class, d, viewBox)


view =
    svg [ class "fill-current h-4 w-4", viewBox "0 0 20 20" ]
        [ path [ d "M9.293 12.95l.707.707L15.657 8l-1.414-1.414L10 10.828 5.757 6.586 4.343 8z" ]
            []
        ]
