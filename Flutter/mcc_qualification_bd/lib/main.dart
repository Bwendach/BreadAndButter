import 'package:flutter/material.dart';
import 'package:bread_and_butter/screens/login_screen.dart';
import 'package:bread_and_butter/utils/colors.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: lightTheme, 
      darkTheme: darkTheme,
      themeMode: ThemeMode.system, 
      home: const LoginScreen(),
    );
  }
}
