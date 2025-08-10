import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chatas/shared/widgets/app_bar.dart';

void main() {
  group('CommonAppBar', () {
    testWidgets('should display title correctly', (tester) async {
      // arrange
      const title = 'Test Title';

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(appBar: const CommonAppBar(title: title)),
        ),
      );

      // assert
      expect(find.text(title), findsOneWidget);
    });

    testWidgets('should display default styling', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: CommonAppBar(title: 'Test')),
        ),
      );

      // assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Colors.blue));
      expect(appBar.elevation, equals(1.0));
      expect(appBar.title, isA<Text>());
    });

    testWidgets('should display custom leading widget', (tester) async {
      // arrange
      const leadingIcon = Icon(Icons.arrow_back, key: Key('leading'));

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            appBar: CommonAppBar(title: 'Test', leading: leadingIcon),
          ),
        ),
      );

      // assert
      expect(find.byKey(const Key('leading')), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should display custom actions', (tester) async {
      // arrange
      final actions = [
        IconButton(
          icon: const Icon(Icons.search, key: Key('search')),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, key: Key('menu')),
          onPressed: () {},
        ),
      ];

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CommonAppBar(title: 'Test', actions: actions),
          ),
        ),
      );

      // assert
      expect(find.byKey(const Key('search')), findsOneWidget);
      expect(find.byKey(const Key('menu')), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });

    testWidgets('should work without actions', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: CommonAppBar(title: 'Test')),
        ),
      );

      // assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.actions, isNull);
    });

    testWidgets('should work without leading widget', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: CommonAppBar(title: 'Test')),
        ),
      );

      // assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.leading, isNull);
    });

    testWidgets('should handle long titles properly', (tester) async {
      // arrange
      const longTitle =
          'This is a very long title that might overflow if not handled properly';

      // act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: CommonAppBar(title: longTitle)),
        ),
      );

      // assert
      expect(find.text(longTitle), findsOneWidget);
      expect(tester.takeException(), isNull); // No overflow exception
    });

    testWidgets('should handle empty title', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: CommonAppBar(title: '')),
        ),
      );

      // assert
      expect(find.text(''), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should maintain consistent styling across instances', (
      tester,
    ) async {
      // Test first instance
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: CommonAppBar(title: 'First')),
        ),
      );

      final firstAppBar = tester.widget<AppBar>(find.byType(AppBar));
      final firstBackgroundColor = firstAppBar.backgroundColor;
      final firstElevation = firstAppBar.elevation;

      // Test second instance
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(appBar: CommonAppBar(title: 'Second')),
        ),
      );

      final secondAppBar = tester.widget<AppBar>(find.byType(AppBar));

      // assert
      expect(secondAppBar.backgroundColor, equals(firstBackgroundColor));
      expect(secondAppBar.elevation, equals(firstElevation));
      expect(secondAppBar.backgroundColor, equals(Colors.blue));
    });

    testWidgets('should handle multiple action widgets', (tester) async {
      // arrange
      final manyActions = List.generate(
        5,
        (index) => IconButton(
          key: Key('action_$index'),
          icon: Icon(Icons.star, key: Key('star_$index')),
          onPressed: () {},
        ),
      );

      // act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: CommonAppBar(title: 'Many Actions', actions: manyActions),
          ),
        ),
      );

      // assert
      for (int i = 0; i < 5; i++) {
        expect(find.byKey(Key('action_$i')), findsOneWidget);
        expect(find.byKey(Key('star_$i')), findsOneWidget);
      }
    });

    testWidgets('should integrate well with Scaffold', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: const CommonAppBar(title: 'Integration Test'),
            body: const Center(child: Text('Body Content')),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // assert
      expect(find.text('Integration Test'), findsOneWidget);
      expect(find.text('Body Content'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byType(CommonAppBar), findsOneWidget);
    });
  });
}
