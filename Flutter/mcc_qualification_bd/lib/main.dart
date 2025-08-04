import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bread_and_butter/screens/login_screen.dart';
import 'package:bread_and_butter/utils/colors.dart';
import 'package:bread_and_butter/utils/theme_provider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.flutterThemeMode,
      home: const LoginScreen(),
    );
  }
}
