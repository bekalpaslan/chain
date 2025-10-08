import 'package:go_router/go_router.dart';
import 'package:the_chain/features/auth/screens/splash_screen.dart';
import 'package:the_chain/features/auth/screens/scan_ticket_screen.dart';
import 'package:the_chain/features/auth/screens/register_screen.dart';
import 'package:the_chain/features/chain/screens/home_screen.dart';
import 'package:the_chain/features/ticket/screens/generate_ticket_screen.dart';
import 'package:the_chain/features/chain/screens/stats_screen.dart';
import 'package:the_chain/features/profile/screens/profile_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/scan',
        builder: (context, state) => const ScanTicketScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) {
          final ticketId = state.uri.queryParameters['ticketId'];
          return RegisterScreen(ticketId: ticketId);
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/generate-ticket',
        builder: (context, state) => const GenerateTicketScreen(),
      ),
      GoRoute(
        path: '/stats',
        builder: (context, state) => const StatsScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
