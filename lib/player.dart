import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/collisions.dart';

class Player extends SpriteComponent {
  moveTo(Vector2 delta) {
    position.add(delta);
  }
}

class PlayerFire extends CustomPainterComponent with CollisionCallbacks {
  Vector2 playerPos;
  late Timer timer;
  late RectangleHitbox hitBox;

  PlayerFire({
    required this.playerPos,
  }) {
    timer = Timer(
      0.02,
      autoStart: true,
      repeat: true,
      onTick: () {
        playerPos += Vector2(0.0, -5.0);
        hitBox.position += Vector2(0.0, -5.0);
        if (hitBox.position.y < 0) _removeMe();
      },
    );
    hitBox = RectangleHitbox(
      size: Vector2(5, 30),
      position: Vector2(playerPos.x, playerPos.y),
    );
    add(hitBox);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    _removeMe();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    Paint paint = Paint()..color = Colors.white;

    canvas.drawRect(Rect.fromLTWH(playerPos.x, playerPos.y, 5, 30), paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);
  }

  _removeMe() {
    removeFromParent();
    FlameAudio.play('explosion.wav', volume: 0.6);
  }
}
