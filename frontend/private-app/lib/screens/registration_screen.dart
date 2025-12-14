import 'package:flutter/material.dart';
import 'package:thechain_shared/theme/dark_mystique_theme.dart';
import 'package:thechain_shared/widgets/mystique_components.dart';
import 'package:thechain_shared/api/api_client.dart';
import 'package:thechain_shared/utils/storage_helper.dart';

/// Registration screen for new users joining via QR code invitation
/// Displays inviter info and collects user credentials
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();

  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    if (value.length < 3 || value.length > 20) {
      return 'Username must be 3-20 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Only letters, numbers, and underscores allowed';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateDisplayName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length < 3 || value.length > 50) {
      return 'Display name must be 3-50 characters';
    }
    return null;
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final ticketId = args['ticketId'] as String;
    final ticketSignature = args['ticketSignature'] as String;

    setState(() => _isLoading = true);

    try {
      final response = await ApiClient().register(
        ticketId: ticketId,
        ticketSignature: ticketSignature,
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      // Save tokens
      await StorageHelper.saveAccessToken(response.tokens.accessToken);
      await StorageHelper.saveRefreshToken(response.tokens.refreshToken);
      await StorageHelper.saveUserId(response.userId.toString());

      if (!mounted) return;

      // Show success and navigate to home
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to The Chain, ${response.displayName}!'),
          backgroundColor: DarkMystiqueTheme.successGlow,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: ${e.toString()}'),
          backgroundColor: DarkMystiqueTheme.errorPulse,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Default values if args are missing (for testing)
    final inviterName = args?['inviterName'] as String? ?? 'Unknown';
    final inviterChainKey = args?['inviterChainKey'] as String? ?? 'N/A';
    final inviterPosition = args?['inviterPosition'] as int? ?? 0;
    final yourFuturePosition = args?['yourFuturePosition'] as int? ?? 0;

    return Scaffold(
      backgroundColor: DarkMystiqueTheme.deepVoid,
      appBar: AppBar(
        backgroundColor: DarkMystiqueTheme.shadowPurple.withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: DarkMystiqueTheme.etherealPurple),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Join The Chain',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Inviter Info Card
                _buildInviterCard(inviterName, inviterChainKey, inviterPosition, yourFuturePosition),

                const SizedBox(height: 32),

                // Section header
                _buildSectionHeader('Create Your Account', Icons.person_add),
                const SizedBox(height: 8),
                Text(
                  'Complete the form below to join The Chain',
                  style: TextStyle(
                    color: DarkMystiqueTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 24),

                // Username field
                _buildTextField(
                  controller: _usernameController,
                  label: 'Username',
                  hint: 'Choose a unique username',
                  icon: Icons.person_outline,
                  validator: _validateUsername,
                ),
                const SizedBox(height: 20),

                // Password field
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Enter a secure password',
                  icon: Icons.lock_outline,
                  obscureText: !_passwordVisible,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible ? Icons.visibility_off : Icons.visibility,
                      color: DarkMystiqueTheme.textMuted,
                    ),
                    onPressed: () => setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm Password field
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  icon: Icons.lock_outline,
                  obscureText: !_confirmPasswordVisible,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _confirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                      color: DarkMystiqueTheme.textMuted,
                    ),
                    onPressed: () => setState(() => _confirmPasswordVisible = !_confirmPasswordVisible),
                  ),
                ),
                const SizedBox(height: 20),

                // Display Name field (optional)
                _buildTextField(
                  controller: _displayNameController,
                  label: 'Display Name (Optional)',
                  hint: 'How others will see you',
                  icon: Icons.badge_outlined,
                  validator: _validateDisplayName,
                ),
                const SizedBox(height: 32),

                // Join Button
                MystiqueButton(
                  text: _isLoading ? 'Joining...' : 'Join The Chain',
                  icon: Icons.link,
                  loading: _isLoading,
                  onPressed: _isLoading ? null : _handleRegistration,
                ),
                const SizedBox(height: 16),

                // Info text
                _buildInfoBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInviterCard(String name, String chainKey, int position, int futurePosition) {
    return MystiqueCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: DarkMystiqueTheme.ghostCyan,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: DarkMystiqueTheme.ghostCyan.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Invited by',
                style: TextStyle(
                  color: DarkMystiqueTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: DarkMystiqueTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.link, size: 16, color: DarkMystiqueTheme.etherealPurple),
              const SizedBox(width: 8),
              Text(
                chainKey,
                style: TextStyle(
                  color: DarkMystiqueTheme.etherealPurple,
                  fontSize: 13,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.tag, size: 16, color: DarkMystiqueTheme.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Position #$position',
                style: TextStyle(
                  color: DarkMystiqueTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  DarkMystiqueTheme.ghostCyan.withOpacity(0.15),
                  DarkMystiqueTheme.mysticViolet.withOpacity(0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DarkMystiqueTheme.ghostCyan.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.stars, color: DarkMystiqueTheme.ghostCyan, size: 28),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Future Position',
                      style: TextStyle(
                        color: DarkMystiqueTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '#$futurePosition',
                      style: TextStyle(
                        color: DarkMystiqueTheme.ghostCyan,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: DarkMystiqueTheme.etherealPurple, size: 20),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: DarkMystiqueTheme.etherealPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      enabled: !_isLoading,
      style: const TextStyle(color: DarkMystiqueTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: DarkMystiqueTheme.textSecondary),
        hintStyle: TextStyle(color: DarkMystiqueTheme.textMuted),
        prefixIcon: Icon(icon, color: DarkMystiqueTheme.etherealPurple),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: DarkMystiqueTheme.shadowPurple,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DarkMystiqueTheme.mysticViolet.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: DarkMystiqueTheme.mysticViolet.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkMystiqueTheme.etherealPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: DarkMystiqueTheme.errorPulse),
        ),
      ),
    );
  }

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DarkMystiqueTheme.shadowPurple.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: DarkMystiqueTheme.mysticViolet.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: DarkMystiqueTheme.etherealPurple,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'By joining, you become part of an exclusive chain. Your position is permanent and unique.',
              style: TextStyle(
                color: DarkMystiqueTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
