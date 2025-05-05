import 'dart:io';

import 'package:flutter/material.dart';
import 'package:spl_front/models/chat_models/chat_message.dart';

import '../../../utils/strings/chat_strings.dart';
import 'chat_image_manager.dart';
import 'chat_video_player.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isCurrentUser;
  final FocusNode focusNode;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar for other user
          if (!isCurrentUser)
            CircleAvatar(radius: 20, backgroundColor: Colors.grey[300]),
          const SizedBox(width: 10),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: _buildMessageContent(context),
                ),

                // Message time
                Text(message.time,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),

          const SizedBox(width: 10),
          // Avatar for current user
          if (isCurrentUser)
            CircleAvatar(radius: 20, backgroundColor: Colors.grey[300]),
        ],
      ),
    );
  }

  // Main content selector based on message type
  Widget _buildMessageContent(BuildContext context) {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage(context);
      case MessageType.video:
        return _buildVideoMessage(context);
    }
  }

  // Text message content
  Widget _buildTextMessage() {
    return Text(message.text);
  }

  // Image message content with error handling
  Widget _buildImageMessage(BuildContext context) {
    if (message.fileUrl == null || message.fileUrl!.isEmpty) {
      return const Text(ChatStrings.imageNotAvailable);
    }

    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FullScreenImage(imageUrl: message.fileUrl!),
          ),
        );
      },
      child: _isNetworkImage(message.fileUrl!)
          ? _buildNetworkImage()
          : _buildLocalImage(),
    );
  }

  // Network image with loading and error states
  Widget _buildNetworkImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        message.fileUrl!,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildImageLoadingIndicator(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildImageErrorWidget();
        },
      ),
    );
  }

  // Loading indicator for images
  Widget _buildImageLoadingIndicator(ImageChunkEvent loadingProgress) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
        ),
      ),
    );
  }

  // Error widget for failed image loads
  Widget _buildImageErrorWidget() {
    return Container(
      width: 200,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 8),
          Text(ChatStrings.imageLoadError, style: TextStyle(color: Colors.red)),
          Text(ChatStrings.imageLoadErrorRetry, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  // Local file image
  Widget _buildLocalImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(message.fileUrl!),
        width: 200,
        height: 200,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 200,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 40),
                Text(ChatStrings.imageLoadError,
                    style: TextStyle(color: Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Video message content
  Widget _buildVideoMessage(BuildContext context) {
    if (message.fileUrl == null || message.fileUrl!.isEmpty) {
      return const Text(ChatStrings.videoNotAvailable);
    }

    return GestureDetector(
      onTap: () {
        focusNode.unfocus();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerWidget(videoUrl: message.fileUrl!),
          ),
        );
      },
      child: Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.black,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: VideoPlayerWidget(videoUrl: message.fileUrl!),
        ),
      ),
    );
  }

  // Helper to check if image is from network
  bool _isNetworkImage(String path) {
    return path.contains(RegExp(r'^(http|https)://'));
  }
}
