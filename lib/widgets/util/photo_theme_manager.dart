import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles picking, persisting, and decoding the photo used in Photo Puzzle
/// mode. The saved photo lives under a single fixed filename in the app's
/// documents directory, so a new pick always overwrites the previous one
/// (no orphan accumulation) and only the filename (not an absolute path,
/// which can go stale across app updates/reinstalls) needs to be persisted.
abstract final class PhotoThemeManager {
  static const String savedFileName = 'theme_pack_photo.jpg';

  /// Opens the system photo picker and, if the user picked something,
  /// copies it into the app's documents directory under [savedFileName].
  /// Returns the filename to persist, or `null` if the user cancelled or
  /// picking/copying failed.
  static Future<String?> pickAndSavePhoto() async {
    try {
      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (picked == null) return null;

      final documentsDir = await getApplicationDocumentsDirectory();
      final savedPath = '${documentsDir.path}/$savedFileName';
      await File(picked.path).copy(savedPath);
      return savedFileName;
    } catch (e) {
      debugPrint('PhotoThemeManager: pickAndSavePhoto failed: $e');
      return null;
    }
  }

  /// Decodes the saved photo (by [filename]) into a [ui.Image], or `null`
  /// if the file is missing/corrupt (e.g. cleared by the OS, or a stale
  /// filename from a previous install) — callers should fall back to a
  /// non-photo theme in that case.
  static Future<ui.Image?> decodeSavedPhoto(String filename) async {
    try {
      final documentsDir = await getApplicationDocumentsDirectory();
      final file = File('${documentsDir.path}/$filename');
      if (!await file.exists()) return null;

      final bytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      return frame.image;
    } catch (e) {
      debugPrint('PhotoThemeManager: decodeSavedPhoto failed: $e');
      return null;
    }
  }
}
