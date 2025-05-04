import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:video_player/video_player.dart';

import '../../../utils/strings/chat_strings.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isPlaying = false;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() async {
    try {
      if (kIsWeb) {
        _controller =
            VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      } else {
        if (widget.videoUrl.startsWith('http')) {
          _controller =
              VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
        } else {
          _controller = VideoPlayerController.file(File(widget.videoUrl));
        }
      }

      await _controller!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
      debugPrint("Error initializing video: $e");
    }
  }

  Future<void> _showDownloadDialog(String message) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Download"),
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
    try {
      if (kIsWeb) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode != 200) {
          throw Exception("Error downloading video");
        }
        final blob = html.Blob([response.bodyBytes]);
        final urlDownload = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: urlDownload)
          ..setAttribute("download", filename)
          ..click();
        html.Url.revokeObjectUrl(urlDownload);
        _showDownloadDialog('${ChatStrings.videoDownloaded}: $filename');
      } else {
        // For mobile platforms
        if (url.startsWith('http')) {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode != 200) {
            throw Exception("Error downloading video");
          }

          // Use temporary directory to store the file
          final directory = await getTemporaryDirectory();
          final filePath = '${directory.path}/$filename';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          // Save to gallery
          await Gal.putVideo(filePath);

          _showDownloadDialog('${ChatStrings.videoDownloaded}: $filename');
        } else {
          // Local file
          await Gal.putVideo(url);
          _showDownloadDialog(ChatStrings.videoDownloaded);
        }
      }
    } catch (e) {
      _showDownloadDialog(
          '${ChatStrings.errorDownloadingVideo}: ${e.toString()}');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${ChatStrings.errorDownloadingVideo}: $_errorMessage',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_controller == null || !_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Center(
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            VideoPlayer(_controller!),
            ControlsOverlay(
              controller: _controller!,
              isPlaying: _isPlaying,
              onPlayPause: () {
                setState(() {
                  if (_isPlaying) {
                    _controller!.pause();
                  } else {
                    _controller!.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
              onDownload: () => _downloadFile(widget.videoUrl, 'video.mp4'),
            ),
          ],
        ),
      ),
    );
  }
}

class ControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onDownload;

  const ControlsOverlay({
    super.key,
    required this.controller,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 32.0,
            ),
            onPressed: onPlayPause,
          ),
          IconButton(
            icon: const Icon(
              Icons.download,
              color: Colors.white,
              size: 32.0,
            ),
            onPressed: onDownload,
          ),
        ],
      ),
    );
  }
}
