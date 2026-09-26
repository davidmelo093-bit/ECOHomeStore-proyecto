import 'package:flutter/material.dart';

/// Burbuja de mensaje para el chat.
class MessageBubble extends StatelessWidget {
  final String username;
  final String text;
  final String? createdAt;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.username,
    required this.text,
    required this.isMe,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    final timeLabel = createdAt != null
        ? TimeOfDay.fromDateTime(DateTime.parse(createdAt!).toLocal())
            .format(context)
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMe ? 12 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                username,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            Text(text),
            if (timeLabel.isNotEmpty)
              Text(
                timeLabel,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
