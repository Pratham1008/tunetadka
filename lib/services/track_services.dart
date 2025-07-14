import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../model/models.dart';

class TrackService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'https://mp3-backend-ut8t.onrender.com/api/tracks'));

  static const String baseUrl = 'https://mp3-backend-ut8t.onrender.com/api/tracks';

  // ✅ Check user
  static Future<void> checkUser(String name, String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/check-user?name=$name&email=$email'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to verify user');
    }
  }


  static Future<String> uploadTrack(
      String title,
      String email,
      File file, {
        required void Function(int sent, int total) onSendProgress,
      }) async {
    final formData = FormData.fromMap({
      'title': title,
      'userEmail': email,
      'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
    });

    final response = await _dio.post(
      '/upload',
      data: formData,
      onSendProgress: onSendProgress,
    );

    if (response.statusCode == 200) return response.data.toString();
    throw Exception('Failed to upload track');
  }

  static Uri getCoverImageUrl(String id) => Uri.parse('${_dio.options.baseUrl}/$id/cover');

  static Future<Uri> getStreamUrl(String trackId, String email) async {
    final response = await _dio.getUri(
      Uri.parse('${_dio.options.baseUrl}/audio?trackId=$trackId&email=$email'),
      options: Options(followRedirects: false, validateStatus: (s) => s! < 400),
    );
    if (response.isRedirect) return Uri.parse(response.headers['location']!.first);
    throw Exception('Unable to get stream URL');
  }

  static Future<String> addToFavorites(String id, String email) async {
    final response = await _dio.post('/$id/favorite', queryParameters: {'email': email});
    return response.data;
  }

  static Future<List<Track>> getAllTracks() async {
    final response = await _dio.get('');
    return (response.data as List).map((e) => Track.fromJson(e)).toList();
  }

  static Future<Track> getTrack(String id) async {
    final response = await _dio.get('/$id');
    return Track.fromJson(response.data);
  }

  static Future<List<Track>> getTracksByUser(String email) async {
    final response = await _dio.get('/by-user', queryParameters: {'email': email});
    return (response.data as List).map((e) => Track.fromJson(e)).toList();
  }

  static Future<String> deleteTrack(String id) async {
    final response = await _dio.delete('/$id');
    return response.data;
  }

  static Future<List<History>> getHistory(String email) async {
    final response = await _dio.get('/history', queryParameters: {'userEmail': email});
    return (response.data as List).map((e) => History.fromJson(e)).toList();
  }

  static Future<List<Favorite>> getFavorites(String email) async {
    final response = await _dio.get('/favorites', queryParameters: {'userEmail': email});
    return (response.data as List).map((e) => Favorite.fromJson(e)).toList();
  }
}
