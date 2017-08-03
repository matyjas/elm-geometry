module OpenSolid.Rectangle2d
    exposing
        ( area
          --, boundingBox
        , axes
        , centerPoint
        , containing
        , contains
        , dimensions
        , edges
        , in_
          --, interpolate
          --, mirrorAcross
          --, placeIn
          --, placeOnto
          --, point
          --, relativeTo
        , rotateAround
          --, scaleAbout
          --, translateBy
        , vertices
        , with
        )

import OpenSolid.Frame2d as Frame2d
import OpenSolid.Geometry.Types exposing (..)
import OpenSolid.Point2d as Point2d


in_ : Frame2d -> { minX : Float, maxX : Float, minY : Float, maxY : Float } -> Rectangle2d
in_ frame { minX, maxX, minY, maxY } =
    let
        width =
            maxX - minX

        height =
            maxY - minY

        midX =
            minX + 0.5 * width

        midY =
            minY + 0.5 * height

        centerPoint =
            Point2d.in_ frame ( midX, midY )
    in
    Rectangle2d
        { centeredOn = Frame2d.at centerPoint
        , dimensions = ( width, height )
        }


containing : Point2d -> Point2d -> Rectangle2d
containing firstPoint secondPoint =
    let
        centerPoint =
            Point2d.midpoint firstPoint secondPoint

        ( x1, y1 ) =
            Point2d.coordinates firstPoint

        ( x2, y2 ) =
            Point2d.coordinates secondPoint
    in
    Rectangle2d
        { centeredOn = Frame2d.at centerPoint
        , dimensions = ( abs (x2 - x1), abs (y2 - y1) )
        }


with : { minX : Float, maxX : Float, minY : Float, maxY : Float } -> Rectangle2d
with { minX, maxX, minY, maxY } =
    let
        width =
            maxX - minX

        height =
            maxY - minY

        midX =
            minX + 0.5 * width

        midY =
            minY + 0.5 * height

        centerPoint =
            Point2d ( midX, midY )
    in
    Rectangle2d
        { centeredOn = Frame2d.at centerPoint
        , dimensions = ( width, height )
        }


axes : Rectangle2d -> Frame2d
axes (Rectangle2d { centeredOn }) =
    centeredOn


centerPoint : Rectangle2d -> Point2d
centerPoint rectangle =
    Frame2d.originPoint (axes rectangle)


dimensions : Rectangle2d -> ( Float, Float )
dimensions (Rectangle2d { dimensions }) =
    dimensions


area : Rectangle2d -> Float
area rectangle =
    let
        ( width, height ) =
            dimensions rectangle
    in
    width * height


vertices : Rectangle2d -> ( Point2d, Point2d, Point2d, Point2d )
vertices rectangle =
    let
        frame =
            axes rectangle

        ( width, height ) =
            dimensions rectangle

        halfWidth =
            width / 2

        halfHeight =
            height / 2
    in
    ( Point2d.in_ frame ( -halfWidth, -halfHeight )
    , Point2d.in_ frame ( halfWidth, -halfHeight )
    , Point2d.in_ frame ( halfWidth, halfHeight )
    , Point2d.in_ frame ( -halfWidth, halfHeight )
    )


contains : Point2d -> Rectangle2d -> Bool
contains point rectangle =
    let
        frame =
            axes rectangle

        ( width, height ) =
            dimensions rectangle

        ( x, y ) =
            Point2d.coordinates (Point2d.relativeTo frame point)
    in
    abs x <= width / 2 && abs y <= height / 2


edges : Rectangle2d -> ( LineSegment2d, LineSegment2d, LineSegment2d, LineSegment2d )
edges rectangle =
    let
        ( p1, p2, p3, p4 ) =
            vertices rectangle
    in
    ( LineSegment2d ( p1, p2 )
    , LineSegment2d ( p2, p3 )
    , LineSegment2d ( p3, p4 )
    , LineSegment2d ( p4, p1 )
    )


rotateAround : Point2d -> Float -> Rectangle2d -> Rectangle2d
rotateAround point angle =
    let
        rotateFrame =
            Frame2d.rotateAround point angle
    in
    \rectangle ->
        Rectangle2d
            { centeredOn = rotateFrame (axes rectangle)
            , dimensions = dimensions rectangle
            }
