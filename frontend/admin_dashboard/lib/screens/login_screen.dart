import 'package:flutter/material.dart';
import '../widgets/mystique_components.dart';
import '../theme/dark_mystique_theme.dart';

/// Beautiful login screen with Mystique Dark theme
///
/// Features:
/// - Animated gradient background
/// - Glass-morphism effect on login card
/// - Mystique-styled input fields
/// - Smooth hover and focus animations
/// - Full keyboard accessibility
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    // Animated background gradient
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual authentication
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Navigate to dashboard on success
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Invalid email or password. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(
                  _backgroundAnimation.value * 0.5 - 0.25,
                  _backgroundAnimation.value * 0.5 - 0.25,
                ),
                radius: 1.5,
                colors: [
                  DarkMystiqueTheme.mysticViolet.withValues(alpha: 0.3),
                  DarkMystiqueTheme.deepVoid,
                  DarkMystiqueTheme.shadowPurple,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
            child: child,
          );
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo and Title
                    _buildHeader(),

                    const SizedBox(height: 48),

                    // Login Form Card
                    MystiqueCard(
                      padding: const EdgeInsets.all(32),
                      elevated: true,
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Welcome Text
                            Text(
                              'Welcome Back',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: DarkMystiqueTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),

                            Text(
                              'Sign in to access your dashboard',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: DarkMystiqueTheme.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 32),

                            // Email Field
                            MystiqueTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: 'admin@thechain.com',
                              prefixIcon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 24),

                            // Password Field
                            MystiqueTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hint: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              suffixIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              onSuffixIconTap: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              obscureText: _obscurePassword,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: Implement forgot password
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: DarkMystiqueTheme.etherealPurple,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Error Message
                            if (_errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 24),
                                child: MystiqueAlert(
                                  message: _errorMessage!,
                                  type: MystiqueAlertType.error,
                                  onDismiss: () {
                                    setState(() {
                                      _errorMessage = null;
                                    });
                                  },
                                ),
                              ),

                            // Login Button
                            SizedBox(
                              width: double.infinity,
                              child: MystiqueButton(
                                text: _isLoading ? 'Signing In...' : 'Sign In',
                                onPressed: _isLoading ? null : _handleLogin,
                                variant: MystiqueButtonVariant.primary,
                                minimumSize: const Size(double.infinity, 56),
                                icon: _isLoading ? null : Icons.login,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Divider
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          DarkMystiqueTheme.etherealPurple.withValues(alpha: 0.3),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(
                                      color: DarkMystiqueTheme.textMuted,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          DarkMystiqueTheme.etherealPurple.withValues(alpha: 0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // SSO Button (Demo)
                            SizedBox(
                              width: double.infinity,
                              child: MystiqueButton(
                                text: 'Sign in with SSO',
                                onPressed: _isLoading ? null : () {
                                  // TODO: Implement SSO
                                },
                                variant: MystiqueButtonVariant.secondary,
                                minimumSize: const Size(double.infinity, 56),
                                icon: Icons.business,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo with glow effect
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: DarkMystiqueTheme.mysticGradient,
            boxShadow: DarkMystiqueTheme.purpleGlow,
          ),
          child: const Icon(
            Icons.dashboard,
            size: 40,
            color: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // Title
        Text(
          'The Chain',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = DarkMystiqueTheme.mysticGradient.createShader(
                const Rect.fromLTWH(0, 0, 200, 50),
              ),
          ),
        ),

        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Admin Dashboard',
          style: TextStyle(
            fontSize: 16,
            color: DarkMystiqueTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Text(
          'Protected by enterprise-grade security',
          style: TextStyle(
            color: DarkMystiqueTheme.textMuted,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 14,
              color: DarkMystiqueTheme.successGlow,
            ),
            const SizedBox(width: 4),
            Text(
              'SSL Encrypted',
              style: TextStyle(
                color: DarkMystiqueTheme.textMuted,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 16),
            Icon(
              Icons.verified_user,
              size: 14,
              color: DarkMystiqueTheme.successGlow,
            ),
            const SizedBox(width: 4),
            Text(
              'WCAG AA Compliant',
              style: TextStyle(
                color: DarkMystiqueTheme.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
