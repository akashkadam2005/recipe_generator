import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiHelper {
  // Singleton instance
  static final ApiHelper _instance = ApiHelper._internal();

  // Base URL
  final String baseUrl = 'http://192.168.118.172/chefio/api/';

  // Image base URL

  final String imageBaseUrl = 'http://192.168.118.172/chefio/api/uploads/';

  // Private constructor for singleton
  ApiHelper._internal();

  // Factory constructor to return the same instance
  factory ApiHelper() => _instance;

  // HTTP POST method
  Future<http.Response> httpPost(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }

  String getUrl(String endpoint) {
    return "$baseUrl$endpoint";
  }

  // HTTP GET method
  Future<http.Response> httpGet(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.get(url);
  }

  // HTTP DELETE method
  Future<http.Response> httpDelete(String endpoint) async {
    final url = Uri.parse('$baseUrl$endpoint');
    return await http.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );
  }

  // Multipart request method
  Future<http.StreamedResponse> multipartRequest({
    required String endpoint,
    required Map<String, String> fields,
    Map<String, String>? headers,
    Map<String, String>? files, // key: form field name, value: file path
  }) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final request = http.MultipartRequest('POST', url);

    request.fields.addAll(fields);
    if (headers != null) request.headers.addAll(headers);

    if (files != null) {
      for (var entry in files.entries) {
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }
    }

    return await request.send(); // Use .stream.bytesToString() to read response later
  }


  // Helper method to get full image URL
  String getImageUrl(String imageName) {
    return '$imageBaseUrl$imageName';
  }
}
