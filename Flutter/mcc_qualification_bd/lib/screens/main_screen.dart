import 'package:bread_and_butter/apis/api.dart';
import 'package:bread_and_butter/screens/create_menu_screen.dart';
import 'package:bread_and_butter/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:bread_and_butter/screens/menu_list_screen.dart';
import 'package:bread_and_butter/screens/home_screen.dart';
import 'package:bread_and_butter/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String userId;

  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late List<Widget> pages;

  String username = "";
  String role = "";
  String userId = "";

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove("token");
    prefs.remove("userId");
    showSnackBar(context, "logout success");

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const LoginScreen();
        },
      ),
      (route) => false,
    );
  }

  void _fetchUserDetails() async {
    try {
      final userDetails = await getUser(widget.userId);
      setState(() {
        username = userDetails['username'] ?? "Guest";
        role = userDetails['role'] ?? "user";
        userId = userDetails['userId'] ??= widget.userId;
      });
    } catch (e) {
      showSnackBar(context, "Failed to fetch user details: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [const HomeScreen(), MenuListScreen(userId: userId, role: role)];
    if (role == 'admin') {
      pages.add(const CreateMenuScreen());
    }

    final List<BottomNavigationBarItem> bottomNavItems = [
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Menu List'),
    ];
    if (role == 'admin') {
      bottomNavItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.verified_user),
          label: 'Admin',
        ),
      );
    }

    if (_currentIndex >= pages.length) {
      _currentIndex = 0;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Hi, $username'),
          actions: [
            IconButton(
              icon: const Icon(Icons.brightness_6),
              tooltip: 'Toggle Theme',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Theme toggle not implemented')),
                );
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Text(
                  'Hello, $username',
                  style: const TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  setState(() => _currentIndex = 0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.list),
                title: const Text('Menu List'),
                onTap: () {
                  setState(() => _currentIndex = 1);
                  Navigator.pop(context);
                },
              ),

              if (role == 'admin')
                ListTile(
                  leading: const Icon(Icons.verified_user),
                  title: const Text('Admin'),
                  onTap: () {
                    setState(() => _currentIndex = 2);
                    Navigator.pop(context);
                  },
                ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Log Out'),
                onTap: _logout,
              ),
            ],
          ),
        ),
        body: pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: bottomNavItems,
        ),
      ),
    );
  }
}
