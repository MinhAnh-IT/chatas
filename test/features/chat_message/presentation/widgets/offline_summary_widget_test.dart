import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/features/chat_message/presentation/widgets/offline_summary_widget.dart';
import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';

import '../../../../shared/test_helpers.dart';

void main() {
  group('OfflineSummaryWidget', () {
    setUp(() {
      TestOnlineStatusService.setup();
    });

    tearDown(() {
      TestOnlineStatusService.reset();
    });

    testWidgets('should display summary text and title', (
      WidgetTester tester,
    ) async {
      const testSummary = 'This is a test summary for offline messages.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OfflineSummaryWidget(summary: testSummary)),
        ),
      );

      expect(
        find.text(ChatMessagePageConstants.offlineSummaryDialogTitle),
        findsOneWidget,
      );
      expect(find.text(testSummary), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('should show truncated summary by default for long text', (
      WidgetTester tester,
    ) async {
      const longSummary =
          'This is a very long summary text that should be truncated by default because it exceeds the maximum length limit for the initial display. This text continues to be very long and should trigger the truncation mechanism.';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OfflineSummaryWidget(summary: longSummary)),
        ),
      );

      // Should show "Show more" button for long text
      expect(find.text(ChatMessagePageConstants.showMore), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);

      // Should not show the full text initially
      expect(find.text(longSummary), findsNothing);
    });

    testWidgets('should expand and collapse summary when tapped', (
      WidgetTester tester,
    ) async {
      const longSummary =
          'This is a very long summary text that should be truncated by default because it exceeds the maximum length limit for the initial display. This text continues to be very long and should trigger the truncation mechanism.';
      bool isExpanded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: OfflineSummaryWidget(
                  summary: longSummary,
                  isExpanded: isExpanded,
                  onExpand: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                ),
              );
            },
          ),
        ),
      );

      // Initially collapsed
      expect(find.text(ChatMessagePageConstants.showMore), findsOneWidget);

      // Tap to expand
      await tester.tap(find.text(ChatMessagePageConstants.showMore));
      await tester.pumpAndSettle();

      // Should show "Show less" button
      expect(find.text(ChatMessagePageConstants.showLess), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
    });

    testWidgets('should call onDismiss when close button is tapped', (
      WidgetTester tester,
    ) async {
      bool dismissCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineSummaryWidget(
              summary: 'Test summary',
              onDismiss: () {
                dismissCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissCalled, isTrue);
    });

    testWidgets('should not show close button when onDismiss is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OfflineSummaryWidget(summary: 'Test summary')),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });
  });

  group('OfflineSummaryLoadingWidget', () {
    testWidgets('should display loading indicator and text', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: OfflineSummaryLoadingWidget())),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        find.text(ChatMessagePageConstants.offlineSummaryLoading),
        findsOneWidget,
      );
    });
  });

  group('OfflineSummaryErrorWidget', () {
    testWidgets('should display error message and title', (
      WidgetTester tester,
    ) async {
      const errorMessage = 'Failed to generate summary';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OfflineSummaryErrorWidget(error: errorMessage)),
        ),
      );

      expect(
        find.text(ChatMessagePageConstants.offlineSummaryErrorTitle),
        findsOneWidget,
      );
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should call onRetry when retry button is tapped', (
      WidgetTester tester,
    ) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineSummaryErrorWidget(
              error: 'Test error',
              onRetry: () {
                retryCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text(ChatMessagePageConstants.retryButton));
      await tester.pump();

      expect(retryCalled, isTrue);
    });

    testWidgets('should call onDismiss when close button is tapped', (
      WidgetTester tester,
    ) async {
      bool dismissCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineSummaryErrorWidget(
              error: 'Test error',
              onDismiss: () {
                dismissCalled = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissCalled, isTrue);
    });

    testWidgets('should not show retry button when onRetry is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: OfflineSummaryErrorWidget(error: 'Test error')),
        ),
      );

      expect(find.text(ChatMessagePageConstants.retryButton), findsNothing);
    });
  });
}
