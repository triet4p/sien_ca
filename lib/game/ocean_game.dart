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
    // 1. Setup Camera Fixed (800x1200)
    camera = CameraComponent.withFixedResolution(
      width: GameConstants.canvasWidth,
      height: GameConstants.canvasHeight,
    );
    camera.viewfinder.anchor = Anchor.topLeft;
    camera.viewfinder.position = Vector2.zero();

    // 2. Add Background Gradient (Optional - Tạm dùng màu nền)
    
    // 3. Add Spear (Add trước để nằm dưới thuyền nếu cần, hoặc quản lý priority)
    spear = Spear(weapon: DataManager().currentWeapon);
    spear.priority = 5;
    world.add(spear);

    // 4. Add Boat
    boat = PlayerBoat();
    world.add(boat);

    // Init Data
    oxygen = GameConstants.maxOxygen;
    currentScore = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    // 1. Oxygen Drain
    oxygen -= 0.05 * (dt * 60); // Time-based adjustment
    onOxygenChanged(oxygen.ceil());

    if (oxygen <= 0) {
      isGameOver = true;
      onGameOver(currentScore);
      return;
    }

    // 2. Spawning Logic
    lastSpawnTime += dt;
    // Spawn mỗi 0.8s nếu chưa quá 25 con
    int fishCount = world.children.whereType<Fish>().length;
    if (lastSpawnTime > 0.8 && fishCount < 25) {
      _spawnFish();
      lastSpawnTime = 0;
    }

    // 3. Collision Detection (Spear vs Fish)
    if (spear.state == SpearState.flying) { // Chỉ check khi lao đang bay tới
      // Lấy danh sách cá
      final fishes = world.children.whereType<Fish>();
      
      for (final fish in fishes) {
        // Distance check (Simple circle collision)
        double dist = spear.position.distanceTo(fish.position);
        
        // fish.width / 2 + 10 (Hitbox rộng hơn chút)
        if (dist < (fish.size.x / 2 + 10)) {
          // HIT!
          fish.takeDamage(spear.weapon.damage);
          spear.returnSpear(); // Lao trúng là quay về ngay

          // Cá chết?
          if (fish.currentHp <= 0) {
            currentScore += fish.template.value;
            onScoreChanged(currentScore);
            fish.removeFromParent(); // Xóa cá
            
            // Effect: Có thể add ParticleEffect nổ tiền ở đây
          }
          break; // Mỗi lần lao chỉ trúng 1 con (hoặc xuyên táo nếu muốn upgrade sau)
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
    // 1. Reset Stats
    oxygen = GameConstants.maxOxygen;
    currentScore = 0;
    isGameOver = false;
    lastSpawnTime = 0;
    
    // 2. Clear Fishes
    world.children.whereType<Fish>().forEach((f) => f.removeFromParent());
    
    // 3. Reset Spear
    spear.reset();
    updateWeapon(); // Cập nhật lại vũ khí nếu lỡ có đổi trong shop
    
    // 4. Update UI ngay lập tức
    onScoreChanged(0);
    onOxygenChanged(oxygen.toInt());
    
    resumeEngine(); // Đảm bảo game chạy
  }
}