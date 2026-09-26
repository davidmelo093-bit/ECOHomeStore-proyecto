import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/products_screen.dart';
import 'screens/chat_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? _token;
  String _username = '';

  void _onLoginSuccess(String token, String username) {
    setState(() {
      _token = token;
      _username = username;
    });
  }

  void _logout() {
    setState(() {
      _token = null;
      _username = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Store App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _token == null
          ? LoginScreen(onLoginSuccess: _onLoginSuccess)
          : _HomeShell(
              token: _token!,
              username: _username,
              onLogout: _logout,
            ),
    );
  }
}

/// Shell principal post-login: TabBar con Productos y Chat.
class _HomeShell extends StatefulWidget {
  final String token;
  final String username;
  final VoidCallback onLogout;

  const _HomeShell({
    required this.token,
    required this.username,
    required this.onLogout,
  });

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ProductsScreen(
        token: widget.token,
        username: widget.username,
        onLogout: widget.onLogout,
      ),
      ChatScreen(
        token: widget.token,
        username: widget.username,
      ),
    ];

    return Scaffold(
      body: tabs[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Productos',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}
