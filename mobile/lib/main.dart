import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_chain/core/config/app_router.dart';
import 'package:the_chain/core/config/theme.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ChainApp(),
    ),
  );
}

class ChainApp extends StatelessWidget {
  const ChainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'The Chain',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
