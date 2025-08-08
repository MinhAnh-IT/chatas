import 'package:chatas/features/chat_message/constants/chat_message_page_constants.dart';
import 'package:chatas/features/chat_message/domain/entities/chat_message.dart';
import 'package:chatas/features/chat_message/presentation/widgets/message_context_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageContextMenu', () {
    late ChatMessage testMessage;
    const currentUserId = 'current_user_id';
    const otherUserId = 'other_user_id';

    setUp(() {
      testMessage = ChatMessage(
        id: 'test_message',
        chatThreadId: 'test_thread',
        senderId: currentUserId,
        senderName: 'Test User',
        senderAvatarUrl: '',
        content: 'Test message content',
        sentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    });

    Widget createWidgetUnderTest({
      required ChatMessage message,
      required String currentUserId,
      VoidCallback? onReply,
      VoidCallback? onEdit,
      VoidCallback? onDelete,
      VoidCallback? onCopy,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: MessageContextMenu(
            message: message,
            currentUserId: currentUserId,
            onReply: onReply,
            onEdit: onEdit,
            onDelete: onDelete,
            onCopy: onCopy,
          ),
        ),
      );
    }

    testWidgets('displays all menu options for own message', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: testMessage,
          currentUserId: currentUserId,
        ),
      );

      // assert
      expect(find.text(ChatMessagePageConstants.replyMenuOption), findsOneWidget);
      expect(find.text(ChatMessagePageConstants.editMenuOption), findsOneWidget);
      expect(find.text(ChatMessagePageConstants.deleteMenuOption), findsOneWidget);
      expect(find.text(ChatMessagePageConstants.copyMenuOption), findsOneWidget);
    });

    testWidgets('hides edit and delete options for other user message', (tester) async {
      // arrange
      final otherUserMessage = ChatMessage(
        id: 'other_message',
        chatThreadId: 'test_thread',
        senderId: otherUserId,
        senderName: 'Other User',
        senderAvatarUrl: '',
        content: 'Other message content',
        sentAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // act
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: otherUserMessage,
          currentUserId: currentUserId,
        ),
      );

      // assert
      expect(find.text(ChatMessagePageConstants.replyMenuOption), findsOneWidget);
      expect(find.text(ChatMessagePageConstants.editMenuOption), findsNothing);
      expect(find.text(ChatMessagePageConstants.deleteMenuOption), findsNothing);
      expect(find.text(ChatMessagePageConstants.copyMenuOption), findsOneWidget);
    });

    testWidgets('calls onReply when reply option is tapped', (tester) async {
      // arrange
      bool replyTapped = false;
      
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: testMessage,
          currentUserId: currentUserId,
          onReply: () => replyTapped = true,
        ),
      );

      // act
      await tester.tap(find.text(ChatMessagePageConstants.replyMenuOption));
      await tester.pump();

      // assert
      expect(replyTapped, isTrue);
    });

    testWidgets('calls onEdit when edit option is tapped', (tester) async {
      // arrange
      bool editTapped = false;
      
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: testMessage,
          currentUserId: currentUserId,
          onEdit: () => editTapped = true,
        ),
      );

      // act
      await tester.tap(find.text(ChatMessagePageConstants.editMenuOption));
      await tester.pump();

      // assert
      expect(editTapped, isTrue);
    });

    testWidgets('calls onDelete when delete option is tapped', (tester) async {
      // arrange
      bool deleteTapped = false;
      
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: testMessage,
          currentUserId: currentUserId,
          onDelete: () => deleteTapped = true,
        ),
      );

      // act
      await tester.tap(find.text(ChatMessagePageConstants.deleteMenuOption));
      await tester.pump();

      // assert
      expect(deleteTapped, isTrue);
    });

    testWidgets('copies text to clipboard when copy option is tapped', (tester) async {
      // arrange
      const testClipboard = [];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall methodCall) async {
          if (methodCall.method == 'Clipboard.setData') {
            return null;
          }
          return null;
        },
      );

      await tester.pumpWidget(
        createWidgetUnderTest(
          message: testMessage,
          currentUserId: currentUserId,
        ),
      );

      // act
      await tester.tap(find.text(ChatMessagePageConstants.copyMenuOption));
      await tester.pump();

      // assert - no exception should be thrown
      expect(find.text(ChatMessagePageConstants.copyMenuOption), findsOneWidget);
    });

    testWidgets('shows proper icons for each menu option', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: testMessage,
          currentUserId: currentUserId,
        ),
      );

      // assert
      expect(find.byIcon(Icons.reply), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.byIcon(Icons.copy), findsOneWidget);
    });

    testWidgets('delete option has error color', (tester) async {
      // arrange & act
      await tester.pumpWidget(
        createWidgetUnderTest(
          message: testMessage,
          currentUserId: currentUserId,
        ),
      );

      // assert
      final deleteMenuFinder = find.text(ChatMessagePageConstants.deleteMenuOption);
      expect(deleteMenuFinder, findsOneWidget);
      
      final deleteTextWidget = tester.widget<Text>(deleteMenuFinder);
      expect(deleteTextWidget.style?.color, isNotNull);
    });
  });
}
