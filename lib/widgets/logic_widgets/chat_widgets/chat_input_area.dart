import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spl_front/models/chat_models/chat_message.dart';

import '../../../bloc/chat_bloc/single_chat_bloc/chat_bloc.dart';
import '../../../bloc/chat_bloc/single_chat_bloc/chat_event.dart';
import '../../../bloc/chat_bloc/single_chat_bloc/chat_state.dart';
import '../../../models/helpers/intern_logic/user_type.dart';
import '../../../utils/strings/chat_strings.dart';

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

    final bool isUploading =
        context.select((ChatBloc bloc) => bloc.state is ChatFileUploading);

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
      if (isUploading) return;

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
                    final XFile? image =
                        await picker.pickImage(source: ImageSource.gallery);
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
                    final XFile? video =
                        await picker.pickVideo(source: ImageSource.gallery);
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
                senderType: userType,
                messageType: messageType,
                filePath: fileUrl,
              ));
        }
        scrollToBottomWithDelay(scrollController);
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isUploading ? Colors.grey[200] : Colors.white,
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
                        if (event is KeyDownEvent && kIsWeb && !isUploading) {
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
                        enabled: !isUploading,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.multiline,
                        minLines: 1,
                        maxLines: maxInputLines,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              isUploading ? Colors.grey[300] : Colors.grey[100],
                          hintText: isUploading
                              ? ChatStrings.uploadingFile
                              : ChatStrings.writeMessageHint,
                          hintStyle: TextStyle(
                              color:
                                  isUploading ? Colors.grey[600] : Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                        ),
                        onTap: () {
                          // Scroll to the bottom when the input field is tapped
                          scrollToBottomWithDelay(scrollController);
                        },
                        onSubmitted: (value) {
                          if (!isUploading) {
                            sendMessage();
                          }
                        },
                      ),
                    ),
                  ),

                  // Attach file button
                  IconButton(
                    icon:
                        const Icon(Icons.attach_file, color: Colors.blueAccent),
                    onPressed: isUploading
                        ? null
                        : () async {
                            focusNode.unfocus();
                            await handleFileSelection();
                          },
                    color: isUploading ? Colors.grey : Colors.blueAccent,
                  ),

                  // Send message button
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isUploading ? null : sendMessage,
                    color: isUploading ? Colors.grey : Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ),

          // Show upload progress indicator
          if (isUploading)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(height: 8),
                      Text(ChatStrings.uploadingFile,
                          style:
                              TextStyle(fontSize: 12, color: Colors.grey[800])),
                    ],
                  ),
                ),
              ),
            ),
        ],
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
    debugPrint('Error scrolling: $e');
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
