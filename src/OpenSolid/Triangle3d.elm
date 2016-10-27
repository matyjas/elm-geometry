{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module OpenSolid.Triangle3d
    exposing
        ( vertices
        , edges
        , map
        , scaleAbout
        , rotateAround
        , translateBy
        , mirrorAcross
        , projectOnto
        , projectInto
        , area
        , centroid
        , boundingBox
        )

import OpenSolid.Geometry.Types exposing (..)
import OpenSolid.Vector3d as Vector3d
import OpenSolid.Point3d as Point3d


vertices : Triangle3d -> ( Point3d, Point3d, Point3d )
vertices (Triangle3d vertices') =
    vertices'


edges : Triangle3d -> ( LineSegment3d, LineSegment3d, LineSegment3d )
edges triangle =
    let
        ( p1, p2, p3 ) =
            vertices triangle
    in
        ( LineSegment3d ( p1, p2 )
        , LineSegment3d ( p2, p3 )
        , LineSegment3d ( p3, p1 )
        )


map : (Point3d -> Point3d) -> Triangle3d -> Triangle3d
map function triangle =
    let
        ( p1, p2, p3 ) =
            vertices triangle
    in
        Triangle3d ( function p1, function p2, function p3 )


scaleAbout : Point3d -> Float -> Triangle3d -> Triangle3d
scaleAbout centerPoint scale =
    map (Point3d.scaleAbout centerPoint scale)


rotateAround : Axis3d -> Float -> Triangle3d -> Triangle3d
rotateAround axis angle =
    map (Point3d.rotateAround axis angle)


translateBy : Vector3d -> Triangle3d -> Triangle3d
translateBy vector =
    map (Point3d.translateBy vector)


mirrorAcross : Plane3d -> Triangle3d -> Triangle3d
mirrorAcross plane =
    map (Point3d.mirrorAcross plane)


projectOnto : Plane3d -> Triangle3d -> Triangle3d
projectOnto plane =
    map (Point3d.projectOnto plane)


projectInto : SketchPlane3d -> Triangle3d -> Triangle2d
projectInto sketchPlane triangle =
    let
        ( p1, p2, p3 ) =
            vertices triangle

        project =
            Point3d.projectInto sketchPlane
    in
        Triangle2d ( project p1, project p2, project p3 )


area : Triangle3d -> Float
area triangle =
    let
        ( p1, p2, p3 ) =
            vertices triangle

        firstVector =
            Point3d.vectorFrom p1 p2

        secondVector =
            Point3d.vectorFrom p1 p3
    in
        0.5 * Vector3d.length (Vector3d.crossProduct firstVector secondVector)


centroid : Triangle3d -> Point3d
centroid triangle =
    let
        ( p1, p2, p3 ) =
            vertices triangle

        firstVector =
            Point3d.vectorFrom p1 p2

        secondVector =
            Point3d.vectorFrom p1 p3

        displacement =
            Vector3d.times (1.0 / 3.0) (Vector3d.plus secondVector firstVector)
    in
        Point3d.translateBy displacement p1


boundingBox : Triangle3d -> BoundingBox3d
boundingBox triangle =
    let
        ( p1, p2, p3 ) =
            vertices triangle

        ( x1, y1, z1 ) =
            Point3d.coordinates p1

        ( x2, y2, z2 ) =
            Point3d.coordinates p2

        ( x3, y3, z3 ) =
            Point3d.coordinates p3
    in
        BoundingBox3d
            { minX = min x1 (min x2 x3)
            , maxX = max x1 (max x2 x3)
            , minY = min y1 (min y2 y3)
            , maxY = max y1 (max y2 y3)
            , minZ = min z1 (min z2 z3)
            , maxZ = max z1 (max z2 z3)
            }
