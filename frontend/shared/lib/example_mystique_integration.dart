// Example Integration Guide for Dark Mystique Theme
//
// This file demonstrates how to integrate the Dark Mystique design system
// into your existing Flutter apps (private-app and public-app).

import 'package:flutter/material.dart';
import 'theme/dark_mystique_theme.dart';
import 'widgets/mystique_components.dart';
import 'screens/mystique_stats_screen.dart';

// ============================================================================
// STEP 1: Update main.dart to use Dark Mystique Theme
// ============================================================================

class ExampleAppWithMystiqueTheme extends StatelessWidget {
  const ExampleAppWithMystiqueTheme({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Chain',
      // Apply the dark mystique theme
      theme: DarkMystiqueTheme.theme,
      // Optional: Set dark mode
      themeMode: ThemeMode.dark,
      home: const ExampleHomePage(),
    );
  }
}

// ============================================================================
// STEP 2: Transform Existing Login Page
// ============================================================================

/// Replace your existing LoginPage with MystiqueLoginScreen
///
/// Before:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => LoginPage(),
/// ));
///
/// After:
/// Navigator.push(context, MaterialPageRoute(
///   builder: (_) => MystiqueLoginScreen(
///     onLoginSuccess: () {
///       Navigator.pushReplacement(context,
///         MaterialPageRoute(builder: (_) => DashboardPage()));
///     },
///   ),
/// ));

// ============================================================================
// STEP 3: Transform Existing Landing/Stats Page
// ============================================================================

/// Replace your existing stats page with MystiqueStatsScreen
///
/// Simply use:
/// home: const MystiqueStatsScreen()

// ============================================================================
// STEP 4: Update Existing Components with Mystique Components
// ============================================================================

class BeforeAndAfterExamples extends StatelessWidget {
  const BeforeAndAfterExamples({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ===============================================
            // EXAMPLE 1: Card Transformation
            // ===============================================
            const Text('BEFORE (Standard Card):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildBeforeCard(),
            const SizedBox(height: 24),
            const Text('AFTER (Mystique Card):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildAfterCard(),

            const SizedBox(height: 48),

            // ===============================================
            // EXAMPLE 2: Button Transformation
            // ===============================================
            const Text('BEFORE (Standard Button):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildBeforeButton(),
            const SizedBox(height: 24),
            const Text('AFTER (Mystique Button):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildAfterButton(),

            const SizedBox(height: 48),

            // ===============================================
            // EXAMPLE 3: Text Field Transformation
            // ===============================================
            const Text('BEFORE (Standard TextField):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildBeforeTextField(),
            const SizedBox(height: 24),
            const Text('AFTER (Mystique TextField):',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildAfterTextField(),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Card Examples
  // ---------------------------------------------------------------------------

  Widget _buildBeforeCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.people, size: 48),
            const SizedBox(height: 16),
            const Text('1,234', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text('Total Users', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildAfterCard() {
    return const MystiqueStatCard(
      title: 'TOTAL USERS',
      value: '1,234',
      icon: Icons.people_outline,
      accentColor: DarkMystiqueTheme.mysticViolet,
      subtitle: 'In the network',
    );
  }

  // ---------------------------------------------------------------------------
  // Button Examples
  // ---------------------------------------------------------------------------

  Widget _buildBeforeButton() {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Text('Login'),
    );
  }

  Widget _buildAfterButton() {
    return MystiqueButton(
      text: 'ENTER THE CHAIN',
      onPressed: () {},
      icon: Icons.login,
      minimumSize: const Size(double.infinity, 56),
    );
  }

  // ---------------------------------------------------------------------------
  // TextField Examples
  // ---------------------------------------------------------------------------

  Widget _buildBeforeTextField() {
    return const TextField(
      decoration: InputDecoration(
        labelText: 'Username',
        hintText: 'your_username',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAfterTextField() {
    return MystiqueTextField(
      label: 'Username',
      hint: 'your_username',
      prefixIcon: Icons.person_outline,
    );
  }
}

// ============================================================================
// STEP 5: Add Background Decorations
// ============================================================================

class ExamplePageWithDecorations extends StatelessWidget {
  const ExamplePageWithDecorations({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Add gradient background
        decoration: BoxDecoration(
          gradient: DarkMystiqueTheme.voidGradient,
        ),
        child: Stack(
          children: [
            // Add chain link decorations
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

            // Your content
            SafeArea(
              child: Center(
                child: MystiqueCard(
                  elevated: true,
                  child: const Text('Your Content Here'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STEP 6: Example Dashboard with Mystique Theme
// ============================================================================

class ExampleMystiqueDashboard extends StatelessWidget {
  const ExampleMystiqueDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DASHBOARD'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: DarkMystiqueTheme.voidGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header with glowing icon
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
                  Icons.person,
                  size: 48,
                  color: DarkMystiqueTheme.etherealPurple,
                ),
              ),

              const SizedBox(height: 24),

              // Username with gradient
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    DarkMystiqueTheme.etherealPurple,
                    DarkMystiqueTheme.mysticViolet,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'JOHN DOE',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 4.0,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Member #42 • Chain Key: ABC123',
                style: TextStyle(
                  fontSize: 12,
                  color: DarkMystiqueTheme.textMuted,
                  letterSpacing: 1.0,
                ),
              ),

              const SizedBox(height: 48),

              // User info card
              MystiqueCard(
                elevated: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildInfoRow('Status', 'ACTIVE', Icons.check_circle,
                        DarkMystiqueTheme.successGlow),
                    const SizedBox(height: 16),
                    _buildInfoRow('Position', '#42', Icons.tag,
                        DarkMystiqueTheme.mysticViolet),
                    const SizedBox(height: 16),
                    _buildInfoRow('Invites Sent', '3', Icons.send,
                        DarkMystiqueTheme.ghostCyan),
                    const SizedBox(height: 16),
                    _buildInfoRow('Wasted Tickets', '0', Icons.delete,
                        DarkMystiqueTheme.textMuted),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Action button
              MystiqueButton(
                text: 'GENERATE INVITE',
                onPressed: () {},
                icon: Icons.add_link,
                minimumSize: const Size(double.infinity, 56),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.2),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: DarkMystiqueTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// STEP 7: Example Alert/Error Handling
// ============================================================================

class ExampleAlertUsage extends StatelessWidget {
  const ExampleAlertUsage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success alert
            const MystiqueAlert(
              message: 'Login successful! Welcome to The Chain.',
              type: MystiqueAlertType.success,
            ),
            const SizedBox(height: 16),

            // Warning alert
            const MystiqueAlert(
              message: 'Your invitation will expire in 24 hours.',
              type: MystiqueAlertType.warning,
            ),
            const SizedBox(height: 16),

            // Error alert
            MystiqueAlert(
              message: 'Connection failed. Please try again.',
              type: MystiqueAlertType.error,
              onDismiss: () {},
            ),
            const SizedBox(height: 16),

            // Info alert
            const MystiqueAlert(
              message: 'The Chain is invitation-only. Scan a QR code to join.',
              type: MystiqueAlertType.info,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// STEP 8: Example Loading States
// ============================================================================

class ExampleLoadingStates extends StatelessWidget {
  const ExampleLoadingStates({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mystique loading indicator
            MystiqueLoadingIndicator(
              message: 'Connecting to The Chain...',
              size: 50,
            ),
            SizedBox(height: 48),

            // Loading in button
            MystiqueButton(
              text: 'PROCESSING',
              loading: true,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// QUICK MIGRATION CHECKLIST
// ============================================================================

/// MIGRATION CHECKLIST:
///
/// [ ] 1. Import dark mystique theme
///     import 'package:thechain_shared/theme/dark_mystique_theme.dart';
///
/// [ ] 2. Apply theme to MaterialApp
///     theme: DarkMystiqueTheme.theme
///
/// [ ] 3. Replace login page
///     Use MystiqueLoginScreen instead of custom login
///
/// [ ] 4. Replace stats/landing page
///     Use MystiqueStatsScreen instead of custom landing
///
/// [ ] 5. Update cards
///     Card → MystiqueCard
///
/// [ ] 6. Update buttons
///     ElevatedButton → MystiqueButton
///
/// [ ] 7. Update text fields
///     TextFormField → MystiqueTextField
///
/// [ ] 8. Add background decorations
///     Add ChainLinkDecoration to major screens
///
/// [ ] 9. Add gradient backgrounds
///     Use DarkMystiqueTheme.voidGradient on screens
///
/// [ ] 10. Update alerts/errors
///     Use MystiqueAlert for all notifications
///
/// [ ] 11. Update loading states
///     Use MystiqueLoadingIndicator
///
/// [ ] 12. Test accessibility
///     Verify keyboard navigation and screen reader support

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MystiqueStatsScreen();
  }
}
