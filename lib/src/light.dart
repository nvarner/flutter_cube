/*
 * Copyright 2019-2021 Zebiao Hu
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

import 'dart:ui';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart';

import 'material.dart';

class Light {
  Light({Vector3? position, Color? color, double ambient = 0.1, double diffuse = 0.8, double specular = 0.5}) {
    position?.copyInto(this.position);
    setColor(color, ambient, diffuse, specular);
  }
  final Vector3 position = Vector3(0, 0, 10);
  final Vector3 ambient = Vector3.zero();
  final Vector3 diffuse = Vector3.zero();
  final Vector3 specular = Vector3.zero();

  void setColor(Color? color, double ambient, double diffuse, double specular) {
    final Vector3 c = (color != null) ? fromColor(color) : Vector3.all(1.0);
    this.ambient.setFrom(c * ambient);
    this.diffuse.setFrom(c * diffuse);
    this.specular.setFrom(c * specular);
  }

  Color shading(Vector3 viewPosition, Vector3 fragmentPosition, Vector3 normal, Material material) {
    final Vector3 ambient = material.ambient.clone()..multiply(this.ambient);
    final Vector3 lightDir = (position - fragmentPosition)..normalize();
    final double diff = math.max(normal.dot(lightDir), 0);
    final Vector3 diffuse = (material.diffuse * diff)..multiply(this.diffuse);
    final Vector3 viewDir = (viewPosition - fragmentPosition)..normalize();
    final Vector3 reflectDir = (-lightDir) - normal * (2 * normal.dot(-lightDir));
    final double spec = math.pow(math.max(viewDir.dot(reflectDir), 0.0), material.shininess) as double;
    final Vector3 specular = (material.specular * spec)..multiply(this.specular);
    ambient
      ..add(diffuse)
      ..add(specular)
      ..clampScalar(0.0, 1.0);
    return toColor(ambient, material.opacity);
  }
}
