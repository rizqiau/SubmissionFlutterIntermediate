import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/db/auth_repository.dart';
import 'package:story_app/routes/route_delegate.dart';

import '../provider/story_provider.dart';

class StoryListScreen extends StatefulWidget {
  const StoryListScreen({super.key});

  @override
  State<StoryListScreen> createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    final authRepository = context.read<AuthRepository>();
    final token = await authRepository.getToken();
    if (token != null) {
      await context.read<StoryProvider>().loadStories(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStories,
        child:
            storyProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : storyProvider.errorMessage != null
                ? Center(child: Text(storyProvider.errorMessage!))
                : ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: storyProvider.stories.length,
                  itemBuilder: (context, index) {
                    final story = storyProvider.stories[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            story.photoUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(
                          story.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          context.read<RouteState>().goToStoryDetail(story.id);
                        },
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Tambah Cerita',
        child: Icon(Icons.add),
        onPressed: () {
          context.read<RouteState>().goToAddStory();
        },
      ),
    );
  }
}
