import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tugas_akhir_pm/hive/user.dart';
import 'package:tugas_akhir_pm/model/product_model.dart';
import 'package:tugas_akhir_pm/view/login.dart';
import 'package:tugas_akhir_pm/view/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(ComputerAdapter());
  await Hive.openBox<User>('usersBox');
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen());
  }
}
