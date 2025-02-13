import 'dart:io';
import 'package:flutter/material.dart';
import 'package:spl_front/widgets/chat/chat_image_manager.dart';
import 'package:spl_front/widgets/chat/chat_video_player.dart';
import '../../bloc/ui_management/chat/chat_state.dart';
import '../../utils/strings/chat_strings.dart';

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
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser) CircleAvatar(radius: 20, backgroundColor: Colors.grey[300]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                // Message bubble
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: isCurrentUser ? Colors.blue[100] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.type == MessageType.text)
                        Text(message.text)

                      // Image 
                      else if (message.type == MessageType.image)
                        message.fileUrl != null
                            ? GestureDetector(
                                onTap: () {
                                  focusNode.unfocus(); // Desenfocar el TextField antes de navegar
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenImage(imageUrl: message.fileUrl!),
                                    ),
                                  );
                                },
                                child: message.fileUrl!.startsWith('http')
                                    ? Image.network(
                                        message.fileUrl!,
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      )
                                    : Image.file(
                                        File(message.fileUrl!),
                                        width: 200,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                              )
                            : const Text(ChatStrings.imageNotAvailable)

                      // Video
                      else if (message.type == MessageType.video)
                        message.fileUrl != null
                            ? GestureDetector(
                                onTap: () {
                                  focusNode.unfocus(); // Desenfocar el TextField antes de navegar
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
                              )
                            : const Text(ChatStrings.videoNotAvailable)
                    ],
                  ),
                ),
                // Message time
                Text(message.time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          if (isCurrentUser) CircleAvatar(radius: 20, backgroundColor: Colors.grey[300]),
        ],
      ),
    );
  }
}