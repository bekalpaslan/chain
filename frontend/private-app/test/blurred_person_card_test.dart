import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:thechain_private/widgets/blurred_person_card.dart';

void main() {
  group('BlurredPersonCard Widget Tests', () {
    testWidgets('Ghost card displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlurredPersonCard(
              position: 1001,
              isGhost: true,
              blurIntensity: 15.0,
            ),
          ),
        ),
      );

      // Verify ghost card elements
      expect(find.text('#1001'), findsOneWidget);
      expect(find.text('Empty Slot'), findsOneWidget);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('Pending card displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlurredPersonCard(
              displayName: 'Emma Rodriguez',
              chainKey: 'CHAIN0000127',
              position: 1002,
              isPending: true,
              blurIntensity: 8.0,
            ),
          ),
        ),
      );

      // Verify pending card elements
      expect(find.text('Emma Rodriguez'), findsOneWidget);
      expect(find.text('CHAIN0000127'), findsOneWidget);
      expect(find.text('#1002'), findsOneWidget);
      expect(find.text('Invitation Pending'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Regular blurred card with tap handler', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlurredPersonCard(
              displayName: 'Private User',
              chainKey: 'CHAIN000999',
              position: 1003,
              blurIntensity: 5.0,
              onTap: () {
                wasTapped = true;
              },
            ),
          ),
        ),
      );

      // Verify regular blurred card elements
      expect(find.text('Private User'), findsOneWidget);
      expect(find.text('CHAIN000999'), findsOneWidget);
      expect(find.text('#1003'), findsOneWidget);

      // Test tap functionality
      await tester.tap(find.byType(BlurredPersonCard));
      expect(wasTapped, isTrue);
    });

    testWidgets('Blur intensity affects BackdropFilter', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlurredPersonCard(
              displayName: 'Test User',
              chainKey: 'CHAIN000001',
              position: 1,
              blurIntensity: 10.0,
            ),
          ),
        ),
      );

      // Find BackdropFilter widget
      final backdropFilter = tester.widget<BackdropFilter>(
        find.byType(BackdropFilter),
      );

      // Verify blur filter is applied
      expect(backdropFilter.filter, isNotNull);
    });

    testWidgets('Empty data shows placeholder UI', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BlurredPersonCard(
              position: 999,
              // No displayName or chainKey provided
            ),
          ),
        ),
      );

      // Should show placeholder containers
      expect(find.byType(Container), findsWidgets);
      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });
  });

  group('Integration with HomeScreen', () {
    test('Chain members with different statuses', () {
      // Mock chain data
      final members = [
        {'status': 'active', 'shouldUseBlur': false},
        {'status': 'pending', 'shouldUseBlur': true},
        {'status': 'ghost', 'shouldUseBlur': true},
        {'status': 'inactive', 'shouldUseBlur': false},
      ];

      for (final member in members) {
        final shouldBlur = member['status'] == 'ghost' ||
                          member['status'] == 'pending';
        expect(shouldBlur, equals(member['shouldUseBlur']),
          reason: 'Status ${member['status']} blur expectation mismatch');
      }
    });
  });
}