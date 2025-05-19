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

  int _page = 1;
  final int _size = 10;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  Future<void> loadStories(String token, {bool isRefresh = false}) async {
    if (isRefresh) {
      _page = 1;
      _hasMore = true;
    }

    if (!_hasMore) return;

    isLoading = true;
    notifyListeners();

    try {
      final response = await storyRepository.fetchStories(
        token,
        page: _page,
        size: _size,
      );

      if (isRefresh) {
        _stories = response.listStory;
      } else {
        _stories.addAll(response.listStory);
      }

      _hasMore = response.listStory.length >= _size;
      _page++;

      errorMessage = null;
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> refreshStories(String token) async {
    _page = 1;
    _hasMore = true;
    _stories.clear();
    isLoading = true; // Kosongkan list sebelum load ulang
    notifyListeners();

    await loadStories(token);
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
