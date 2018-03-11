module Tests.Axis2d
    exposing
        ( directionExample
        , flipExample
        , jsonRoundTrips
        , mirrorAcrossExample
        , moveToExample
        , originPointExample
        , placeInExample
        , relativeToExample
        , rotateAroundExample
        , translateByExample
        , xExample
        , yExample
        )

import Axis2d
import Direction2d
import Frame2d
import Geometry.Decode as Decode
import Geometry.Encode as Encode
import Geometry.Expect as Expect
import Geometry.Fuzz as Fuzz
import Point2d
import Test exposing (Test)
import Tests.Generic as Generic
import Vector2d


jsonRoundTrips : Test
jsonRoundTrips =
    Generic.jsonRoundTrips Fuzz.axis2d Encode.axis2d Decode.axis2d


xExample : Test
xExample =
    Test.test "Axis2d.x example" <|
        \() ->
            Axis2d.x
                |> Expect.axis2d
                    (Axis2d.withDirection Direction2d.x Point2d.origin)


yExample : Test
yExample =
    Test.test "Axis2d.y example" <|
        \() ->
            Axis2d.y
                |> Expect.axis2d
                    (Axis2d.withDirection Direction2d.y Point2d.origin)


originPointExample : Test
originPointExample =
    Test.test "Axis2d.originPoint example" <|
        \() ->
            Axis2d.originPoint Axis2d.x |> Expect.point2d Point2d.origin


directionExample : Test
directionExample =
    Test.test "Axis2d.direction example" <|
        \() ->
            Axis2d.direction Axis2d.y |> Expect.direction2d Direction2d.y


flipExample : Test
flipExample =
    Test.test "Axis2d.flip example" <|
        \() ->
            Axis2d.flip Axis2d.x
                |> Expect.axis2d
                    (Axis2d.withDirection Direction2d.negativeX Point2d.origin)


moveToExample : Test
moveToExample =
    Test.test "Axis2d.moveTo example" <|
        \() ->
            let
                axis =
                    Axis2d.withDirection Direction2d.y
                        (Point2d.fromCoordinates ( 2, 3 ))

                newOrigin =
                    Point2d.fromCoordinates ( 4, 5 )
            in
            Axis2d.moveTo newOrigin axis
                |> Expect.axis2d
                    (Axis2d.withDirection Direction2d.y
                        (Point2d.fromCoordinates ( 4, 5 ))
                    )


rotateAroundExample : Test
rotateAroundExample =
    Test.test "Axis2d.rotateAround example" <|
        \() ->
            Axis2d.rotateAround Point2d.origin (degrees 90) Axis2d.x
                |> Expect.axis2d Axis2d.y


translateByExample : Test
translateByExample =
    Test.test "Axis2d.translateBy example" <|
        \() ->
            let
                displacement =
                    Vector2d.fromComponents ( 2, 3 )
            in
            Axis2d.translateBy displacement Axis2d.y
                |> Expect.axis2d
                    (Axis2d.withDirection Direction2d.y
                        (Point2d.fromCoordinates ( 2, 3 ))
                    )


mirrorAcrossExample : Test
mirrorAcrossExample =
    Test.test "Axis2d.mirrorAcross example" <|
        \() ->
            let
                axis =
                    Axis2d.withDirection
                        (Direction2d.fromAngle (degrees 30))
                        (Point2d.fromCoordinates ( 1, 2 ))
            in
            Axis2d.mirrorAcross Axis2d.x axis
                |> Expect.axis2d
                    (Axis2d.withDirection
                        (Direction2d.fromAngle (degrees -30))
                        (Point2d.fromCoordinates ( 1, -2 ))
                    )


relativeToExample : Test
relativeToExample =
    Test.test "Axis2d.relativeTo example" <|
        \() ->
            let
                originPoint =
                    Point2d.fromCoordinates ( 2, 3 )
            in
            Axis2d.relativeTo (Frame2d.atPoint originPoint) Axis2d.x
                |> Expect.axis2d
                    (Axis2d.withDirection Direction2d.x
                        (Point2d.fromCoordinates ( -2, -3 ))
                    )


placeInExample : Test
placeInExample =
    Test.test "Axis2d.placeIn example" <|
        \() ->
            let
                originPoint =
                    Point2d.fromCoordinates ( 2, 3 )
            in
            Axis2d.placeIn (Frame2d.atPoint originPoint) Axis2d.x
                |> Expect.axis2d
                    (Axis2d.withDirection Direction2d.x
                        (Point2d.fromCoordinates ( 2, 3 ))
                    )
