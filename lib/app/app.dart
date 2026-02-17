import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/login_screen.dart';
import '../screens/main_app_screen.dart';

class App extends StatefulWidget {
  const App({super.key});

  // 🔹 Toggle theme
  static void toggleTheme(BuildContext context, bool isDark) {
    final state = context.findAncestorStateOfType<_AppState>();
    state?.toggleTheme(isDark);
  }

  // 🔹 Read current theme
  static bool isDarkMode(BuildContext context) {
    final state = context.findAncestorStateOfType<_AppState>();
    return state?.currentThemeMode ?? false;
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isDarkMode = false;

  bool get currentThemeMode => _isDarkMode;

  void toggleTheme(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'KrishiAI',
      theme: _isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData(useMaterial3: true, primarySwatch: Colors.green),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;

        if (session != null) {
          return const MainAppScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
