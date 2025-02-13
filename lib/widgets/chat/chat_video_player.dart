import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../../utils/strings/chat_strings.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      _controller = widget.videoUrl.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
          : VideoPlayerController.file(File(widget.videoUrl));

      await _controller.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint("${ChatStrings.error} $e");
    }
  }

  Future<void> _showDownloadDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Descarga"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> _downloadFile(String url, String filename) async {
    if (url.startsWith('http')) {
      // Download from remote URL
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception(ChatStrings.errorDownloadingVideo);
      }
      final downloadsDirectory = await getDownloadsDirectory();
      if (downloadsDirectory == null) {
        _showDownloadDialog(ChatStrings.errorDownloadingVideo);
        return;
      }
      final filePath = '${downloadsDirectory.path}/$filename';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await Gal.putVideo(filePath);
      _showDownloadDialog('Video descargado: $filename');
    } else {
      // Copy from local file
      await Gal.putVideo(url);
      _showDownloadDialog('Video descargado: $filename');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: _controller.value.isInitialized
          ? Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                Positioned(
                  bottom: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isPlaying ? _controller.pause() : _controller.play();
                            _isPlaying = !_isPlaying;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.white),
                        onPressed: () {
                          _downloadFile(widget.videoUrl, 'video.mp4');
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}