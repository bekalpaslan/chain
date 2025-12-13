import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/login_screen.dart';
import 'screens/landing_screen.dart';
import 'screens/public_stats_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/home_screen.dart'; // Keep for backward compatibility
import 'screens/ticket_view_screen.dart';
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
      title: 'The Chain',
      theme: AppTheme.darkTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      // Landing page as home - public, no auth required
      home: const LandingScreen(),
      routes: {
        // ========== Public routes (no auth required) ==========
        '/': (context) => const LandingScreen(),
        '/stats': (context) => const PublicStatsScreen(),
        '/login': (context) => const LoginScreen(),

        // ========== Protected routes (auth required) ==========
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
        '/ticket': (context) => const AuthGuard(
          routeName: '/ticket',
          child: TicketViewScreen(),
        ),
      },
    );
  }
}

