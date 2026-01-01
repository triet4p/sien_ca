import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants.dart';
import '../../core/data_manager.dart';
import '../../core/types.dart';
import '../ocean_game.dart';

class ShopOverlay extends StatefulWidget {
  final OceanGame game;
  final VoidCallback onClose;

  const ShopOverlay({
    super.key, 
    required this.game, 
    required this.onClose
  });

  @override
  State<ShopOverlay> createState() => _ShopOverlayState();
}

class _ShopOverlayState extends State<ShopOverlay> {
  final DataManager _data = DataManager();

  void _buy(Weapon weapon) {
    if (_data.coins >= weapon.cost) {
      setState(() {
        _data.spendCoins(weapon.cost);
        _data.buyWeapon(weapon.id);
      });
    }
  }

  void _equip(Weapon weapon) {
    setState(() {
      _data.equipWeapon(weapon.id);
      widget.game.updateWeapon(); // Cập nhật ngay vào game
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0c4a6e), // Sky 950
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header (FIXED OVERFLOW)
          Row(
            children: [
              // 1. Tiêu đề: Dùng Expanded để chiếm chỗ trống và FittedBox để tự co nhỏ
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "XƯỞNG VŨ KHÍ", // Có thể đổi thành "SHOP" cho ngắn nếu cần
                    style: GoogleFonts.baloo2(
                      fontSize: 32, 
                      fontWeight: FontWeight.w900, 
                      color: Colors.white
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 8),

              // 2. Tiền
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "${_data.coins} 💰",
                  style: const TextStyle(
                    fontSize: 18, 
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF082f49)
                  ),
                ),
              ),
              
              const SizedBox(width: 8),

              // 3. Nút Đóng
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                padding: EdgeInsets.zero, // Bỏ padding thừa
                constraints: const BoxConstraints(), // Thu gọn area
              )
            ],
          ),
          
          const SizedBox(height: 20),

          // Grid Vũ khí (Giữ nguyên)
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.70, // Chỉnh lại tỷ lệ cho thẻ dài ra chút đỡ bị chật
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: WEAPONS.length,
              itemBuilder: (context, index) {
                // ... (Giữ nguyên logic bên trong item builder cũ) ...
                final weapon = WEAPONS[index];
                final isOwned = _data.hasWeapon(weapon.id);
                final isEquipped = _data.equippedWeaponId == weapon.id;
                final canAfford = _data.coins >= weapon.cost;

                return Container(
                  decoration: BoxDecoration(
                    color: isEquipped ? const Color(0xFF0c4a6e) : const Color(0xFF082f49),
                    border: Border.all(
                      color: isEquipped ? Colors.lightBlue : Colors.white10,
                      width: isEquipped ? 3 : 1
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isEquipped ? [BoxShadow(color: Colors.lightBlue.withOpacity(0.3), blurRadius: 10)] : []
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: Color(weapon.color),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24, width: 2)
                        ),
                        child: Center(
                          child: Container(
                             width: 4, height: 40, 
                             color: Colors.white.withOpacity(0.5),
                             transform: Matrix4.rotationZ(0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        weapon.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            Text("Sát thương: ${weapon.damage}", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                            Text("Tầm xa: ${weapon.range.toInt()}m", style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (!isOwned)
                        ElevatedButton(
                          onPressed: canAfford ? () => _buy(weapon) : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            disabledBackgroundColor: Colors.grey[800],
                            foregroundColor: const Color(0xFF082f49),
                          ),
                          child: Text("${weapon.cost} 💰"),
                        )
                      else
                        ElevatedButton(
                          onPressed: isEquipped ? null : () => _equip(weapon),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isEquipped ? Colors.lightBlue : Colors.green,
                            disabledBackgroundColor: Colors.lightBlue,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(isEquipped ? "ĐANG DÙNG" : "TRANG BỊ"),
                        ),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}