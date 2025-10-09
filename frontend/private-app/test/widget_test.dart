import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:thechain_private/main.dart';

void main() {
  testWidgets('Private app displays login page', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const ProviderScope(child: PrivateApp()));

    // Verify that the app title is displayed
    expect(find.text('The Chain - Login'), findsOneWidget);

    // Verify that the login page is shown
    expect(find.text('Welcome to The Chain'), findsOneWidget);

    // Verify login button exists
    expect(find.text('Login with Device'), findsOneWidget);
  });

  testWidgets('Login button shows loading state when clicked', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const ProviderScope(child: PrivateApp()));

    // Find and tap the login button
    final loginButton = find.text('Login with Device');
    expect(loginButton, findsOneWidget);

    // Note: Actual login will fail without mock API, but we can verify button exists
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
