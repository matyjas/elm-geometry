--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- This Source Code Form is subject to the terms of the Mozilla Public        --
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,  --
-- you can obtain one at http://mozilla.org/MPL/2.0/.                         --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


module Plane3d exposing
    ( Plane3d
    , xy, yz, zx
    , through, withNormalDirection, throughPoints
    , originPoint, normalDirection, normalAxis
    , at, at_
    , offsetBy, reverseNormal, rotateAround, translateBy, translateIn, moveTo, mirrorAcross
    , relativeTo, placeIn
    )

{-| A `Plane3d` is an infinite flat plane in 3D. It is defined by an origin
point and normal direction and is useful for several operations including:

  - Mirroring across the plane
  - Projecting onto the plane
  - Measuring distance from the plane

@docs Plane3d


# Constants

@docs xy, yz, zx


# Constructors

@docs through, withNormalDirection, throughPoints


# Properties

@docs originPoint, normalDirection, normalAxis


# Unit conversions

@docs at, at_


# Transformations

@docs offsetBy, reverseNormal, rotateAround, translateBy, translateIn, moveTo, mirrorAcross


# Coordinate conversions

@docs relativeTo, placeIn

-}

import Angle exposing (Angle)
import Axis3d exposing (Axis3d)
import Direction3d exposing (Direction3d)
import Geometry.Types as Types exposing (Frame3d)
import Point3d exposing (Point3d)
import Quantity exposing (Quantity, Rate)
import Vector3d exposing (Vector3d)


{-| -}
type alias Plane3d units coordinates =
    Types.Plane3d units coordinates


{-| The global XY plane, centered at the origin with a normal in the positive Z
direction.

    Plane3d.xy
    --> Plane3d.through Point3d.origin Direction3d.z

-}
xy : Plane3d units coordinates
xy =
    through Point3d.origin Direction3d.z


{-| The global YZ plane, centered at the origin with a normal in the positive X
direction.

    Plane3d.yz
    --> Plane3d.through Point3d.origin Direction3d.x

-}
yz : Plane3d units coordinates
yz =
    through Point3d.origin Direction3d.x


{-| The global ZX plane, centered at the origin with a normal in the positive Y
direction.

    Plane3d.zx
    --> Plane3d.through Point3d.origin Direction3d.y

-}
zx : Plane3d units coordinates
zx =
    through Point3d.origin Direction3d.y


{-| Construct a plane through the given point, with the given normal direction.

    xyPlane =
        Plane3d.through Point3d.origin Direction3d.z

-}
through : Point3d units coordinates -> Direction3d coordinates -> Plane3d units coordinates
through givenPoint givenNormalDirection =
    Types.Plane3d
        { originPoint = givenPoint
        , normalDirection = givenNormalDirection
        }


{-| Construct a plane with the given normal direction, through the given point.
Flipped version of `through`.

    plane =
        Plane3d.withNormalDirection Direction3d.y
            (Point3d.meters 2 1 3)

-}
withNormalDirection : Direction3d coordinates -> Point3d units coordinates -> Plane3d units coordinates
withNormalDirection givenNormalDirection givenPoint =
    Types.Plane3d
        { normalDirection = givenNormalDirection
        , originPoint = givenPoint
        }


{-| Attempt to construct a plane passing through the three given points. The
origin point of the resulting plane will be equal to the first given point, and
the normal direction will be such that the three given points are in
counterclockwise order around it according to the right-hand rule. If the three
given points are collinear, returns `Nothing`.

    Plane3d.throughPoints
        (Point3d.meters 2 0 0)
        (Point3d.meters 3 0 0)
        (Point3d.meters 4 1 1)
    --> Just <|
    -->     Plane3d.through (Point3d.meters 2 0 0)
    -->         (Direction3d.yz (Angle.degrees 135))

    Plane3d.throughPoints
        (Point3d.meters 2 0 0)
        (Point3d.meters 3 0 0)
        (Point3d.meters 4 0 0)
    --> Nothing

-}
throughPoints : Point3d units coordinates -> Point3d units coordinates -> Point3d units coordinates -> Maybe (Plane3d units coordinates)
throughPoints firstPoint secondPoint thirdPoint =
    let
        firstVector =
            Vector3d.from firstPoint secondPoint

        secondVector =
            Vector3d.from secondPoint thirdPoint

        crossProduct =
            firstVector |> Vector3d.cross secondVector
    in
    Vector3d.direction crossProduct |> Maybe.map (through firstPoint)


{-| Convert a plane from one units type to another, by providing a conversion
factor given as a rate of change of destination units with respect to source
units.
-}
at : Quantity Float (Rate units2 units1) -> Plane3d units1 coordinates -> Plane3d units2 coordinates
at rate (Types.Plane3d plane) =
    Types.Plane3d
        { originPoint = Point3d.at rate plane.originPoint
        , normalDirection = plane.normalDirection
        }


{-| Convert a plane from one units type to another, by providing an 'inverse'
conversion factor given as a rate of change of source units with respect to
destination units.
-}
at_ : Quantity Float (Rate units1 units2) -> Plane3d units1 coordinates -> Plane3d units2 coordinates
at_ rate plane =
    at (Quantity.inverse rate) plane


{-| Get the origin point of a plane.

    Plane3d.originPoint Plane3d.xy
    --> Point3d.origin

-}
originPoint : Plane3d units coordinates -> Point3d units coordinates
originPoint (Types.Plane3d plane) =
    plane.originPoint


{-| Get the normal direction of a plane.

    Plane3d.normalDirection Plane3d.xy
    --> Direction3d.z

-}
normalDirection : Plane3d units coordinates -> Direction3d coordinates
normalDirection (Types.Plane3d plane) =
    plane.normalDirection


{-| Construct an axis from the origin point and normal direction of a plane.

    Plane3d.normalAxis Plane3d.zx
    --> Axis3d.y

-}
normalAxis : Plane3d units coordinates -> Axis3d units coordinates
normalAxis (Types.Plane3d plane) =
    Axis3d.through plane.originPoint plane.normalDirection


{-| Shift a plane in its own normal direction by the given (signed) distance.

    Plane3d.offsetBy (Length.meters 1) Plane3d.zx
    --> Plane3d.withNormalDirection Direction3d.y
    -->     (Point3d.meters 0 1 0)

    Plane3d.offsetBy (Length.meters -2) Plane3d.xy
    --> Plane3d.withNormalDirection Direction3d.z
    -->     (Point3d.meters 0 0 -2)

-}
offsetBy : Quantity Float units -> Plane3d units coordinates -> Plane3d units coordinates
offsetBy distance plane =
    let
        displacement =
            Vector3d.withLength distance (normalDirection plane)
    in
    translateBy displacement plane


{-| Reverse a plane's normal direction while leaving its origin point unchanged.

    Plane3d.reverseNormal Plane3d.xy
    --> Plane3d.through Point3d.origin
    -->     Direction3d.negativeZ

-}
reverseNormal : Plane3d units coordinates -> Plane3d units coordinates
reverseNormal (Types.Plane3d plane) =
    through plane.originPoint (Direction3d.reverse plane.normalDirection)


{-| Rotate a plane around an axis by a given angle.

    Plane3d.rotateAround Axis3d.y (Angle.degrees 90) Plane3d.xy
    --> Plane3d.yz

-}
rotateAround : Axis3d units coordinates -> Angle -> Plane3d units coordinates -> Plane3d units coordinates
rotateAround axis angle (Types.Plane3d plane) =
    through (Point3d.rotateAround axis angle plane.originPoint)
        (Direction3d.rotateAround axis angle plane.normalDirection)


{-| Translate a plane by a given displacement. Applies the given displacement to
the plane's origin point and leaves its normal direction unchanged.

    plane =
        Plane3d.withNormalDirection Direction3d.z
            (Point3d.meters 1 1 1)

    displacement =
        Vector3d.meters 1 2 3

    Plane3d.translateBy displacement plane
    --> Plane3d.withNormalDirection Direction3d.z
    -->     (Point3d.meters 2 3 4)

-}
translateBy : Vector3d units coordinates -> Plane3d units coordinates -> Plane3d units coordinates
translateBy vector (Types.Plane3d plane) =
    withNormalDirection plane.normalDirection
        (Point3d.translateBy vector plane.originPoint)


{-| Translate a plane in a given direction by a given distance;

    Plane3d.translateIn direction distance

is equivalent to

    Plane3d.translateBy
        (Vector3d.withLength distance direction)

-}
translateIn : Direction3d coordinates -> Quantity Float units -> Plane3d units coordinates -> Plane3d units coordinates
translateIn direction distance plane =
    translateBy (Vector3d.withLength distance direction) plane


{-| Move a plane so that it has the given origin point but unchanged normal
direction.

    newOrigin =
        Point3d.meters 1 2 3

    Plane3d.moveTo newOrigin Plane3d.xy
    --> Plane3d.through newOrigin Direction3d.z

-}
moveTo : Point3d units coordinates -> Plane3d units coordinates -> Plane3d units coordinates
moveTo newOrigin (Types.Plane3d plane) =
    through newOrigin plane.normalDirection


{-| Mirror one plane across another. The plane to mirror across is given first
and the plane to mirror is given second.

    plane =
        Plane3d.withNormalDirection Direction3d.z
            (Point3d.meters 1 2 3)

    Plane3d.mirrorAcross Plane3d.xy plane
    --> Plane3d.withNormalDirection Direction3d.negativeZ
    -->     (Point3d.meters 1 2 -3)

-}
mirrorAcross : Plane3d units coordinates -> Plane3d units coordinates -> Plane3d units coordinates
mirrorAcross otherPlane (Types.Plane3d plane) =
    through (Point3d.mirrorAcross otherPlane plane.originPoint)
        (Direction3d.mirrorAcross otherPlane plane.normalDirection)


{-| Take a plane defined in global coordinates, and return it expressed in local
coordinates relative to a given reference frame.

    referenceFrame =
        Frame3d.atPoint (Point3d.meters 1 1 1)

    plane =
        Plane3d.withNormalDirection Direction3d.z
            (Point3d.meters 0 0 2)

    Plane3d.relativeTo referenceFrame plane
    --> Plane3d.withNormalDirection Direction3d.z
    -->     (Point3d.meters -1 -1 1)

-}
relativeTo : Frame3d units globalCoordinates { defines : localCoordinates } -> Plane3d units globalCoordinates -> Plane3d units localCoordinates
relativeTo frame (Types.Plane3d plane) =
    through (Point3d.relativeTo frame plane.originPoint)
        (Direction3d.relativeTo frame plane.normalDirection)


{-| Take a plane defined in local coordinates relative to a given reference
frame, and return that plane expressed in global coordinates.

    referenceFrame =
        Frame3d.atPoint (Point3d.meters 1 1 1)

    plane =
        Plane3d.withNormalDirection Direction3d.z
            (Point3d.meters 1 2 3)

    Plane3d.placeIn referenceFrame plane
    --> Plane3d.withNormalDirection Direction3d.z
    -->     (Point3d.meters 2 3 4)

-}
placeIn : Frame3d units globalCoordinates { defines : localCoordinates } -> Plane3d units localCoordinates -> Plane3d units globalCoordinates
placeIn frame (Types.Plane3d plane) =
    through (Point3d.placeIn frame plane.originPoint)
        (Direction3d.placeIn frame plane.normalDirection)
