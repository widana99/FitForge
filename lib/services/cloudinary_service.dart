import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Replace these with your Cloudinary credentials
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UNSIGNED_PRESET';

  static final CloudinaryService _instance = CloudinaryService._();
  factory CloudinaryService() => _instance;
  CloudinaryService._();

  /// Upload an image to Cloudinary
  Future<String?> uploadImage(File file, {String? folder}) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder ?? 'fitforge/images'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        return json['secure_url'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Upload a video to Cloudinary
  Future<String?> uploadVideo(File file, {String? folder}) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
      );
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder ?? 'fitforge/videos'
        ..fields['resource_type'] = 'video'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final json = jsonDecode(responseBody);
        return json['secure_url'] as String;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Generate thumbnail URL from Cloudinary video URL
  String getThumbnailUrl(String videoUrl, {int width = 400, int height = 300}) {
    // Transform Cloudinary URL to get auto-generated thumbnail
    return videoUrl
        .replaceFirst(
          '/video/upload/',
          '/video/upload/w_$width,h_$height,c_fill,so_0/',
        )
        .replaceFirst('.mp4', '.jpg');
  }

  /// Generate optimized image URL
  String getOptimizedImageUrl(
    String imageUrl, {
    int width = 400,
    int quality = 80,
  }) {
    return imageUrl.replaceFirst(
      '/image/upload/',
      '/image/upload/w_$width,q_$quality,f_auto/',
    );
  }
}
