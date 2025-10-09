import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_public/main.dart';

void main() {
  testWidgets('Public app displays landing page', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: PublicApp()));

    // Verify that the app title is displayed
    expect(find.text('The Chain'), findsWidgets);

    // Verify that the landing page is shown
    expect(find.text('Welcome to The Chain'), findsOneWidget);
  });

  testWidgets('Landing page shows loading state', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const ProviderScope(child: PublicApp()));

    // Initially should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
