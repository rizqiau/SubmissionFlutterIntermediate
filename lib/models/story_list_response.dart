import 'story.dart';

class StoryListResponse {
  final bool error;
  final String message;
  final List<Story> listStory;

  StoryListResponse({
    required this.error,
    required this.message,
    required this.listStory,
  });

  factory StoryListResponse.fromJson(Map<String, dynamic> json) {
    return StoryListResponse(
      error: json['error'],
      message: json['message'],
      listStory:
          (json['listStory'] as List)
              .map((storyJson) => Story.fromJson(storyJson))
              .toList(),
    );
  }
}
