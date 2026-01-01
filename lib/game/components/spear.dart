import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../core/types.dart';

enum SpearState { idle, flying, returning }

class Spear extends PositionComponent {
  Weapon weapon;
  SpearState state = SpearState.idle;
  
  double distanceTravelled = 0;
  Vector2 velocity = Vector2.zero();
  Vector2 origin = Vector2(GameConstants.canvasWidth / 2, GameConstants.surfaceHeight);

  // Paints
  late Paint _paintBody;
  late Paint _paintTip;
  late Paint _paintLine; // Dây thừng

  Spear({required this.weapon}) {
    // Init Paints
    _paintBody = Paint()..color = Color(weapon.color);
    _paintTip = Paint()..color = const Color(0xFFcbd5e1);
    _paintLine = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2; // Dây thừng mảnh
      // ..strokeCap = StrokeCap.round; // Dash effect khó làm với Paint thuần, ta vẽ line liền cũng đc
  }

  void updateWeapon(Weapon newWeapon) {
    weapon = newWeapon;
    _paintBody.color = Color(weapon.color);
  }

  void fire(Vector2 target) {
    if (state != SpearState.idle) return;

    state = SpearState.flying;
    origin = Vector2(GameConstants.canvasWidth / 2, GameConstants.surfaceHeight); // Reset origin
    position = origin.clone();
    distanceTravelled = 0;

    // Tính góc và vận tốc
    // target là toạ độ tap
    double angle = atan2(target.y - y, target.x - x);
    this.angle = angle; // Xoay mũi lao

    // Vận tốc vector
    velocity = Vector2(cos(angle), sin(angle)) * weapon.speed;
  }

  void returnSpear() {
    state = SpearState.returning;
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (state == SpearState.flying) {
      // Logic bay đi
      position += velocity; // (dt * 60) nếu muốn time-based chuẩn
      distanceTravelled += weapon.speed;

      // Check range hoặc ra khỏi màn hình
      if (distanceTravelled >= weapon.range || 
          x < 0 || x > GameConstants.canvasWidth || 
          y > GameConstants.canvasHeight) {
        state = SpearState.returning;
      }

    } else if (state == SpearState.returning) {
      // Logic bay về (Kéo dây)
      Vector2 dirToOrigin = origin - position;
      double dist = dirToOrigin.length;

      if (dist < weapon.speed * 1.5) { // Về đến nơi
        reset();
      } else {
        // Normalize vector rồi nhân tốc độ (về nhanh hơn bay đi 1.5 lần)
        dirToOrigin.normalize();
        position += dirToOrigin * (weapon.speed * 1.5);
      }
    }
  }

  void reset() {
    state = SpearState.idle;
    distanceTravelled = 0;
    position = origin.clone();
    angle = 0;
  }

  @override
  void render(Canvas canvas) {
    if (state == SpearState.idle) return; // Không vẽ khi chưa bắn (hoặc vẽ trên tay nhân vật)

    // 1. Vẽ dây thừng (Từ origin đến đuôi lao)
    // Vì ta đang ở local coordinate system của Spear (đã rotate), việc vẽ dây nối về world origin hơi phức tạp.
    // Mẹo: Vẽ dây ở toạ độ World (parent render) hoặc tính ngược toạ độ.
    // Đơn giản nhất: Vẽ Spear Shape thôi, dây thừng vẽ ở Game Class hoặc chấp nhận dây vẽ sai hệ toạ độ chút.
    // FIX: Để vẽ dây đúng, ta dùng:
    // canvas.drawLine(Offset(-distanceTravelled, 0), Offset(0, 0), _paintLine); 
    // Vì Spear đang xoay (angle) và dịch chuyển, nên local (0,0) là mũi lao? Không, PositionComponent (0,0) là anchor.
    // Giả sử anchor là center.
    
    // Vẽ thân lao
    // Thân: Dài 40, Rộng 8. Vẽ từ -20 đến 20
    canvas.drawRect(const Rect.fromLTWH(-20, -4, 40, 8), _paintBody);

    // Vẽ mũi lao
    Path tipPath = Path();
    tipPath.moveTo(25, 0);
    tipPath.lineTo(15, -6);
    tipPath.lineTo(15, 6);
    tipPath.close();
    canvas.drawPath(tipPath, _paintTip);
    
    // Vẽ dây thừng (Mô phỏng đơn giản: Vạch nét đứt phía sau đuôi)
    // Để vẽ dây nối về thuyền thật sự đẹp, ta nên vẽ dây ở lớp Game, không phải trong Component này.
  }
}