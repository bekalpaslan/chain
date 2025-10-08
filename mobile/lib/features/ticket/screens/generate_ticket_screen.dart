import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:the_chain/core/providers/ticket_provider.dart';

class GenerateTicketScreen extends ConsumerStatefulWidget {
  const GenerateTicketScreen({super.key});

  @override
  ConsumerState<GenerateTicketScreen> createState() => _GenerateTicketScreenState();
}

class _GenerateTicketScreenState extends ConsumerState<GenerateTicketScreen> {
  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  Future<void> _loadTicket() async {
    try {
      await ref.read(ticketProvider.notifier).generateTicket();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);

    return 'Expires in ${hours}h ${minutes}m';
  }

  Future<void> _shareTicket(String ticketCode) async {
    final deepLink = 'thechain://join?t=$ticketCode';
    await Clipboard.setData(ClipboardData(text: deepLink));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Link copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketState = ref.watch(ticketProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Invitation'),
      ),
      body: ticketState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ticketState.currentTicket == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Failed to generate ticket'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadTicket,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: QrImageView(
                              data: 'thechain://join?t=${ticketState.currentTicket!.ticketCode}',
                              version: QrVersions.auto,
                              size: 280,
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          _getTimeRemaining(ticketState.currentTicket!.expiresAt),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: ticketState.currentTicket!.isExpired
                                    ? Colors.red
                                    : Colors.orange,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Share with ONE person',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Status: ${ticketState.currentTicket!.status.name.toUpperCase()}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: ticketState.currentTicket!.isActive
                              ? () => _shareTicket(ticketState.currentTicket!.ticketCode)
                              : null,
                          icon: const Icon(Icons.share),
                          label: const Text('Copy Link'),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
