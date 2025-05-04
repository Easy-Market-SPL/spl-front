import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:universal_html/html.dart' as html;

import '../../../utils/strings/chat_strings.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  Future<void> _saveImage(BuildContext context) async {
    try {
      if (kIsWeb) {
        // Download image in web
        final response = await http.get(Uri.parse(imageUrl));
        if (response.statusCode != 200) {
          throw Exception(ChatStrings.errorDownloadingImage);
        }
        final blob = html.Blob([response.bodyBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute("download", "image.jpg")
          ..click();
        html.Url.revokeObjectUrl(url);
        if (context.mounted) {
          _showSnackbar(context, ChatStrings.imageSavedToGallery);
        }
      } else {
        // Ask for permission
        var status = await Permission.storage.request();
        if (!status.isGranted && context.mounted) {
          _showSnackbar(context, ChatStrings.permissionDenied);
          return;
        }

        if (imageUrl.startsWith('http')) {
          // Download from remote URL
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode != 200) {
            throw Exception(ChatStrings.errorDownloadingImage);
          }

          // Save the image in the temporary directory
          final tempDir = await getTemporaryDirectory();
          final filePath = '${tempDir.path}/image.jpg';
          final file = File(filePath);
          await file.writeAsBytes(response.bodyBytes);

          // Save the image in the gallery
          await Gal.putImage(filePath);
        } else {
          // Save the local image in the gallery
          await Gal.putImage(imageUrl);
        }
        if (context.mounted) {
          _showSnackbar(context, ChatStrings.imageSavedToGallery);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackbar(context, "${ChatStrings.error} ${e.toString()}");
      }
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _saveImage(context),
          ),
        ],
      ),
      body: Center(
        child: kIsWeb || imageUrl.startsWith('http')
            ? Image.network(imageUrl, fit: BoxFit.contain)
            : Image.file(File(imageUrl), fit: BoxFit.contain),
      ),
    );
  }
}
