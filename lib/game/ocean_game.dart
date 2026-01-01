import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/data_manager.dart';
import '../../core/types.dart';
import 'components/fish.dart';
import 'components/player_boat.dart';
import 'components/spear.dart';

class OceanGame extends FlameGame with TapCallbacks {
  // Callback về UI Flutter
  final Function(int) onGameOver;
  final Function(int) onOxygenChanged; // Để update UI thanh Oxy
  final Function(int) onScoreChanged;

  late final Spear spear;
  late final PlayerBoat boat;
  
  // Game State
  double oxygen = GameConstants.maxOxygen;
  int currentScore = 0;
  bool isGameOver = false;
  double lastSpawnTime = 0;

  OceanGame({
    required this.onGameOver,
    required this.onOxygenChanged,
    required this.onScoreChanged,
  });

  @override
  Color backgroundColor() => const Color(0xFF0c4a6e); // Màu nền biển sâu

  @override
  Future<void> onLoad() async {
    camera = CameraComponent.withFixedResolution(
      width: GameConstants.canvasWidth,
      height: GameConstants.canvasHeight,
    );
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    spear = Spear(weapon: DataManager().currentWeapon);
    spear.priority = 5;
    world.add(spear);

    boat = PlayerBoat();
    world.add(boat);

    oxygen = GameConstants.maxOxygen;
    currentScore = 0;

    // FIX QUAN TRỌNG: Dừng game ngay khi load xong (để hiện Menu)
    pauseEngine();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    oxygen -= 0.05 * (dt * 60);
    onOxygenChanged(oxygen.ceil());

    if (oxygen <= 0) {
      isGameOver = true;
      pauseEngine(); // Dừng game khi chết
      onGameOver(currentScore);
      return;
    }

    lastSpawnTime += dt;
    int fishCount = world.children.whereType<Fish>().length;
    if (lastSpawnTime > 0.8 && fishCount < 25) {
      _spawnFish();
      lastSpawnTime = 0;
    }

    if (spear.state == SpearState.flying) {
      final fishes = world.children.whereType<Fish>();
      for (final fish in fishes) {
        double dist = spear.position.distanceTo(fish.position);
        if (dist < (fish.size.x / 2 + 10)) {
          fish.takeDamage(spear.weapon.damage);
          spear.returnSpear();

          if (fish.currentHp <= 0) {
            currentScore += fish.template.value;
            onScoreChanged(currentScore);
            fish.removeFromParent();
          }
          break;
        }
      }
    }
  }

  // Draw Dây Thừng ở đây để nó nằm trên background nhưng dưới thuyền
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Vẽ dây thừng nối từ Thuyền -> Lao
    if (spear.state != SpearState.idle) {
      // Vì spear và boat đều ở trong World, và Camera đang nhìn vào World.
      // Hàm render này của Game vẽ lên Canvas của Viewport? KHÔNG.
      // Hàm render của FlameGame vẽ lên canvas gốc. 
      // NẾU dùng CameraComponent, ta nên vẽ dây thừng bằng một Component riêng hoặc vẽ trong Spear nhưng tính toạ độ Global.
      // Tuy nhiên, để đơn giản cho MVP, ta bỏ qua dây thừng phức tạp, 
      // hoặc vẽ dây thừng trong SpearComponent (đã làm sơ sơ).
    }
  }

  void _spawnFish() {
    final template = FISH_TEMPLATES[Random().nextInt(FISH_TEMPLATES.length)];
    int direction = Random().nextBool() ? 1 : -1;
    
    // X: Nếu đi sang phải (1) thì xuất phát từ -size. Nếu sang trái (-1) thì từ Width + size
    double startX = direction == 1 ? -template.size : GameConstants.canvasWidth + template.size;
    
    // Y: Random trong khoảng depthRange
    double range = template.depthRange[1] - template.depthRange[0];
    double startY = template.depthRange[0] + Random().nextDouble() * range;

    final fish = Fish(
      template: template,
      x: startX,
      y: startY,
      direction: direction,
    );
    world.add(fish);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isGameOver) return;

    // Chuyển toạ độ màn hình (screen) sang toạ độ thế giới (world)
    // Vì dùng Camera fixed, ta cần convert chuẩn.
    Vector2 worldPos = camera.globalToLocal(event.localPosition);

    // Bắn lao về phía đó
    spear.fire(worldPos);
  }
  
  // Hàm update vũ khí khi mua từ Shop
  void updateWeapon() {
    spear.updateWeapon(DataManager().currentWeapon);
  }

  void reset() {
    oxygen = GameConstants.maxOxygen;
    currentScore = 0;
    isGameOver = false;
    lastSpawnTime = 0;
    
    world.children.whereType<Fish>().forEach((f) => f.removeFromParent());
    spear.reset();
    updateWeapon();
    
    onScoreChanged(0);
    onOxygenChanged(oxygen.toInt());
    
    // FIX: Chạy lại game khi bấm Reset/Start
    resumeEngine();
  }
}