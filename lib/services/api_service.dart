import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:story_app/models/story.dart';
import '../models/user.dart';
import '../models/login_response.dart';

class ApiService {
  static const String baseUrl = "https://story-api.dicoding.dev/v1";

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || (data['error'] == false)) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['error'] == false) {
      return LoginResponse.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<List<Story>> getStories(
    String token, {
    int page = 1,
    int size = 20,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stories?page=$page&size=$size'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['error'] == false) {
      List listStory = data['listStory'];
      return listStory.map((json) => Story.fromJson(json)).toList();
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch stories');
    }
  }

  Future<Story> getStoryDetail(String token, String storyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stories/$storyId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['error'] == false) {
      return Story.fromJson(data['story']);
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch story detail');
    }
  }

  Future<bool> addStory({
    required String token,
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    final uri = Uri.parse('$baseUrl/stories');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';

    request.fields['description'] = description;
    if (lat != null) request.fields['lat'] = lat.toString();
    if (lon != null) request.fields['lon'] = lon.toString();

    final mimeType = 'image/jpeg'; // asumsi jpeg, bisa dikembangkan
    request.files.add(
      await http.MultipartFile.fromPath(
        'photo',
        photo.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body);
    if (response.statusCode == 201 || (data['error'] == false)) {
      return true;
    } else {
      throw Exception(data['message'] ?? 'Failed to add story');
    }
  }
}
