import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spl_front/models/data/chat_message.dart';
import 'package:spl_front/models/logic/user_type.dart';

import '../../bloc/ui_management/chat/chat_bloc.dart';
import '../../bloc/ui_management/chat/chat_event.dart';
import '../../utils/strings/chat_strings.dart';

class ChatInputField extends StatelessWidget {
  final ScrollController scrollController;
  final UserType userType;
  final FocusNode focusNode;

  const ChatInputField(
      {super.key,
      required this.scrollController,
      required this.userType,
      required this.focusNode});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    var maxInputLines = 2;
    if (kIsWeb) {
      maxInputLines = 4;
    }

    void sendMessage() {
      if (controller.text.trim().isNotEmpty) {
        context.read<ChatBloc>().add(SendMessageEvent(
            senderType: userType,
            text: controller.text.trim(),
        ));
        controller.clear();
        scrollToBottomPostFrame(scrollController);
      }
    }

    Future<void> handleFileSelection() async {
      MessageType fileType = MessageType.image;
      final ImagePicker picker = ImagePicker();
      final XFile? file = await showModalBottomSheet<XFile>(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text(ChatStrings.selectImage),
                  onTap: () async {
                    fileType = MessageType.image;
                    final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery);
                    if (context.mounted) {
                      Navigator.pop(context, image);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.videocam),
                  title: const Text(ChatStrings.selectVideo),
                  onTap: () async {
                    fileType = MessageType.video;
                    final XFile? video = await picker.pickVideo(
                        source: ImageSource.gallery);
                    if (context.mounted) {
                      Navigator.pop(context, video);
                    }
                  },
                ),
              ],
            ),
          );
        },
      );

      if (file != null) {
        String fileUrl = file.path;

        MessageType messageType = fileType;

        // Send the file with the correct type
        if (context.mounted) {
          context.read<ChatBloc>().add(SendFileEvent(
              senderType: userType == UserType.customer ? 'cliente' : 'soporte',
              messageType: messageType,
              ));
        }
        scrollToBottomWithDelay(scrollController);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey, width: 0.5),
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 2.0,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Text input field
              Expanded(
                child: Focus(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    if (event is KeyDownEvent && kIsWeb) {
                      if (event.logicalKey == LogicalKeyboardKey.enter &&
                          !HardwareKeyboard.instance.isShiftPressed) {
                        sendMessage();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: maxInputLines,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[100],
                      hintText: ChatStrings.writeMessageHint,
                      hintStyle: const TextStyle(color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25.0),
                        borderSide:
                            const BorderSide(color: Colors.black, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onTap: () {
                      // Scroll to the bottom when the input field is tapped
                      scrollToBottomWithDelay(scrollController);
                    },
                    onSubmitted: (value) {
                      sendMessage();
                    },
                  ),
                ),
              ),

              // Attach file button
              IconButton(
                icon: const Icon(Icons.attach_file, color: Colors.blueAccent),
                onPressed: () async {
                  focusNode.unfocus();
                  await handleFileSelection();
                },
              ),

              // Send message button
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blueAccent),
                onPressed: sendMessage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void scrollToBottom(ScrollController scrollController) {
  try {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  } catch (e) {
    print('Error scrolling: $e');
  }
}

void scrollToBottomPostFrame(ScrollController scrollController) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    scrollToBottom(scrollController);
  });
}

void scrollToBottomWithDelay(ScrollController scrollController) {
  Future.delayed(const Duration(milliseconds: 500), () {
    scrollToBottom(scrollController);
  });
}
