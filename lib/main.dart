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
  
  // 1. Load Data
  await DataManager().load();
  
  // 2. Setup Screen
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
  
  // State UI
  int _score = 0;
  int _oxygen = GameConstants.maxOxygen.toInt();
  
  // Overlay management
  // Flame quản lý overlay bằng String keys.
  // Mặc định ta sẽ hiện 'Menu' trước.

  @override
  void initState() {
    super.initState();
    _game = OceanGame(
      onScoreChanged: (score) {
        // Chỉ setState nếu mounted để tránh lỗi
        if (mounted && _score != score) {
           // Bọc trong postFrameCallback nếu cần thiết (fix lỗi build)
           WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() => _score = score);
           });
        }
      },
      onOxygenChanged: (oxy) {
        // Oxy đổi liên tục 60fps, ta nên hạn chế setState nếu không cần thiết
        // Hoặc chấp nhận update UI.
        // Để tối ưu: Có thể check if (oxy % 5 == 0) mới update.
        if (mounted && _oxygen != oxy) {
          // Không bọc postFrameCallback cho oxy để mượt hơn, trừ khi crash
          setState(() => _oxygen = oxy);
        }
      },
      onGameOver: (finalScore) {
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
             DataManager().addCoins(finalScore);
             DataManager().updateHighScore(finalScore);
             _game.pauseEngine();
             _game.overlays.add('GameOver');
             _game.overlays.remove('HUD');
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GameWidget(
        game: _game,
        initialActiveOverlays: const ['Menu'], // Bắt đầu ở Menu
        overlayBuilderMap: {
          'Menu': (context, OceanGame game) => _buildMenu(game),
          'HUD': (context, OceanGame game) => _buildHUD(game),
          'Shop': (context, OceanGame game) => ShopOverlay(
            game: game, 
            onClose: () {
              game.overlays.remove('Shop');
              game.overlays.add('Menu');
            }
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
            
            // Start Button
            _buildButton(
              text: "BẮT ĐẦU",
              color: Colors.blue,
              onTap: () {
                game.reset();
                game.overlays.remove('Menu');
                game.overlays.add('HUD');
              }
            ),
            const SizedBox(height: 20),
            
            // Shop Button
            _buildButton(
              text: "CỬA HÀNG",
              color: Colors.orange,
              onTap: () {
                game.overlays.remove('Menu');
                game.overlays.add('Shop');
              }
            ),

            const SizedBox(height: 50),
            // Stats
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
            // Top Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Score
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
                
                // Exit Button
                GestureDetector(
                  onTap: () {
                    game.pauseEngine();
                    game.overlays.remove('HUD');
                    game.overlays.add('Menu');
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

            // Oxygen Bar (Right side aligned)
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
                  game.overlays.remove('GameOver');
                  game.overlays.add('Menu');
                }
              )
            ],
          ),
        ),
      ),
    );
  }

  // Helpers
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