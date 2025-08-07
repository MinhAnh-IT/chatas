import 'package:flutter/material.dart';
import '../../constants/chat_message_page_constants.dart';
import '../../domain/entities/chat_message.dart';

/// Widget for selecting message reactions.
/// Displays available reactions in a popup overlay.
class ReactionPicker extends StatelessWidget {
  final Function(ReactionType) onReactionSelected;
  final VoidCallback onDismiss;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    required this.onDismiss,
  });

  /// List of available reactions with their emoji representations.
  static const List<MapEntry<ReactionType, String>> _reactions = [
    MapEntry(ReactionType.like, ChatMessagePageConstants.likeReaction),
    MapEntry(ReactionType.love, ChatMessagePageConstants.loveReaction),
    MapEntry(ReactionType.laugh, ChatMessagePageConstants.laughReaction),
    MapEntry(ReactionType.wow, ChatMessagePageConstants.wowReaction),
    MapEntry(ReactionType.sad, ChatMessagePageConstants.sadReaction),
    MapEntry(ReactionType.angry, ChatMessagePageConstants.angryReaction),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10.0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(theme),
                  const SizedBox(height: 16.0),
                  _buildReactionGrid(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the title section of the reaction picker.
  Widget _buildTitle(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Chọn cảm xúc',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          onPressed: onDismiss,
          icon: Icon(
            Icons.close,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          iconSize: 20.0,
        ),
      ],
    );
  }

  /// Builds the grid of reaction options.
  Widget _buildReactionGrid(ThemeData theme) {
    return Wrap(
      spacing: 12.0,
      runSpacing: 12.0,
      children: _reactions.map((reactionEntry) {
        return _buildReactionButton(
          theme,
          reactionEntry.key,
          reactionEntry.value,
        );
      }).toList(),
    );
  }

  /// Builds an individual reaction button.
  Widget _buildReactionButton(
    ThemeData theme,
    ReactionType reaction,
    String emoji,
  ) {
    return GestureDetector(
      onTap: () => onReactionSelected(reaction),
      child: Container(
        width: 56.0,
        height: 56.0,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(28.0),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Center(
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 24.0),
          ),
        ),
      ),
    );
  }

  /// Shows the reaction picker as a modal overlay.
  static void show(
    BuildContext context, {
    required Function(ReactionType) onReactionSelected,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (context) => ReactionPicker(
        onReactionSelected: (reaction) {
          Navigator.of(context).pop();
          onReactionSelected(reaction);
        },
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }
}

/// Widget for displaying existing reactions on a message.
class MessageReactions extends StatelessWidget {
  final Map<ReactionType, int> reactions;
  final Function(ReactionType)? onReactionTap;

  const MessageReactions({
    super.key,
    required this.reactions,
    this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      children: reactions.entries.map((entry) {
        final reaction = entry.key;
        final count = entry.value;
        
        if (count <= 0) return const SizedBox.shrink();
        
        return _buildReactionChip(theme, reaction, count);
      }).toList(),
    );
  }

  /// Builds a chip showing a reaction and its count.
  Widget _buildReactionChip(
    ThemeData theme,
    ReactionType reaction,
    int count,
  ) {
    final emoji = _getEmojiForReaction(reaction);
    
    return GestureDetector(
      onTap: onReactionTap != null ? () => onReactionTap!(reaction) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 14.0),
            ),
            if (count > 1) ...[
              const SizedBox(width: 4.0),
              Text(
                count.toString(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Gets the emoji representation for a reaction.
  String _getEmojiForReaction(ReactionType reaction) {
    switch (reaction) {
      case ReactionType.like:
        return ChatMessagePageConstants.likeReaction;
      case ReactionType.love:
        return ChatMessagePageConstants.loveReaction;
      case ReactionType.laugh:
        return ChatMessagePageConstants.laughReaction;
      case ReactionType.wow:
        return ChatMessagePageConstants.wowReaction;
      case ReactionType.sad:
        return ChatMessagePageConstants.sadReaction;
      case ReactionType.angry:
        return ChatMessagePageConstants.angryReaction;
    }
  }
}
