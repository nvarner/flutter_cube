/*
 * Copyright 2019-2021 Zebiao Hu
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

import 'orientation.dart';

/// Represents a camera. Screen space is based on pixels displayed on the
/// physical screen being rendered to. It's different for each device. Near
/// plane space is based on aspect ratio of the screen being rendered to. Its
/// origin is at the center.
class Camera {
  Camera({
    Vector3? position,
    this.orientation = const Orientation(),
    this.fov = 60.0,
    this.near = 0.1,
    this.far = 1000,
    this.zoom = 1.0,
    this.viewportWidth = 100.0,
    this.viewportHeight = 100.0,
    this.phiMin = math.pi / 2,
    this.phiMax = math.pi,
  }) {
    if (position != null) {
      this.position = position;
    }
  }

  Vector3 initialPanPoint = Vector3(0.0, 0.0, 0.0);

  Vector3 position = Vector3(0.0, 0.0, -10.0);
  Orientation orientation;

  /// Vertical field of view, in degrees
  double fov;

  double near;
  double far;
  double zoom;
  double viewportWidth;
  double viewportHeight;

  /// Minimum angle from the z+ axis
  double phiMin;

  /// Maximum angle from the z+ axis
  double phiMax;

  double get aspectRatio => viewportWidth / viewportHeight;

  /// A point in world space that the camera is looking directly at
  Vector3 get target =>
      position + orientation.quaternion.rotated(Vector3(0.0, 0.0, 1.0));

  /// A vector parallel to the left and right edges of the near plane
  Vector3 get up => orientation.quaternion.rotated(Vector3(0.0, 1.0, 0.0));

  /// Half the height of the near plane, ie. the distance from the center to the
  /// top
  double get nearPlaneHalfHeight => near * math.tan(radians(fov) / 2.0) / zoom;

  /// The height of the near plane, ie. the distance from the bottom to the top
  double get nearPlaneHeight => nearPlaneHalfHeight * 2.0;

  /// Half the width of the near plane, ie. the distance from the center to the
  /// right side
  double get nearPlaneHalfWidth => nearPlaneHalfHeight * aspectRatio;

  /// The width of the near plane, ie. the distance from the left to the right
  double get nearPlaneWidth => nearPlaneHalfWidth * 2.0;

  /// Returns the point in near plane space corresponding to the given point in
  /// screen space
  Vector2 screen2NearPlane(Vector2 screenPoint) {
    return Vector2(
      (screenPoint.x / viewportWidth - 0.5) * nearPlaneWidth,
      ((1 - (screenPoint.y / viewportHeight)) - 0.5) * nearPlaneHeight,
    );
  }

  /// Returns the point in world space on the near plane corresponding to the
  /// given point in near plane space
  Vector3 nearPlane2World(Vector2 nearPlanePoint) {
    Vector3 cameraSpace = Vector3(nearPlanePoint.x, nearPlanePoint.y, near);
    return orientation.quaternion.rotated(cameraSpace);
  }

  /// Returns the point in world space on the near plane corresponding to the
  /// given point in screen space
  Vector3 screen2World(Vector2 screenPoint) {
    return nearPlane2World(screen2NearPlane(screenPoint));
  }

  /// Returns the point on the ground (the xz-plane) behind the given point in
  /// screen space
  Vector3 screen2Ground(Vector2 screenPoint) {
    Vector3 groundNorm = Vector3(0.0, 1.0, 0.0);
    Vector3 groundPoint = Vector3(0.0, 0.0, 0.0);

    Vector3 screenLine = screen2World(screenPoint);
    Vector3 screenLinePoint = position;

    double distance = (groundPoint - screenLinePoint).dot(groundNorm) /
        screenLine.dot(groundNorm);

    return screenLinePoint + screenLine.scaled(distance);
  }

  Matrix4 get lookAtMatrix {
    return makeViewMatrix(position, target, up);
  }

  Matrix4 get projectionMatrix {
    final double top = nearPlaneHalfHeight;
    final double bottom = -top;
    final double right = nearPlaneHalfWidth;
    final double left = -right;
    return makeFrustumMatrix(left, right, bottom, top, near, far);
  }

  /// Rotate the camera relatively by the given orientation
  void rotateRelative(Orientation dOrientation) {
    double phi = orientation.phi + dOrientation.phi;
    double theta = orientation.theta + dOrientation.theta;

    double constrainedPhi = math.min(phiMax, math.max(phiMin, phi));

    orientation = Orientation(phi: constrainedPhi, theta: theta);
  }

  /// Rotate the camera based on a mouse drag from one screen space point to
  /// another
  void dragRotate(Vector2 from, Vector2 to, [double sensitivity = 5.0]) {
    double dtheta = sensitivity * -(from.x - to.x) / viewportHeight;
    double dphi = sensitivity * -(from.y - to.y) / viewportHeight;

    rotateRelative(Orientation(phi: dphi, theta: dtheta));
  }

  /// Begin panning the camera based on the start of a mouse drag in screen
  /// space
  void startDragPan(Vector2 screen) {
    initialPanPoint = screen2Ground(screen);
  }

  /// Pan the camera based on the current position in screen space of a mouse
  /// drag
  void dragPan(Vector2 screen) {
    Vector3 point = screen2Ground(screen);
    Vector3 delta = initialPanPoint - point;
    position += delta;
  }
}
