import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_shared/thechain_shared.dart';

void main() {
  runApp(const ProviderScope(child: PrivateApp()));
}

class PrivateApp extends StatelessWidget {
  const PrivateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Chain - Dashboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final ApiClient _apiClient = ApiClient();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      // Get or generate device credentials
      final deviceId = await DeviceInfoHelper.getDeviceId();
      final fingerprint = await DeviceInfoHelper.getDeviceFingerprint();

      // Attempt login
      final authResponse = await _apiClient.login(deviceId, fingerprint);

      // Save tokens
      await StorageHelper.saveAccessToken(authResponse.tokens.accessToken);
      await StorageHelper.saveRefreshToken(authResponse.tokens.refreshToken);
      await StorageHelper.saveUserId(authResponse.userId);

      // Navigate to dashboard
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } catch (e) {
      final errorMsg = e.toString();
      setState(() {
        // Check if user needs to register
        if (errorMsg.contains('USER_NOT_FOUND') || errorMsg.contains('404')) {
          _error = 'No account found. Please register first.';
        } else {
          _error = errorMsg;
        }
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('The Chain - Login'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to The Chain',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 48),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    border: Border.all(color: Colors.orange),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _error!,
                        style: TextStyle(color: Colors.orange[900]),
                        textAlign: TextAlign.center,
                      ),
                      if (_error!.contains('register')) ...[
                        const SizedBox(height: 12),
                        Text(
                          'To join The Chain, you need an invitation ticket from an existing member.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(200, 48),
                ),
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login with Device'),
              ),
              const SizedBox(height: 16),
              Text(
                'Device-based login - no password needed',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  final ApiClient _apiClient = ApiClient();
  User? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final profile = await _apiClient.getUserProfile();

      setState(() {
        _profile = profile;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: _loading
            ? const CircularProgressIndicator()
            : _error != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  )
                : _buildProfile(),
      ),
    );
  }

  Widget _buildProfile() {
    if (_profile == null) return const Text('No profile data');

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            child: Text(
              _profile!.displayName[0].toUpperCase(),
              style: const TextStyle(fontSize: 32),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _profile!.displayName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Position: #${_profile!.position}'),
          Text('Chain Key: ${_profile!.chainKey}'),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Status: ${_profile!.status}'),
                  Text('Wasted Tickets: ${_profile!.wastedTicketsCount}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
