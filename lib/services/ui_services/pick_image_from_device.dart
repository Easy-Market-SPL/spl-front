import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../utils/strings/image_picker_strings.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  /// Displays a bottom sheet for selecting the image source (camera or gallery)
  Future<File?> pickImage(BuildContext context) async {
    ImageSource? source = await _showImageSourceSelector(context);
    if (source == null) return null;
    return await _getImage(source, context);
  }

  /// Shows a modal bottom sheet to choose the image source
  Future<ImageSource?> _showImageSourceSelector(BuildContext context) async {
    return await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Colors.blue),
                title: const Text(ImagePickerStrings.takePhoto),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.green),
                title: const Text(ImagePickerStrings.chooseFromGallery),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Handles image selection from the camera or gallery
  Future<File?> _getImage(ImageSource source, BuildContext context) async {
    PermissionStatus permissionStatus = await _requestPermission(source);

    if (!permissionStatus.isGranted) {
      _showSnackBar(
          context,
          ImagePickerStrings.deniedPermission +
              (source == ImageSource.camera
                  ? ImagePickerStrings.camera
                  : ImagePickerStrings.gallery));
      return null;
    }

    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile == null) {
      _showSnackBar(context, ImagePickerStrings.noImageSelected);
      return null;
    }

    return File(pickedFile.path);
  }

  /// Requests the required permissions based on the image source
  Future<PermissionStatus> _requestPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await Permission.camera.request();
    } else {
      if (Platform.isAndroid && (await _isAndroid13OrAbove())) {
        return await Permission.photos.request();
      } else {
        return await Permission.storage.request();
      }
    }
  }

  /// Checks if the Android version is 13 or above
  Future<bool> _isAndroid13OrAbove() async {
    final int sdkVersion =
        int.tryParse(await _getAndroidSdkVersion() ?? '0') ?? 0;
    return sdkVersion >= 33;
  }

  /// Gets the Android SDK version
  Future<String?> _getAndroidSdkVersion() async {
    try {
      final result = await Process.run('getprop', ['ro.build.version.sdk']);
      return result.stdout.toString().trim();
    } catch (e) {
      return null;
    }
  }

  /// Displays a SnackBar with a message
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
