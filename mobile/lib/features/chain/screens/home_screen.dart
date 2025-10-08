import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:the_chain/core/providers/auth_provider.dart';
import 'package:the_chain/core/providers/chain_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await ref.read(chainStatsProvider.notifier).loadMyChainInfo();
  }

  Future<void> _refresh() async {
    await ref.read(chainStatsProvider.notifier).loadMyChainInfo();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final chainState = ref.watch(chainStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('The Chain'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: chainState.isLoading && chainState.myChainInfo == null
            ? const Center(child: CircularProgressIndicator())
            : chainState.error != null && chainState.myChainInfo == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Error: ${chainState.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            const Icon(Icons.link, size: 80, color: Colors.indigo),
                            const SizedBox(height: 24),
                            Text(
                              'Position #${chainState.myChainInfo?.chainPosition ?? authState.user?.chainPosition ?? '...'}',
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'You\'re connected in the global chain',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            if (chainState.myChainInfo?.username != null)
                              Text(
                                '@${chainState.myChainInfo!.username}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            if (chainState.myChainInfo?.locationCity != null ||
                                chainState.myChainInfo?.locationCountry != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      [
                                        chainState.myChainInfo?.locationCity,
                                        chainState.myChainInfo?.locationCountry,
                                      ].whereType<String>().join(', '),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 48),
                            ElevatedButton.icon(
                              onPressed: () => context.push('/generate-ticket'),
                              icon: const Icon(Icons.qr_code),
                              label: const Text('Generate Invitation'),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => context.push('/stats'),
                              icon: const Icon(Icons.bar_chart),
                              label: const Text('View Chain Stats'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
