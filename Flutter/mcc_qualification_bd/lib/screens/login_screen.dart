// import 'dart:nativewrappers/_internal/vm/lib/math_patch.dart';

import 'package:bread_and_butter/apis/api.dart';
import 'package:bread_and_butter/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:bread_and_butter/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameOrEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _usernameOrEmailError;
  String? _passwordError;

  void _validateAndLogin() async {
    setState(() {
      _usernameOrEmailError = null;
      _passwordError = null;
    });

    String usernameOrEmail = _usernameOrEmailController.text.trim();
    String password = _passwordController.text.trim();
    bool isValid = true;

    if (usernameOrEmail.isEmpty) {
      _usernameOrEmailError = 'Username or email cannot be empty';
      isValid = false;
    } else if (usernameOrEmail.contains('@') &&
        !RegExp(
          r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$",
        ).hasMatch(usernameOrEmail)) {
      _usernameOrEmailError = 'Enter a valid email address';
      isValid = false;
    }

    if (password.isEmpty) {
      _passwordError = 'Password cannot be empty';
      isValid = false;
    } else if (password.length < 6) {
      _passwordError = 'Password must be at least 6 characters';
      isValid = false;
    }

    if (!isValid) {
      setState(() {});
      return;
    }

    final result = await login(usernameOrEmail, password);
    final bool success = result.$1;
    final String errorMessage = result.$2;
    final String? userId = result.userId;

    if (success) {
      showSnackBar(context, "Login successful!");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(userId: userId!)),
        (route) => false,
      );
    } else {
      showSnackBar(context, errorMessage);
    }
  }

  void checkUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final userId = prefs.getString("userId");

    if (token != null && userId != null) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(userId: userId)),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFFDEBD0);
    const accentColor = Color(0xFFB47B84);

    return Scaffold(
      backgroundColor: themeColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/bread_bag_icon.png', height: 100),
              const SizedBox(height: 16),

              const Text(
                "Welcome to Bread & Butter!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8C5E58),
                ),
              ),
              const SizedBox(height: 32),

              // Username or Email
              TextField(
                controller: _usernameOrEmailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Username or Email',
                  hintText: 'Enter you username or email',
                  errorText: _usernameOrEmailError,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  errorText: _passwordError,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Login Button
              ElevatedButton(
                onPressed: _validateAndLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
