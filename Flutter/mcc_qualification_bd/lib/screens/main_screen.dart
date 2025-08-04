import 'package:bread_and_butter/apis/api.dart';
import 'package:bread_and_butter/screens/create_menu_screen.dart';
import 'package:bread_and_butter/utils/snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:bread_and_butter/screens/menu_list_screen.dart';
import 'package:bread_and_butter/screens/home_screen.dart';
import 'package:bread_and_butter/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bread_and_butter/utils/theme_provider.dart';

enum ThemeMode { light, dark, system }

class MainScreen extends StatefulWidget {
  final String userId;

  const MainScreen({super.key, required this.userId});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String username = "";
  String role = "";
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Choose Theme'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildThemeOption(
                context,
                ThemeModeOption.light,
                'Light',
                Icons.wb_sunny,
              ),
              _buildThemeOption(
                context,
                ThemeModeOption.dark,
                'Dark',
                Icons.nights_stay,
              ),
              _buildThemeOption(
                context,
                ThemeModeOption.system,
                'System',
                Icons.settings,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    ThemeModeOption mode,
    String title,
    IconData icon,
  ) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isSelected = themeProvider.themeMode == mode;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
          ),
        ),
        trailing: isSelected
            ? Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        onTap: () {
          themeProvider.setThemeMode(mode);
          Navigator.of(context).pop();
          showSnackBar(context, 'Theme updated to ${title.toLowerCase()}');
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
      ),
    );
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      prefs.remove("token");
      prefs.remove("userId");
      showSnackBar(context, "Signed out successfully");

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
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
      await Future.delayed(const Duration(seconds: 2));

      if (username.isEmpty || role.isEmpty) {
        showSnackBar(context, "Failed to fetch user details: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final List<Widget> pages = [
      const HomeScreen(),
      MenuListScreen(userId: userId, role: role),
    ];
    if (role == 'admin') {
      pages.add(const CreateMenuScreen());
    }

    final List<BottomNavigationBarItem> bottomNavItems = [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.restaurant_menu),
        label: 'Menu',
      ),
    ];
    if (role == 'admin') {
      bottomNavItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
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
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.primary,
          ),
          title: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Hi, $username!',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                _getThemeIcon(themeProvider.themeMode),
                color: Theme.of(context).colorScheme.primary,
              ),
              tooltip: 'Change Theme',
              onPressed: _showThemeSelector,
            ),
            const SizedBox(width: 8),
          ],
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
        ),
        drawer: _buildDrawer(context, themeProvider),
        body: IndexedStack(index: _currentIndex, children: pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: bottomNavItems,
            selectedItemColor: Theme.of(context).colorScheme.primary,
            unselectedItemColor: Theme.of(
              context,
            ).colorScheme.onSurface.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            type: BottomNavigationBarType.fixed,
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(ThemeModeOption mode) {
    switch (mode) {
      case ThemeModeOption.light:
        return Icons.wb_sunny;
      case ThemeModeOption.dark:
        return Icons.nights_stay;
      case ThemeModeOption.system:
        return Icons.settings_display_outlined;
    }
  }

  Widget _buildDrawer(BuildContext context, ThemeProvider themeProvider) {
    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Hello, $username',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      role.toUpperCase(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildDrawerItem(context, Icons.home_rounded, 'Home', 0),
                _buildDrawerItem(
                  context,
                  Icons.restaurant_menu,
                  'Menu List',
                  1,
                ),
                if (role == 'admin')
                  _buildDrawerItem(
                    context,
                    Icons.admin_panel_settings,
                    'Admin Panel',
                    2,
                  ),
                const Divider(height: 32),
                ListTile(
                  leading: Icon(
                    _getThemeIcon(themeProvider.themeMode),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: const Text('Theme Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    _showThemeSelector();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _logout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: () {
          setState(() => _currentIndex = index);
          Navigator.pop(context);
        },
      ),
    );
  }
}
