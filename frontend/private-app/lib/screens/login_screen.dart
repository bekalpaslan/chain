import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/utils/storage_helper.dart';

/// Dark Mystique themed login screen with floating orbs, purple gradients,
/// and glass morphism effects. Matches the visual design of login.html
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  // Form controllers and state
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Floating orbs animation
  final List<OrbAnimation> _orbs = [];
  late AnimationController _orbController;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeOrbs();
  }

  void _initializeAnimations() {
    // Fade-in animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );

    // Slide-up animation
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
  }

  void _initializeOrbs() {
    // Floating orbs animation (continuous loop)
    _orbController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    // Create 5 floating orbs with random properties
    final random = math.Random();
    for (int i = 0; i < 5; i++) {
      _orbs.add(OrbAnimation(
        size: 100 + random.nextDouble() * 200, // 100-300px
        left: random.nextDouble(), // 0-1 (fraction of screen width)
        top: random.nextDouble(), // 0-1 (fraction of screen height)
        duration: 15 + random.nextDouble() * 10, // 15-25 seconds
        delay: random.nextDouble() * 5, // 0-5 second delay
      ));
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _orbController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login submission with username/password authentication
  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call API with username/password
      final authResponse = await ApiClient().login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      // Save tokens using StorageHelper
      await StorageHelper.saveAccessToken(authResponse.tokens.accessToken);
      await StorageHelper.saveRefreshToken(authResponse.tokens.refreshToken);
      await StorageHelper.saveUserId(authResponse.userId);

      // Save username if "Remember me" is checked
      if (_rememberMe) {
        // TODO: Implement remember me functionality
      }

      // Navigate to intended route or dashboard
      if (mounted) {
        // Check if there's a redirect route in the arguments
        final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
        final redirectTo = args?['redirectTo'] as String?;

        // Navigate to the intended route or default to home
        Navigator.pushReplacementNamed(
          context,
          redirectTo ?? '/home',
        );
      }
    } catch (e) {
      // Show error message
      setState(() {
        _errorMessage = _getErrorMessage(e);
        _isLoading = false;
      });
    }
  }

  /// Convert exception to user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('invalid') || errorStr.contains('401')) {
      return 'Invalid username or password';
    } else if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'Network error. Please check your connection.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else {
      return 'Login failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      // Deep void background (#0A0A0F)
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Floating animated orbs (background layer)
          ..._buildFloatingOrbs(size),

          // Main content with fade and slide animations
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Logo and title section
                          _buildHeader(),

                          const SizedBox(height: 48),

                          // Login form card
                          _buildLoginCard(),

                          const SizedBox(height: 24),

                          // Footer text
                          _buildFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build floating orbs background animation
  List<Widget> _buildFloatingOrbs(Size screenSize) {
    return _orbs.map((orb) {
      return AnimatedBuilder(
        animation: _orbController,
        builder: (context, child) {
          // Calculate animated position using sine wave
          final progress = (_orbController.value + orb.delay) % 1.0;
          final x = orb.left * screenSize.width +
              math.sin(progress * 2 * math.pi) * 50;
          final y = orb.top * screenSize.height +
              math.cos(progress * 2 * math.pi) * 50;

          return Positioned(
            left: x,
            top: y,
            child: Container(
              width: orb.size,
              height: orb.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF7C3AED).withOpacity(0.15), // Purple-600
                    const Color(0xFF7C3AED).withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }

  /// Build header with logo and title
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo/Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C3AED), // Purple-600
                Color(0xFF5B21B6), // Purple-800
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Icon(
            Icons.link,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 24),

        // Title
        const Text(
          'The Chain',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Private Chain Management',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.6),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  /// Build login form card with glass morphism
  Widget _buildLoginCard() {
    return MystiqueCard(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card title
              const Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 24),

              // Error message alert
              if (_errorMessage != null) ...[
                MystiqueAlert(
                  message: _errorMessage!,
                  type: MystiqueAlertType.error,
                ),
                const SizedBox(height: 20),
              ],

              // Username field
              MystiqueTextField(
                controller: _usernameController,
                label: 'Username',
                hint: 'Enter your username',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Password field
              MystiqueTextField(
                controller: _passwordController,
                label: 'Password',
                hint: 'Enter your password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscurePassword,
                suffixIcon: _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                onSuffixIconTap: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Remember me checkbox
              _buildRememberMeCheckbox(),

              const SizedBox(height: 32),

              // Login button
              MystiqueButton(
                text: 'Sign In',
                onPressed: _isLoading ? null : _handleLogin,
                loading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build "Remember me" checkbox with custom Dark Mystique styling
  Widget _buildRememberMeCheckbox() {
    return Row(
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Theme(
            data: ThemeData(
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const Color(0xFF7C3AED); // Purple-600
                  }
                  return Colors.transparent;
                }),
                checkColor: WidgetStateProperty.all(Colors.white),
                side: const BorderSide(
                  color: Color(0xFF4B5563), // Gray-600
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            child: Checkbox(
              value: _rememberMe,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value ?? false;
                });
              },
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _rememberMe = !_rememberMe;
              });
            },
            child: Text(
              'Remember me',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build footer text
  Widget _buildFooter() {
    return Center(
      child: Text(
        '© 2025 The Chain. All rights reserved.',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.white.withOpacity(0.4),
        ),
      ),
    );
  }
}

/// Data class for floating orb animation properties
class OrbAnimation {
  final double size;
  final double left; // Fraction of screen width (0-1)
  final double top; // Fraction of screen height (0-1)
  final double duration; // Animation duration in seconds
  final double delay; // Animation delay offset (0-1)

  OrbAnimation({
    required this.size,
    required this.left,
    required this.top,
    required this.duration,
    required this.delay,
  });
}
