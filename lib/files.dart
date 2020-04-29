import 'package:path/path.dart';
import 'dart:typed_data';
import 'dart:convert';

const List<String> videoFormats = [
  '.mp4',
  '.mov',
  '.avi',
  '.wmv',
  '.3gp',
  '.mkv',
  '.flv'
];
const List<String> imageFormats = [
  '.jpeg',
  '.png',
  '.jpg',
  '.gif',
  '.webp',
  '.tif',
  '.heic'
];
const http = 'http';

bool isLocalFilePath(String path) {
  Uri uri = Uri.parse(path);
  return !uri.scheme.contains(http);
}

bool isBase64Image(String path) {
  return path?.startsWith("data:");
}
Uint8List convertBase64ImageToBytes(String path) {
  var i = path.indexOf(",");
  var base64Str = path.substring(i + 1);
  return base64Decode(base64Str);
}
bool isVideo(String path) =>
    videoFormats.contains(extension(path).toLowerCase());

bool isImage(String path) =>
    imageFormats.contains(extension(path).toLowerCase());
