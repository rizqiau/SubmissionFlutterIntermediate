import 'dart:io';

import 'package:story_app/models/story_list_response.dart';

import '../models/story.dart';
import '../services/api_service.dart';

class StoryRepository {
  final ApiService apiService;

  StoryRepository(this.apiService);

  Future<StoryListResponse> fetchStories(
    String token, {
    int page = 1,
    int size = 10,
  }) async {
    return await apiService.getStories(token, page: page, size: size);
  }

  Future<Story> fetchStoryDetail(String token, String storyId) async {
    return await apiService.getStoryDetail(token, storyId);
  }

  Future<bool> addNewStory({
    required String token,
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    return await apiService.addStory(
      token: token,
      description: description,
      photo: photo,
      lat: lat,
      lon: lon,
    );
  }
}
