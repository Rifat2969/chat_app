import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/message_model.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[const CircleAvatar(child: Icon(Icons.person)), const SizedBox(width: 8)],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: isMe ? Theme.of(context).colorScheme.primary : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null && message.imageUrl!.isNotEmpty) _buildImageMessage(),
                      if (message.message.isNotEmpty)
                        Text(message.message, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                      const SizedBox(height: 4),
                      Text(
                        _formatTime(message.timestamp),
                        style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[const SizedBox(width: 8), const CircleAvatar(child: Icon(Icons.person))],
        ],
      ),
    );
  }

  Widget _buildImageMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: message.imageUrl!,
          width: 200,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) =>
              Container(width: 200, height: 150, color: Colors.grey[300], child: const Icon(Icons.error)),
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
