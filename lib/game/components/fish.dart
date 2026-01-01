import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/types.dart';

class Fish extends PositionComponent {
  final FishTemplate template;
  final int direction; // 1: Phải, -1: Trái
  int currentHp;

  late final TextComponent _emojiComponent;
  late final RectangleComponent _hpBarBg;
  late final RectangleComponent _hpBarFill;

  Fish({
    required this.template,
    required double x,
    required double y,
    required this.direction,
  }) : currentHp = template.hp {
    position = Vector2(x, y);
    size = Vector2.all(template.size);
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // 1. Render Emoji
    _emojiComponent = TextComponent(
      text: template.emoji,
      textRenderer: TextPaint(
        style: TextStyle(fontSize: template.size, fontFamily: 'Arial'), // Dùng Arial để support emoji tốt
      ),
    );
    _emojiComponent.anchor = Anchor.center;
    _emojiComponent.position = size / 2;
    
    // Nếu đi sang trái thì lật hình lại
    if (direction == -1) {
      _emojiComponent.scale = Vector2(-1, 1);
    }
    add(_emojiComponent);

    // 2. Setup HP Bar (Ẩn mặc định)
    _hpBarBg = RectangleComponent(
      position: Vector2(0, -10),
      size: Vector2(size.x, 5),
      paint: Paint()..color = Colors.red,
    );
    _hpBarFill = RectangleComponent(
      position: Vector2(0, -10),
      size: Vector2(size.x, 5),
      paint: Paint()..color = Colors.green,
    );
    
    // Add vào nhưng ẩn đi (opacity = 0 hoặc ko add, ở đây ta ko add vội)
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 1. Di chuyển
    x += template.speed * direction; // Pixel per frame logic convert -> Logic này cần nhân dt nếu muốn chuẩn time-based
    // Tuy nhiên, để khớp logic gốc (pixel/frame), ta cứ cộng thẳng hoặc nhân hệ số.
    // Logic gốc: x += speed * direction. Game gốc chạy 60fps.
    // Logic Flame: x += speed * direction * (dt * 60);
    
    // 2. Wrap around screen (Đi lố màn hình thì quay lại bên kia)
    if (direction == 1 && x > GameConstants.canvasWidth + width) {
      x = -width;
    } else if (direction == -1 && x < -width) {
      x = GameConstants.canvasWidth + width;
    }

    // 3. Update HP Bar
    if (currentHp < template.hp) {
      if (!_hpBarBg.isMounted) add(_hpBarBg);
      if (!_hpBarFill.isMounted) add(_hpBarFill);

      double percent = currentHp / template.hp;
      _hpBarFill.width = size.x * percent;
    }
  }

  void takeDamage(int damage) {
    currentHp -= damage;
    // Hiệu ứng nháy đỏ hoặc rung lắc có thể thêm ở đây
  }
}