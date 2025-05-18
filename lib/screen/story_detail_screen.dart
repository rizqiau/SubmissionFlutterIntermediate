import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/story_provider.dart';
import '../db/auth_repository.dart';

class StoryDetailScreen extends StatefulWidget {
  final String storyId;

  const StoryDetailScreen({Key? key, required this.storyId}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final token = await context.read<AuthRepository>().getToken();
    if (token != null) {
      await context.read<StoryProvider>().loadStoryDetail(
        token,
        widget.storyId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();
    final story = storyProvider.selectedStory;

    return Scaffold(
      appBar: AppBar(title: Text('Detail Cerita'), centerTitle: true),
      body:
          storyProvider.isLoading
              ? Center(child: CircularProgressIndicator())
              : storyProvider.errorMessage != null
              ? Center(child: Text(storyProvider.errorMessage!))
              : story == null
              ? Center(child: Text('Cerita tidak ditemukan'))
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.name,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        story.photoUrl,
                        height: 220, // Atur tinggi sesuai kebutuhan, misal 220
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      story.description,
                      style: TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
    );
  }
}
