import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/presentation/widgets/reply_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReplyPreview', () {
    late ChatMessage testMessage;

    setUp(() {
      testMessage = ChatMessage(
        id: 'test_message',
        chatThreadId: 'test_thread',
        senderId: 'sender_id',
        senderName: 'Test Sender',
        senderAvatarUrl: '',
        content: 'This is a test message content that is being replied to',
        sentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createWidgetUnderTest({
      required ChatMessage replyToMessage,
      VoidCallback? onCancel,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ReplyPreview(
            replyToMessage: replyToMessage,
            onCancel: onCancel ?? () {},
          ),
        ),
      );
    }

    testWidgets('displays replying to prefix with sender name', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(replyToMessage: testMessage),
      );

      // assert
      expect(
        find.text(
          '${ChatMessagePageConstants.replyingToPrefix} ${testMessage.senderName}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('displays message content', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(replyToMessage: testMessage),
      );

      // assert
      expect(find.text(testMessage.content), findsOneWidget);
    });

    testWidgets('displays close button', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(replyToMessage: testMessage),
      );

      // assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('calls onCancel when close button is tapped', (tester) async {
      // arrange
      bool cancelCalled = false;

      await tester.pumpWidget(
        createWidgetUnderTest(
          replyToMessage: testMessage,
          onCancel: () => cancelCalled = true,
        ),
      );

      // act
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      // assert
      expect(cancelCalled, isTrue);
    });

    testWidgets('truncates long content with ellipsis', (tester) async {
      // arrange
      final longMessage = ChatMessage(
        id: 'long_message',
        chatThreadId: 'test_thread',
        senderId: 'sender_id',
        senderName: 'Test Sender',
        senderAvatarUrl: '',
        content:
            'This is a very long message content that should be truncated when displayed in the reply preview widget because it exceeds the maximum length limit set for the preview display',
        sentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // act
      await tester.pumpWidget(
        createWidgetUnderTest(replyToMessage: longMessage),
      );

      // assert
      expect(find.textContaining('...'), findsOneWidget);
    });

    testWidgets('does not truncate short content', (tester) async {
      // arrange
      final shortMessage = ChatMessage(
        id: 'short_message',
        chatThreadId: 'test_thread',
        senderId: 'sender_id',
        senderName: 'Test Sender',
        senderAvatarUrl: '',
        content: 'Short message',
        sentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // act
      await tester.pumpWidget(
        createWidgetUnderTest(replyToMessage: shortMessage),
      );

      // assert
      expect(find.text('Short message'), findsOneWidget);
      expect(find.textContaining('...'), findsNothing);
    });

    testWidgets('has proper visual styling', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(replyToMessage: testMessage),
      );

      // assert - check for container with proper decoration
      final containerFinder = find.byType(Container).first;
      expect(containerFinder, findsOneWidget);

      final container = tester.widget<Container>(containerFinder);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.border, isNotNull);
    });

    testWidgets('close button has proper tooltip', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(replyToMessage: testMessage),
      );

      // assert
      final iconButtonFinder = find.byType(IconButton);
      expect(iconButtonFinder, findsOneWidget);

      final iconButton = tester.widget<IconButton>(iconButtonFinder);
      expect(
        iconButton.tooltip,
        equals(ChatMessagePageConstants.cancelReplyButton),
      );
    });
  });
}
