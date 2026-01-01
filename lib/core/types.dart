enum GameState {
  menu,
  playing,
  shop,
  gameOver
}

class FishTemplate {
  final String id;
  final String name;
  final String emoji;
  final int value;
  final double speed;
  final List<double> depthRange; // [min, max]
  final double size;
  final int hp;

  const FishTemplate({
    required this.id,
    required this.name,
    required this.emoji,
    required this.value,
    required this.speed,
    required this.depthRange,
    required this.size,
    required this.hp,
  });
}

class Weapon {
  final String id;
  final String name;
  final int cost;
  final int damage;
  final double speed;
  final double range;
  final int color; // Lưu dạng int (0xFF...) thay vì string hex

  const Weapon({
    required this.id,
    required this.name,
    required this.cost,
    required this.damage,
    required this.speed,
    required this.range,
    required this.color,
  });
}

// Model để lưu xuống DB
class PlayerProgress {
  int coins;
  int highScore;
  List<String> ownedWeaponIds;
  String equippedWeaponId;

  PlayerProgress({
    this.coins = 0,
    this.highScore = 0,
    this.ownedWeaponIds = const ['w1'],
    this.equippedWeaponId = 'w1',
  });

  // Convert từ JSON (Map) sang Object
  factory PlayerProgress.fromJson(Map<String, dynamic> json) {
    return PlayerProgress(
      coins: json['coins'] ?? 0,
      highScore: json['highScore'] ?? 0,
      ownedWeaponIds: List<String>.from(json['ownedWeaponIds'] ?? ['w1']),
      equippedWeaponId: json['equippedWeaponId'] ?? 'w1',
    );
  }

  // Convert từ Object sang JSON (Map)
  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'highScore': highScore,
      'ownedWeaponIds': ownedWeaponIds,
      'equippedWeaponId': equippedWeaponId,
    };
  }
}