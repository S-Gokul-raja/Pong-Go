import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:ponggo/highscore.dart';
import 'package:provider/provider.dart';
import 'game_page.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const PongGo());
}

class PongGo extends StatelessWidget {
  const PongGo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HighScore(),
      builder: (context, _) {
        return const MaterialApp(
          title: "Pong Go",
          debugShowCheckedModeBanner: false,
          home: GamePage(),
        );
      },
    );
  }
}
