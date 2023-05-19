import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'aliens.dart';
import 'player.dart';

void main() {
  runApp(GameWidget(game: SpaceInvaders()));
}

class SpaceInvaders extends FlameGame
    with
        PanDetector,
        SingleGameInstance,
        KeyboardEvents,
        HasCollisionDetection {
  Player player = Player();
  Aliens? aliens;
  late Timer timer;
  late int dx;
  int tickNumber = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final playerSprite = await loadSprite('laser_cannon.png');
    player
      ..sprite = playerSprite
      ..anchor = Anchor.center;
    add(player);

    aliens = Aliens(
      await loadSprite('alien.png'),
      size,
      (hitIndex) {
        remove(aliens!.aliens[hitIndex].alien);
        aliens!.aliens[hitIndex] = (
          alien: aliens!.aliens[hitIndex].alien,
          isVisible: false,
        );
      },
    );
    for (int i = 0; i < aliens!.aliens.length; ++i) {
      add(aliens!.aliens[i].alien);
    }

    /// cache sounds
    await FlameAudio.audioCache.load('fastinvader0.wav');
    await FlameAudio.audioCache.load('fastinvader1.wav');
    await FlameAudio.audioCache.load('fastinvader2.wav');
    await FlameAudio.audioCache.load('fastinvader3.wav');

    dx = 1;

    timer = Timer(
      0.5,
      autoStart: true,
      repeat: true,
      onTick: () {
        if (aliens!.stepForward(size) && timer.limit > 0.2) {
          timer.limit -= 0.05;
        }

        FlameAudio.play('fastinvader${tickNumber % 4}.wav', volume: 0.6);
        tickNumber++;
      },
    );
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);

    player.size = Vector2(size.x / 10, size.x / 20);
    player.position = Vector2(size.x / 2, size.y - 40);

    if (aliens != null) {
      for (int i = 0; i < aliens!.aliens.length; ++i) {
        aliens!.setSizePos(i, size);
      }
      timer.limit = 0.5;
      tickNumber = 0;
    }
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isKeyDown = event is RawKeyDownEvent;

    final isSpace = keysPressed.contains(LogicalKeyboardKey.space);

    if (isSpace && isKeyDown) {
      playerShoot();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.moveTo(Vector2(info.delta.game.x, 0));
  }

  @override
  void update(double dt) {
    super.update(dt);
    timer.update(dt);
  }

  playerShoot() {
    add(
      PlayerFire(
        playerPos: player.position,
        onHit: (component) {
          remove(component);
          FlameAudio.play('explosion.wav', volume: 0.6);
        },
      ),
    );
    FlameAudio.play('shoot.wav', volume: 0.6);
  }
}
