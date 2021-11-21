/*
 * Copyright 2021 Nathan Varner
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:math' as math;

import 'package:flutter_cube/flutter_cube.dart';
import 'package:flutter_cube/src/orientation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("Camera", () {
    test("Screen to near plane simple", () {
      Camera camera = Camera(
        viewportWidth: 10,
        viewportHeight: 10,
      );

      expect(camera.screen2NearPlane(Vector2(5, 5)), Vector2(0, 0));
      expect(camera.screen2NearPlane(Vector2(0, 0)), Vector2(-camera.nearPlaneHalfWidth, -camera.nearPlaneHalfHeight));
    });

    test("Screen to near plane aspect ratio", () {
      Camera camera = Camera(
        viewportWidth: 10,
        viewportHeight: 1,
      );

      expect(camera.screen2NearPlane(Vector2(5, 0.5)), Vector2(0, 0));
      expect(camera.screen2NearPlane(Vector2(0, 0)), Vector2(-camera.nearPlaneHalfWidth, -camera.nearPlaneHalfHeight));
    });

    test("Near plane to world simple", () {
      Camera camera = Camera(
        position: Vector3(0.0, 0.0, 0.0),
        orientation: Orientation(),
        near: 0.1,
      );

      expect(camera.nearPlane2World(Vector2(0.0, 0.0)), Vector3(0.0, 0.0, 0.1));
    });

    test("Near plane to world rotated", () {
      Camera camera = Camera(
        position: Vector3(0.0, 0.0, 0.0),
        orientation: Orientation(theta: math.pi * 0.5),
        near: 0.9,
      );

      Vector3 actual = camera.nearPlane2World(Vector2(0.0, 0.0));
      Vector3 expected = Vector3(-0.9, 0.0, 0);
      expect(actual.x - expected.x < 0.001, true);
      expect(actual.y - expected.y < 0.001, true);
      expect(actual.z - expected.z < 0.001, true);
    });

    test("Screen to ground", () {
      Camera camera = Camera(
        position: Vector3(0.0, 10.0, 0.0),
        orientation: Orientation(phi: -math.pi / 2),
        viewportWidth: 10,
        viewportHeight: 10,
      );
      
      Vector3 expected = camera.screen2Ground(Vector2(5, 5));
      Vector3 actual = Vector3(0.0, 0.0, 0.0);
      expect(actual.x - expected.x < 0.001, true);
      expect(actual.y - expected.y < 0.001, true);
      expect(actual.z - expected.z < 0.001, true);
    });
  });
}