import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'types.dart';
import 'constants.dart';

class DataManager {
  static const String _key = 'sien_ca_data';

  // Singleton pattern
  static final DataManager _instance = DataManager._internal();
  factory DataManager() => _instance;
  DataManager._internal();

  PlayerProgress? _progress;

  // Load data khi mở app
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_key);
    
    if (rawJson != null) {
      try {
        _progress = PlayerProgress.fromJson(jsonDecode(rawJson));
      } catch (e) {
        print("Error loading data: $e");
        _progress = PlayerProgress(); // Fallback nếu data lỗi
      }
    } else {
      _progress = PlayerProgress(); // User mới
    }
  }

  // Lưu data hiện tại xuống đĩa
  Future<void> save() async {
    if (_progress == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_progress!.toJson()));
  }

  // Getters & Helpers
  int get coins => _progress?.coins ?? 0;
  int get highScore => _progress?.highScore ?? 0;
  String get equippedWeaponId => _progress?.equippedWeaponId ?? 'w1';
  
  Weapon get currentWeapon {
    return WEAPONS.firstWhere(
      (w) => w.id == equippedWeaponId, 
      orElse: () => WEAPONS[0]
    );
  }
  
  bool hasWeapon(String id) => _progress?.ownedWeaponIds.contains(id) ?? false;

  // Actions
  void addCoins(int amount) {
    _progress?.coins += amount;
    save();
  }

  void spendCoins(int amount) {
    if (_progress != null && _progress!.coins >= amount) {
      _progress!.coins -= amount;
      save();
    }
  }

  void updateHighScore(int score) {
    if (_progress != null && score > _progress!.highScore) {
      _progress!.highScore = score;
      save();
    }
  }

  void buyWeapon(String id) {
    if (_progress != null && !_progress!.ownedWeaponIds.contains(id)) {
      _progress!.ownedWeaponIds.add(id);
      save();
    }
  }

  void equipWeapon(String id) {
    if (_progress != null) {
      _progress!.equippedWeaponId = id;
      save();
    }
  }
}