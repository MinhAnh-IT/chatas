import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/shared/widgets/refreshable_list_view.dart';
import 'package:chatas/shared/constants/refreshable_list_view_constants.dart';

void main() {
  group('RefreshableListView Widget Tests', () {
    testWidgets('displays loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: const [],
              onRefresh: () async {},
              isLoading: true,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error widget when errorMessage is provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const errorMessage = 'Test error message';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: const [],
              onRefresh: () async {},
              errorMessage: errorMessage,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Assert
      expect(
        find.text(
          '${RefreshableListViewConstants.defaultErrorPrefix}$errorMessage',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays empty widget when items list is empty', (
      WidgetTester tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: const [],
              onRefresh: () async {},
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Assert
      expect(
        find.text(RefreshableListViewConstants.defaultEmptyMessage),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.inbox_outlined), findsOneWidget);
    });

    testWidgets('displays custom empty widget when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const customEmptyWidget = Text('Custom empty message');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: const [],
              onRefresh: () async {},
              emptyWidget: customEmptyWidget,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Custom empty message'), findsOneWidget);
      expect(
        find.text(RefreshableListViewConstants.defaultEmptyMessage),
        findsNothing,
      );
    });

    testWidgets('displays list items when items are provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const items = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: items,
              onRefresh: () async {},
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Assert
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('calls onRefresh when pull to refresh is triggered', (
      WidgetTester tester,
    ) async {
      // Arrange
      var refreshCalled = false;
      const items = ['Item 1'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: items,
              onRefresh: () async {
                refreshCalled = true;
              },
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Act
      await tester.fling(find.text('Item 1'), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Assert
      expect(refreshCalled, isTrue);
    });

    testWidgets('calls onRetry when retry button is pressed in error state', (
      WidgetTester tester,
    ) async {
      // Arrange
      var retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: const [],
              onRefresh: () async {},
              errorMessage: 'Test error',
              onRetry: () {
                retryCalled = true;
              },
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(
        find.text(RefreshableListViewConstants.defaultRetryButtonText),
      );
      await tester.pump();

      // Assert
      expect(retryCalled, isTrue);
    });

    testWidgets('uses custom scroll controller when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      final scrollController = ScrollController();
      final items = List.generate(
        20,
        (index) => 'Item ${index + 1}',
      ); // More items to enable scrolling

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: items,
              onRefresh: () async {},
              scrollController: scrollController,
              itemBuilder: (context, item, index) =>
                  SizedBox(height: 100, child: Text(item)),
            ),
          ),
        ),
      );

      // Assert - Check that the ListView is using our controller
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.controller, equals(scrollController));

      // Cleanup
      scrollController.dispose();
    });

    testWidgets('applies custom padding when provided', (
      WidgetTester tester,
    ) async {
      // Arrange
      const customPadding = EdgeInsets.all(32.0);
      const items = ['Item 1'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshableListView<String>(
              items: items,
              onRefresh: () async {},
              padding: customPadding,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Assert
      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, equals(customPadding));
    });
  });
}
