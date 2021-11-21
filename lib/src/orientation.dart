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

import 'package:vector_math/vector_math_64.dart';

class Orientation {
  // Angles are as in the mathematical conventions for spherical coordinates,
  // except that y+, not z+, is up

  /// Angle in radians from the y+ axis
  final double phi;

  /// Angle in radians from the x+ axis
  final double theta;

  const Orientation({this.phi = math.pi / 2, this.theta = 0});

  Quaternion get quaternion =>
      Quaternion.axisAngle(Vector3(1.0, 0.0, 0.0), math.pi / 2 - phi) *
      Quaternion.axisAngle(Vector3(0.0, 1.0, 0.0), theta);
}
