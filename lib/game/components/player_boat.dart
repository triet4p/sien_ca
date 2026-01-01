import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../../core/constants.dart';

class PlayerBoat extends PositionComponent {
  
  PlayerBoat() {
    position = Vector2(0, 0);
    size = Vector2(GameConstants.canvasWidth, GameConstants.surfaceHeight);
    anchor = Anchor.topLeft;
    priority = 10; // Vẽ đè lên cá
  }

  @override
  void render(Canvas canvas) {
    // 1. Vẽ Bầu trời/Nước mặt (Xanh đậm)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, width, height), 
      Paint()..color = const Color(0xFF1e3a8a)
    );

    // 2. Vẽ Thuyền (Vàng)
    double boatW = 80;
    double boatH = 10;
    double boatX = width / 2 - boatW / 2;
    double boatY = height - 10;
    
    canvas.drawRect(
      Rect.fromLTWH(boatX, boatY, boatW, boatH), 
      Paint()..color = const Color(0xFFfbbf24)
    );

    // 3. Vẽ Đầu người (Tròn vàng nhạt)
    canvas.drawCircle(
      Offset(width / 2, height - 40), 
      15, 
      Paint()..color = const Color(0xFFfef08a)
    );
  }
}