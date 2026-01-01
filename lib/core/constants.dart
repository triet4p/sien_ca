import 'types.dart';

class GameConstants {
  static const double canvasWidth = 800;
  static const double canvasHeight = 1200;
  static const double surfaceHeight = 150;
  static const double maxOxygen = 200;
}

const List<Weapon> WEAPONS = [
  Weapon(id: 'w1', name: 'Gỗ Cũ', cost: 0, damage: 1, speed: 10, range: 400, color: 0xFF92400e),
  Weapon(id: 'w2', name: 'Sắt Rỉ', cost: 5000, damage: 2, speed: 12, range: 600, color: 0xFF64748b),
  Weapon(id: 'w3', name: 'Thép Lam', cost: 50000, damage: 5, speed: 15, range: 800, color: 0xFF3b82f6),
  Weapon(id: 'w4', name: 'Rồng Thần', cost: 250000, damage: 10, speed: 20, range: 1200, color: 0xFFef4444),
];

const List<FishTemplate> FISH_TEMPLATES = [
  // Level 1
  FishTemplate(id: 'f1', name: 'Cá Nhỏ', emoji: '🐟', value: 10, speed: 2.5, depthRange: [180, 450], size: 40, hp: 1),
  FishTemplate(id: 'f2', name: 'Cá Kiếm', emoji: '🐡', value: 50, speed: 4, depthRange: [250, 550], size: 50, hp: 1),
  FishTemplate(id: 'f10', name: 'Cá Trích', emoji: '🐟', value: 20, speed: 3, depthRange: [380, 420], size: 35, hp: 1),
  FishTemplate(id: 'f11', name: 'Cá Vàng', emoji: '🐠', value: 30, speed: 2, depthRange: [350, 450], size: 45, hp: 2),
  FishTemplate(id: 'f12', name: 'Cá Mó', emoji: '🐠', value: 40, speed: 2.2, depthRange: [390, 410], size: 50, hp: 2),
  
  FishTemplate(id: 'f3', name: 'Bạch Tuộc', emoji: '🐙', value: 60, speed: 1.5, depthRange: [300, 600], size: 60, hp: 3),
  FishTemplate(id: 'f4', name: 'Cá Mập Xám', emoji: '🦈', value: 100, speed: 4, depthRange: [400, 800], size: 80, hp: 4),
  FishTemplate(id: 'f5', name: 'Lươn Điện', emoji: '🐍', value: 150, speed: 5, depthRange: [500, 900], size: 90, hp: 5),
  
  // Level 2 (Deep)
  FishTemplate(id: 'f6', name: 'Mực Khổng Lồ', emoji: '🦑', value: 800, speed: 1, depthRange: [700, 1100], size: 120, hp: 8),
  FishTemplate(id: 'f7', name: 'Cá Mặt Trời', emoji: '🐠', value: 300, speed: 4.8, depthRange: [600, 1000], size: 100, hp: 15),
  FishTemplate(id: 'f8', name: 'Cá Voi Xanh', emoji: '🐳', value: 600, speed: 5.2, depthRange: [800, 1150], size: 180, hp: 25),
  FishTemplate(id: 'f9', name: 'Cá Mập Trắng', emoji: '🦈', value: 1000, speed: 6, depthRange: [750, 1100], size: 110, hp: 20),
];