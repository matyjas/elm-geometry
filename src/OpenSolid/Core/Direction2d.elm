{- This Source Code Form is subject to the terms of the Mozilla Public License,
   v. 2.0. If a copy of the MPL was not distributed with this file, you can
   obtain one at http://mozilla.org/MPL/2.0/.

   Copyright 2016 by Ian Mackenzie
   ian.e.mackenzie@gmail.com
-}


module OpenSolid.Core.Direction2d
    exposing
        ( x
        , y
        , perpendicularTo
        , fromAngle
        , toAngle
        , angleFrom
        , angleTo
        , components
        , xComponent
        , yComponent
        , toVector
        , negate
        , times
        , dotProduct
        , crossProduct
        , rotateBy
        , mirrorAcross
        , relativeTo
        , placeIn
        , placeIn3d
        )

{-| Various functions for creating and working with `Direction2d` values. For
the examples below, assume that all OpenSolid core types have been imported
using

    import OpenSolid.Core.Types exposing (..)

and all necessary modules have been imported using the following pattern:

    import OpenSolid.Core.Direction2d as Direction2d

Examples use `==` to indicate that two expressions are equivalent, even if (due
to numerical roundoff) they might not be exactly equal.

# Constants

@docs x, y

# Constructors

The simplest way to construct a `Direction2d` value is by passing a tuple of X
and Y components to the `Direction2d` constructor, for example
`Direction2d ( 1, 0 )`. However, if you do this you must ensure that the sum of
the squares of the given components is exactly one:

    Direction2d ( 1, 0 )
    Direction2d ( 0, -1 )
    Direction2d ( 0.6, 0.8 )

are all valid but

    Direction2d ( 2, 0 )
    Direction2d ( 1, 1 )

are not.

@docs perpendicularTo

# Angles

@docs fromAngle, toAngle, angleFrom, angleTo

# Components

@docs components, xComponent, yComponent

# Vector conversion

@docs toVector

# Arithmetic

@docs negate, times, dotProduct, crossProduct

# Transformations

@docs rotateBy, mirrorAcross

# Coordinate frames

Functions for transforming directions between local and global coordinates in
different coordinate frames. Like other transformations, coordinate
transformations of directions depend only on the orientations of the relevant
frames, not the positions of their origin points.

For the examples, assume the following frames have been defined:

    upsideDownFrame =
        Frame2d
            { originPoint = Point2d.origin
            , xDirection = Direction2d.x
            , yDirection = Direction2d.negate Direction2d.y
            }

    rotatedFrame =
        Frame2d.rotateAround Point2d.origin
            (degrees 30)
            Frame2d.xy

@docs relativeTo, placeIn, placeIn3d
-}

import OpenSolid.Core.Types exposing (..)
import OpenSolid.Core.Vector2d as Vector2d


toDirection : Vector2d -> Direction2d
toDirection (Vector2d components) =
    Direction2d components


{-| The positive X direction.

    Direction2d.x == Direction2d ( 1, 0 )
-}
x : Direction2d
x =
    Direction2d ( 1, 0 )


{-| The positive Y direction.

    Direction2d.y == Direction2d ( 0, 1 )
-}
y : Direction2d
y =
    Direction2d ( 0, 1 )


{-| Construct a direction perpendicular to the given direction, by rotating the
given direction 90 degrees counterclockwise.

    Direction2d.perpendicularTo Direction2d.x ==
        Direction2d.y

    Direction2d.perpendicularTo Direction2d.y ==
        Direction2d.negate Direction2d.x
-}
perpendicularTo : Direction2d -> Direction2d
perpendicularTo =
    toVector >> Vector2d.perpendicularTo >> toDirection


{-| Construct a direction from an angle in radians, given counterclockwise from
the positive X direction.

    Direction2d.fromAngle 0 ==
        Direction2d.x

    Direction2d.fromAngle (degrees 90) ==
        Direction2d.y

    Direction2d.fromAngle (degrees -135) ==
        Direction2d ( -0.7071, -0.7071 )
-}
fromAngle : Float -> Direction2d
fromAngle angle =
    Direction2d ( cos angle, sin angle )


{-| Convert a direction to a counterclockwise angle in radians from the positive
X direction. The result will be in the range -π to π.

    Direction2d.toAngle Direction2d.x == 0
    Direction2d.toAngle Direction2d.y == pi / 2
    Direction2d.toAngle (Direction2d ( 0, -1 )) == -pi / 2
-}
toAngle : Direction2d -> Float
toAngle direction =
    let
        ( x, y ) =
            components direction
    in
        atan2 y x


{-| Find the counterclockwise angle in radians from the first direction to the
second. The result will be in the range -π to π.

    referenceDirection =
        Direction2d.fromAngle (degrees 30)

    Direction2d.angleFrom referenceDirection Direction2d.y ==
        degrees 60

    Direction2d.angleFrom referenceDirection Direction2d.x ==
        degrees -30
-}
angleFrom : Direction2d -> Direction2d -> Float
angleFrom other direction =
    atan2 (crossProduct other direction) (dotProduct other direction)


{-| Flipped version of `angleFrom`: The counterclockwise angle *to* the first
direction, *from* the second.

    direction =
        Direction2d.fromAngle (degrees 45)

    Direction2d.angleTo Direction2d.x direction ==
        degrees -45
-}
angleTo : Direction2d -> Direction2d -> Float
angleTo =
    flip angleFrom


{-| Get the components of a direction as a tuple (the components it would have
as a unit vector, also know as its direction cosines).

    ( x, y ) =
        Direction2d.components direction
-}
components : Direction2d -> ( Float, Float )
components (Direction2d components') =
    components'


{-| Get the X component of a direction.

    Direction2d.xComponent Direction2d.x == 1
    Direction2d.xComponent Direction2d.y == 0
-}
xComponent : Direction2d -> Float
xComponent =
    components >> fst


{-| Get the Y component of a direction.

    Direction2d.yComponent Direction2d.x == 0
    Direction2d.yComponent Direction2d.y == 1
-}
yComponent : Direction2d -> Float
yComponent =
    components >> snd


{-| Convert a direction to a unit vector.

    Direction2d.toVector Direction2d.x ==
        Vector2d ( 1, 0 )
-}
toVector : Direction2d -> Vector2d
toVector (Direction2d components) =
    Vector2d components


{-| Reverse a direction.

    Direction2d.negate Direction2d.y ==
        Direction2d ( 0, -1 )
-}
negate : Direction2d -> Direction2d
negate =
    toVector >> Vector2d.negate >> toDirection


{-| Construct a vector from a magnitude and a direction. If the magnitude is
negative the resulting vector will be in the opposite of the given direction.

    direction =
        Direction2d ( 0.6, 0.8 )

    Direction2d.times 2 direction ==
        Vector2d ( 1.2, 1.6 )

-}
times : Float -> Direction2d -> Vector2d
times scale =
    toVector >> Vector2d.times scale


{-| Find the dot product of two directions. This is equal to the cosine of the
angle between them.

    direction =
        Direction2d.fromAngle (degrees 60)

    Direction2d.dotProduct Direction2d.x direction == 0.5
    Direction2d.dotProduct Direction2d.x Direction2d.x == 1
    Direction2d.dotProduct Direction2d.x Direction2d.y == 0
-}
dotProduct : Direction2d -> Direction2d -> Float
dotProduct firstDirection secondDirection =
    Vector2d.dotProduct (toVector firstDirection) (toVector secondDirection)


{-| Find the cross product of two directions. This is equal to the sine of the
counterclockwise angle from the first to the second.

    direction =
        Direction2d.fromAngle (degrees 60)

    Direction2d.crossProduct Direction2d.x direction == 0.866
    Direction2d.crossProduct Direction2d.x Direction2d.x == 0
    Direction2d.crossProduct Direction2d.x Direction2d.y == 1
    Direction2d.crossProduct Direction2d.y Direction2d.x == -1
-}
crossProduct : Direction2d -> Direction2d -> Float
crossProduct firstDirection secondDirection =
    Vector2d.crossProduct (toVector firstDirection) (toVector secondDirection)


{-| Rotate a direction counterclockwise by a given angle (in radians).

    Direction2d.rotateBy (degrees 45) Direction2d.x ==
        Direction2d ( 0.7071, 0.7071 )

    Direction2d.rotateBy pi Direction2d.y ==
        Direction2d.negate Direction2d.y
-}
rotateBy : Float -> Direction2d -> Direction2d
rotateBy angle =
    toVector >> Vector2d.rotateBy angle >> toDirection


{-| Mirror a direction across a particular axis. Note that only the direction of
the axis affects the result, since directions are position-independent.

    slopedAxis =
        Axis2d
            { originPoint = Point2d ( 100, 200 )
            , direction = Direction2d.fromAngle (degrees 45)
            }

    Direction2d.mirrorAcross slopedAxis Direction2d.x ==
        Direction2d.y

    Direction2d.mirrorAcross slopedAxis Direction2d.y ==
        Direction2d.x
-}
mirrorAcross : Axis2d -> Direction2d -> Direction2d
mirrorAcross axis =
    toVector >> Vector2d.mirrorAcross axis >> toDirection


{-| Take a direction currently expressed in global coordinates and express it
relative to a given frame.

    Direction2d.relativeTo upsideDownFrame Direction2d.y ==
        Direction2d ( 0, -1 )

    Direction2d.relativeTo rotatedFrame Direction2d.x ==
        Direction2d ( 0.866, -0.5 )

    Direction2d.relativeTo rotatedFrame Direction2d.y ==
        Direction2d ( 0.5, 0.866 )
-}
relativeTo : Frame2d -> Direction2d -> Direction2d
relativeTo frame =
    toVector >> Vector2d.relativeTo frame >> toDirection


{-| Place a direction in a given frame, considering it as being expressed
relative to that frame and returning the corresponding direction in global
coordinates. Inverse of `relativeTo`.

    Direction2d.placeIn upsideDownFrame Direction2d.y ==
        Direction2d ( 0, -1 )

    Direction2d.placeIn rotatedFrame Direction2d.x ==
        Direction2d ( 0.866, 0.5 )

    Direction2d.placeIn rotatedFrame Direction2d.y ==
        Direction2d ( -0.5, 0.866 )
-}
placeIn : Frame2d -> Direction2d -> Direction2d
placeIn frame =
    toVector >> Vector2d.placeIn frame >> toDirection


{-| Convert a 2D direction to 3D by placing it in a given planar frame. This
will construct a 3D direction by taking the X and Y components of the given
direction and applying them to the X and Y basis directions of the given frame.

    direction =
        Direction2d ( 0.6, 0.8 )

    Direction2d.placeIn3d SketchPlane3d.xy direction ==
        Direction3d ( 0.6, 0.8, 0 )

    Direction2d.placeIn3d SketchPlane3d.yz direction ==
        Direction3d ( 0, 0.6, 0.8 )

    Direction2d.placeIn3d SketchPlane3d.zx direction ==
        Direction3d ( 0.8, 0, 0.6 )
-}
placeIn3d : SketchPlane3d -> Direction2d -> Direction3d
placeIn3d sketchPlane =
    toVector
        >> Vector2d.placeIn3d sketchPlane
        >> (\(Vector3d components) -> Direction3d components)
