import 'package:flutter/material.dart';
import '../theme/dark_mystique_theme.dart';
import '../widgets/mystique_components.dart';
import '../api/api_client.dart';
import '../utils/storage_helper.dart';

/// Dark Mystique Login Screen
///
/// Features:
/// - Deep void gradient background
/// - Chain link decorations
/// - Glowing mystical input fields
/// - Animated purple glow effects
/// - Ethereal typography
class MystiqueLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const MystiqueLoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

  @override
  State<MystiqueLoginScreen> createState() =>
      _MystiqueLoginScreenState();
}

class _MystiqueLoginScreenState extends State<MystiqueLoginScreen>
    with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  late AnimationController _bgAnimationController;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);
    _bgAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bgAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _bgAnimationController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final authResponse = await _apiClient.login(
        _usernameController.text.trim(),
        _passwordController.text,
      );

      await StorageHelper.saveAccessToken(authResponse.tokens.accessToken);
      await StorageHelper.saveRefreshToken(authResponse.tokens.refreshToken);
      await StorageHelper.saveUserId(authResponse.userId);

      if (mounted) {
        widget.onLoginSuccess();
      }
    } catch (e) {
      final errorMsg = e.toString();
      setState(() {
        if (errorMsg.contains('USER_NOT_FOUND')) {
          _error = 'Username not found in The Chain.';
        } else if (errorMsg.contains('INVALID_PASSWORD')) {
          _error = 'Invalid credentials. Access denied.';
        } else {
          _error = 'Connection to The Chain failed: $errorMsg';
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgAnimation,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  DarkMystiqueTheme.deepVoid,
                  DarkMystiqueTheme.voidSecondary,
                  DarkMystiqueTheme.shadowPurple,
                ],
                stops: [
                  0.0,
                  0.5 + (_bgAnimation.value * 0.2),
                  1.0,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Chain link decorations (background)
                Positioned(
                  top: -40,
                  right: -40,
                  child: Opacity(
                    opacity: 0.05,
                    child: ChainLinkDecoration(
                      size: 200,
                      color: DarkMystiqueTheme.mysticViolet,
                      opacity: 1.0,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: -60,
                  child: Opacity(
                    opacity: 0.05,
                    child: ChainLinkDecoration(
                      size: 250,
                      color: DarkMystiqueTheme.ghostCyan,
                      opacity: 1.0,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.4,
                  right: 50,
                  child: Opacity(
                    opacity: 0.03,
                    child: ChainLinkDecoration(
                      size: 150,
                      color: DarkMystiqueTheme.etherealPurple,
                      opacity: 1.0,
                    ),
                  ),
                ),
                // Main content
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 450),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(),
                            const SizedBox(height: 48),
                            _buildLoginCard(),
                            const SizedBox(height: 24),
                            _buildInvitationInfo(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Chain icon with glow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                DarkMystiqueTheme.mysticViolet.withValues(alpha: 0.3),
                Colors.transparent,
              ],
            ),
            boxShadow: DarkMystiqueTheme.purpleGlow,
          ),
          child: const Icon(
            Icons.link,
            size: 48,
            color: DarkMystiqueTheme.etherealPurple,
          ),
        ),
        const SizedBox(height: 24),
        // Title with mystical styling
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              DarkMystiqueTheme.etherealPurple,
              DarkMystiqueTheme.mysticViolet,
            ],
          ).createShader(bounds),
          child: const Text(
            'THE CHAIN',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w300,
              letterSpacing: 8.0,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Enter the mystical network',
          style: TextStyle(
            fontSize: 14,
            color: DarkMystiqueTheme.textMuted,
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return MystiqueCard(
      elevated: true,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            const Text(
              'Access Portal',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                color: DarkMystiqueTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Authenticate your identity',
              style: TextStyle(
                fontSize: 12,
                color: DarkMystiqueTheme.textMuted,
                letterSpacing: 0.75,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Error message
            if (_error != null) ...[
              MystiqueAlert(
                message: _error!,
                type: MystiqueAlertType.error,
              ),
              const SizedBox(height: 24),
            ],

            // Username field
            MystiqueTextField(
              controller: _usernameController,
              label: 'Username',
              hint: 'your_username',
              prefixIcon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username required';
                }
                if (value.length < 3) {
                  return 'Minimum 3 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Password field
            MystiqueTextField(
              controller: _passwordController,
              label: 'Password',
              hint: 'Your secret passphrase',
              prefixIcon: Icons.lock_outline,
              suffixIcon:
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
              onSuffixIconTap: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password required';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),

            // Login button
            MystiqueButton(
              text: 'ENTER THE CHAIN',
              onPressed: _login,
              loading: _loading,
              icon: Icons.login,
              minimumSize: const Size(double.infinity, 56),
            ),
            const SizedBox(height: 16),

            // Forgot password
            TextButton(
              onPressed: () {
                // TODO: Implement password reset
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Password recovery coming soon'),
                    backgroundColor: DarkMystiqueTheme.shadowPurple,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Forgotten your credentials?',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationInfo() {
    return MystiqueCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DarkMystiqueTheme.warningAura.withValues(alpha: 0.2),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: DarkMystiqueTheme.warningAura,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Invitation Required',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: DarkMystiqueTheme.textPrimary,
                    letterSpacing: 0.75,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The Chain is an exclusive network. You must possess a valid invitation ticket from an existing member to join.',
            style: TextStyle(
              fontSize: 12,
              color: DarkMystiqueTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DarkMystiqueTheme.twilightGray,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: DarkMystiqueTheme.ghostCyan.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.qr_code_scanner,
                  size: 14,
                  color: DarkMystiqueTheme.ghostCyan,
                ),
                SizedBox(width: 6),
                Text(
                  'Scan QR ticket to register',
                  style: TextStyle(
                    fontSize: 11,
                    color: DarkMystiqueTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
