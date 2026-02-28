import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

Future<String> downloadAndCacheImage(String imageUrl) async {
  try {
    // Get cache directory path
    final Directory cacheDir = await getTemporaryDirectory();

    // Create a file path with the same name as the image
    final String fileName = path.basename(imageUrl);
    final String filePath = path.join(cacheDir.path, fileName);

    // Check if file already exists in cache
    final File cachedFile = File(filePath);
    if (await cachedFile.exists()) {
      debugPrint("Image loaded from cache: $filePath");
      return filePath;
    }

    // Download the image from network
    final http.Response response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      await cachedFile.writeAsBytes(response.bodyBytes);
      debugPrint("Image downloaded and cached: $filePath");
      return filePath;
    } else {
      throw Exception("Failed to download image");
    }
  } catch (e) {
    debugPrint("Error caching image: $e");
    rethrow;
  }
}
