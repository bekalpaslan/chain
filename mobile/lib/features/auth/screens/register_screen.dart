import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:the_chain/core/providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? ticketId;

  const RegisterScreen({super.key, this.ticketId});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _shareLocation = false;
  bool _isLoading = false;

  Future<Position?> _getCurrentLocation() async {
    if (!_shareLocation) return null;

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }

      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        Position? position = await _getCurrentLocation();

        await ref.read(authProvider.notifier).register(
              username: _nameController.text.trim().isEmpty
                  ? 'Anonymous'
                  : _nameController.text.trim(),
              invitationTicket: widget.ticketId,
              latitude: position?.latitude,
              longitude: position?.longitude,
            );

        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join The Chain'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.link,
                size: 64,
                color: Colors.indigo,
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome to The Chain',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'You\'re about to join a global social experiment',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name (Optional)',
                  hintText: 'Leave empty for Anonymous',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    if (value.length > 50) {
                      return 'Name must be less than 50 characters';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: const Text('Share my location'),
                subtitle: const Text('Only city and country (optional)'),
                value: _shareLocation,
                onChanged: (value) {
                  setState(() => _shareLocation = value);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Join The Chain'),
              ),
              const SizedBox(height: 16),
              Text(
                'By joining, you agree to our Terms of Service',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
