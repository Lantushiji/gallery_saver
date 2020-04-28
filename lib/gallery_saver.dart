import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:gallery_saver/files.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class GallerySaver {
  static const String channelName = 'gallery_saver';
  static const String methodSaveImage = 'saveImage';
  static const String methodSaveVideo = 'saveVideo';

  static const String pleaseProvidePath = 'Please provide valid file path.';
  static const String fileIsNotVideo = 'File on path is not a video.';
  static const String fileIsNotImage = 'File on path is not an image.';
  static const MethodChannel _channel = const MethodChannel(channelName);

  ///saves video from provided temp path and optional album name in gallery
  static Future<bool> saveVideo(String path, {String albumName}) async {
    File tempFile;
    if (path == null || path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
//    if (!isVideo(path)) {
//      throw ArgumentError(fileIsNotVideo);
//    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path, false);
      path = tempFile.path;
    }
    bool result = await _channel.invokeMethod(
      methodSaveVideo,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    if (tempFile != null) {
      tempFile.delete();
    }
    return result;
  }

  ///saves image from provided temp path and optional album name in gallery
  static Future<bool> saveImage(String path, {String albumName}) async {
    File tempFile;
    if (path == null || path.isEmpty) {
      throw ArgumentError(pleaseProvidePath);
    }
//    if (!isImage(path)) {
//      throw ArgumentError(fileIsNotImage);
//    }
    if (!isLocalFilePath(path)) {
      tempFile = await _downloadFile(path, true);
      path = tempFile.path;
    }

    bool result = await _channel.invokeMethod(
      methodSaveImage,
      <String, dynamic>{'path': path, 'albumName': albumName},
    );
    if (tempFile != null) {
      tempFile.delete();
    }

    return result;
  }

  static Future<File> _downloadFile(String url, bool image) async {
    http.Client _client = new http.Client();
    var req = await _client.get(Uri.parse(url));
    var bytes = req.bodyBytes;
    var name;
    if (image) {
      if (isImage(url)) {
        name =  basename(url);
      } else {
        name = '${new DateTime.now().millisecondsSinceEpoch}.jpg';
      }
    } else {
      if (isVideo(url)) {
        name =  basename(url);
      } else {
        name = '${new DateTime.now().millisecondsSinceEpoch}.mp4';
      }
    }

    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/${name}');
    await file.writeAsBytes(bytes);
    return file;
  }
}
