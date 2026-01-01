import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants.dart';
import 'core/data_manager.dart';
import 'game/ocean_game.dart';
import 'game/overlays/shop_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DataManager().load();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OceanApp(),
  ));
}

class OceanApp extends StatefulWidget {
  const OceanApp({super.key});

  @override
  State<OceanApp> createState() => _OceanAppState();
}

class _OceanAppState extends State<OceanApp> {
  late OceanGame _game;
  int _score = 0;
  int _oxygen = GameConstants.maxOxygen.toInt();

  @override
  void initState() {
    super.initState();
    _game = OceanGame(
      onScoreChanged: (score) {
        if (mounted && _score != score) {
           Future.microtask(() => setState(() => _score = score));
        }
      },
      onOxygenChanged: (oxy) {
        if (mounted && _oxygen != oxy) {
          setState(() => _oxygen = oxy);
        }
      },
      onGameOver: (finalScore) {
        if (mounted) {
          Future.delayed(Duration.zero, () {
             DataManager().addCoins(finalScore);
             DataManager().updateHighScore(finalScore);
             _switchOverlay('GameOver');
          });
        }
      },
    );

    // FIX LỖI: Add Menu thủ công 1 lần duy nhất khi App khởi động
    // Thay vì dùng initialActiveOverlays dễ gây lỗi khi rebuild
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _game.overlays.add('Menu');
    });
  }

  // Hàm chuyển màn hình
  void _switchOverlay(String newOverlay) {
    // Xóa tất cả overlay đang hiện
    final activeOverlays = _game.overlays.activeOverlays.toList();
    _game.overlays.removeAll(activeOverlays);
    
    // Thêm cái mới
    _game.overlays.add(newOverlay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: _game,
        // FIX LỖI: Xóa dòng initialActiveOverlays ở đây đi!
        // initialActiveOverlays: const ['Menu'], <--- ĐÃ XÓA
        overlayBuilderMap: {
          'Menu': (context, OceanGame game) => _buildMenu(game),
          'HUD': (context, OceanGame game) => _buildHUD(game),
          'Shop': (context, OceanGame game) => ShopOverlay(
            game: game, 
            onClose: () => _switchOverlay('Menu'),
          ),
          'GameOver': (context, OceanGame game) => _buildGameOver(game),
        },
      ),
    );
  }

  // --- MENU OVERLAY ---
  Widget _buildMenu(OceanGame game) {
    return Center(
      child: Container(
        color: Colors.black.withOpacity(0.9),
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "SIÊN CÁ",
              style: GoogleFonts.baloo2(
                fontSize: 80, 
                fontWeight: FontWeight.w900, 
                color: Colors.lightBlueAccent,
                shadows: [const BoxShadow(color: Colors.blue, blurRadius: 20)]
              ),
            ),
            Text(
              "CHINH PHỤC ĐẠI DƯƠNG",
              style: GoogleFonts.baloo2(fontSize: 20, color: Colors.white70),
            ),
            const SizedBox(height: 50),
            
            // Nút BẮT ĐẦU
            _buildButton(
              text: "BẮT ĐẦU",
              color: Colors.blue,
              onTap: () {
                // FIX THỨ TỰ: Chuyển màn hình trước -> Reset sau
                // Để tránh việc reset gọi setState khi Menu chưa kịp tắt
                _switchOverlay('HUD'); 
                game.reset();
              }
            ),
            const SizedBox(height: 20),
            
            _buildButton(
              text: "CỬA HÀNG",
              color: Colors.orange,
              onTap: () {
                _switchOverlay('Shop');
              }
            ),

            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag("KỶ LỤC: ${DataManager().highScore}", Colors.blue[900]!),
                const SizedBox(width: 10),
                _buildTag("TIỀN: ${DataManager().coins}", Colors.orange[900]!),
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- HUD OVERLAY ---
  Widget _buildHUD(OceanGame game) {
    double oxyPercent = _oxygen / GameConstants.maxOxygen;
    Color oxyColor = oxyPercent > 0.3 ? Colors.lightBlue : Colors.red;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.blue),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text(
                    "$_score 💰",
                    style: const TextStyle(color: Colors.yellow, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    game.pauseEngine();
                    _switchOverlay('Menu');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                    child: const Text("THOÁT", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("OXY: $_oxygen", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                    const SizedBox(height: 4),
                    Container(
                      width: 150, height: 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.white24)
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: oxyPercent.clamp(0.0, 1.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: oxyColor,
                            borderRadius: BorderRadius.circular(5)
                          ),
                        ),
                      ),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- GAME OVER OVERLAY ---
  Widget _buildGameOver(OceanGame game) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: const Color(0xFF0c4a6e),
            border: Border.all(color: Colors.lightBlue, width: 4),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [const BoxShadow(color: Colors.black, blurRadius: 20)]
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("HẾT OXY!", style: GoogleFonts.baloo2(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Số cá đã siên được:", style: TextStyle(color: Colors.white70)),
              Text("$_score", style: GoogleFonts.baloo2(fontSize: 60, color: Colors.yellow, fontWeight: FontWeight.w900)),
              const SizedBox(height: 30),
              _buildButton(
                text: "QUAY LẠI",
                color: Colors.amber,
                onTap: () {
                  _switchOverlay('Menu');
                }
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({required String text, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color, color.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), offset: const Offset(0, 4))]
        ),
        child: Center(
          child: Text(
            text,
            style: GoogleFonts.baloo2(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color bg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.5),
        border: Border.all(color: bg),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}