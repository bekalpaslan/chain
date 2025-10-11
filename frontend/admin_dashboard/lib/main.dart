import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/dashboard_provider.dart';
import 'screens/login_screen.dart';
import 'screens/project_board_screen.dart';
import 'screens/project_health_screen.dart';
import 'theme/dark_mystique_theme.dart';

void main() {
  runApp(const TheChainAdminDashboard());
}

class TheChainAdminDashboard extends StatelessWidget {
  const TheChainAdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'The Chain - Admin Dashboard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: DarkMystiqueTheme.mysticViolet,
          scaffoldBackgroundColor: DarkMystiqueTheme.deepVoid,
          colorScheme: const ColorScheme.dark(
            primary: DarkMystiqueTheme.mysticViolet,
            secondary: DarkMystiqueTheme.ghostCyan,
            surface: DarkMystiqueTheme.shadowPurple,
            error: DarkMystiqueTheme.errorPulse,
          ),
          fontFamily: 'Roboto',
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const ProjectBoardScreen(),
          '/health': (context) => const ProjectHealthScreen(),
        },
      ),
    );
  }
}
