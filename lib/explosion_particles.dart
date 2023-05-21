import 'dart:ui';

import 'package:flame/particles.dart';
import 'package:flame/timer.dart';
import 'package:flutter/material.dart';

class ExplosionParticle extends Particle {
  final double lifespan;
  final double fromRadius;
  final double toRadius;
  final Color fromColor;
  final Color toColor;
  late Color color;
  late double radius;
  double life = 0;
  late Timer timer;

  ExplosionParticle({
    this.lifespan = 3.0,
    this.fromRadius = 2.0,
    this.toRadius = 6.0,
    this.fromColor = Colors.yellowAccent,
    this.toColor = Colors.red,
  }) {
    color = fromColor;
    radius = fromRadius;
    timer = Timer(
      lifespan,
      autoStart: true,
      repeat: true,
      onTick: () {},
    );
  }

  @override
  void update(double dt) {
    timer.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset.zero,
      lerpDouble(fromRadius, toRadius, timer.progress) ?? fromRadius,
      Paint()
        ..color = (Color.lerp(fromColor, toColor, timer.progress) ?? fromColor)
            .withOpacity(1.0 - timer.progress),
    );
  }
}
