import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flutter/material.dart';

const int nAliens = 40;

typedef AlienRecord = ({Alien alien, bool isVisible});

class Aliens {
  final Sprite alienSprite;
  final Function(int index) onHit;
  late List<AlienRecord> aliens;
  int dx = 1;

  Aliens(this.alienSprite, Vector2 gameSize, this.onHit) {
    aliens = List.generate(nAliens, (index) {
      Alien a = Alien(
        index: index,
        onHit: (index) => onHit(index),
      )
        ..position = Vector2(0, 0)
        ..size = Vector2(0, 0)
        ..sprite = alienSprite
        ..anchor = Anchor.topLeft;

      return (alien: a, isVisible: true);
    });
    for (int i = 0; i < aliens.length; ++i) {
      setSizePos(i, gameSize);
    }
  }

  setSizePos(int index, Vector2 gameSize) {
    double width = gameSize.x / 20;
    double height = width * 0.75;
    int row = index ~/ 10;
    int col = index % 10;
    aliens[index].alien.position = Vector2((width * 1.25) * col, (height * 1.3) * row);
    aliens[index].alien.size = Vector2(width, height);
  }

  /// step forward aliens when tick occurs
  bool stepForward(Vector2 gameSize) {
    Rect aliensBoundaries = boundaries();
    bool newLineCycle = false;
    // shift by half the sprite width
    double shift = aliens[0].alien.width * 0.5;
    if (aliensBoundaries.left + aliensBoundaries.width + shift * dx >
        gameSize.x) {
      dx *= -1;
    }
    if (aliensBoundaries.left + shift * dx < 0) {
      dx *= -1;
      newLineCycle = true;
    }
    for (var alien in aliens) {
      alien.alien.moveTo(Vector2(newLineCycle ? 0 : shift * dx,
          0.0 + (newLineCycle ? gameSize.y / 20 : 0)));
    }
    return newLineCycle;
  }

  /// get the boundaries of visible aliens
  Rect boundaries() {
    if (aliens.isEmpty) return Rect.zero;
    Rect ret = aliens.first.alien.toRect();
    for (int i = 0; i < aliens.length; ++i) {
      if (aliens[i].isVisible) {
        ret = ret.expandToInclude(aliens[i].alien.toRect());
      }
    }
    return ret;
  }
}

class Alien extends SpriteComponent with CollisionCallbacks {
  final int index;
  final Function(int index) onHit;
  late RectangleHitbox hitBox;

  Alien({
    required this.index,
    required this.onHit,
  }) {
    hitBox = RectangleHitbox();
    add(hitBox);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    onHit(index);
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    if (other is ScreenHitbox) {}
  }

  void setPosAndSize(Vector2 newPos, Vector2 newSize) {
    moveTo(newPos);
    size = newSize;
    hitBox.size = newSize;
  }

  void moveTo(Vector2 delta) {
    position += delta;
  }

}
