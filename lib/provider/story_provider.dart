import 'dart:io';

import 'package:flutter/material.dart';

import '../db/story_repository.dart';
import '../models/story.dart';

class StoryProvider extends ChangeNotifier {
  final StoryRepository storyRepository;

  StoryProvider(this.storyRepository);

  List<Story> _stories = [];
  List<Story> get stories => _stories;

  Story? _selectedStory;
  Story? get selectedStory => _selectedStory;

  bool isLoading = false;
  String? errorMessage;

  Future<void> loadStories(String token) async {
    isLoading = true;
    notifyListeners();

    try {
      _stories = await storyRepository.fetchStories(token);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadStoryDetail(String token, String storyId) async {
    isLoading = true;
    notifyListeners();

    try {
      _selectedStory = await storyRepository.fetchStoryDetail(token, storyId);
      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addStory({
    required String token,
    required String description,
    required File photo,
    double? lat,
    double? lon,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final result = await storyRepository.addNewStory(
        token: token,
        description: description,
        photo: photo,
        lat: lat,
        lon: lon,
      );
      errorMessage = null;
      isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
