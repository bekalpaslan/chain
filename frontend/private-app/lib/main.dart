import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/thechain_shared.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart'; // Keep for backward compatibility
import 'theme/app_theme.dart';
import 'widgets/auth_guard.dart';

void main() {
  runApp(const ProviderScope(child: PrivateApp()));
}

class PrivateApp extends StatelessWidget {
  const PrivateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Chain - Dashboard',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const AuthCheckPage(), // Use auth check on startup
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const AuthGuard(
          routeName: '/home',
          child: DashboardScreen(),
        ),
        '/dashboard': (context) => const AuthGuard(
          routeName: '/dashboard',
          child: DashboardScreen(),
        ),
        '/chain': (context) => const AuthGuard(
          routeName: '/chain',
          child: HomeScreen(),
        ),
        '/notifications': (context) => const AuthGuard(
          routeName: '/notifications',
          child: Scaffold(body: Center(child: Text('Notifications'))),
        ),
        '/settings': (context) => const AuthGuard(
          routeName: '/settings',
          child: Scaffold(body: Center(child: Text('Settings'))),
        ),
        '/profile': (context) => const AuthGuard(
          routeName: '/profile',
          child: Scaffold(body: Center(child: Text('Profile'))),
        ),
        '/achievements': (context) => const AuthGuard(
          routeName: '/achievements',
          child: Scaffold(body: Center(child: Text('Achievements'))),
        ),
        '/generate-ticket': (context) => const AuthGuard(
          routeName: '/generate-ticket',
          child: Scaffold(body: Center(child: Text('Generate Ticket'))),
        ),
        '/active-ticket': (context) => const AuthGuard(
          routeName: '/active-ticket',
          child: Scaffold(body: Center(child: Text('Active Ticket'))),
        ),
      },
    );
  }
}

// Check for existing session on app startup
class AuthCheckPage extends StatefulWidget {
  const AuthCheckPage({super.key});

  @override
  State<AuthCheckPage> createState() => _AuthCheckPageState();
}

class _AuthCheckPageState extends State<AuthCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Wait a moment for the UI to render
    await Future.delayed(const Duration(milliseconds: 500));

    // Check if we have stored tokens
    final accessToken = await StorageHelper.getAccessToken();
    final userId = await StorageHelper.getUserId();

    if (mounted) {
      if (accessToken != null && userId != null) {
        // User has a session, go to dashboard
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardScreen()),
        );
      } else {
        // No session, go to login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Loading...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}

