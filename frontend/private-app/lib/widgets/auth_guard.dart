import 'package:flutter/material.dart';
import 'package:thechain_shared/utils/storage_helper.dart';

/// Authentication guard widget that protects routes
/// Checks if user is authenticated before allowing access
class AuthGuard extends StatefulWidget {
  final Widget child;
  final String routeName;

  const AuthGuard({
    super.key,
    required this.child,
    required this.routeName,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      // Check for valid session
      final accessToken = await StorageHelper.getAccessToken();
      final userId = await StorageHelper.getUserId();

      if (mounted) {
        setState(() {
          _isAuthenticated = accessToken != null && userId != null;
          _isChecking = false;
        });

        // If not authenticated, redirect to login
        if (!_isAuthenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              // Store the intended route for redirect after login
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
                arguments: {'redirectTo': widget.routeName},
              );
            }
          });
        }
      }
    } catch (e) {
      // On error, redirect to login for safety
      if (mounted) {
        setState(() {
          _isAuthenticated = false;
          _isChecking = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.of(context).pushNamedAndRemoveUntil(
              '/login',
              (route) => false,
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      // Show loading while checking auth
      return Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: const Color(0xFF7C3AED),
              ),
              const SizedBox(height: 24),
              Text(
                'Verifying authentication...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      // Show brief loading state before redirect
      return const Scaffold(
        backgroundColor: Color(0xFF0A0A0F),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7C3AED),
          ),
        ),
      );
    }

    // User is authenticated, show the protected content
    return widget.child;
  }
}