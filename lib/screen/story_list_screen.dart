import 'package:cached_network_image/cached_network_image.dart';
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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final token = await context.read<AuthRepository>().getToken();
    if (token != null) {
      await context.read<StoryProvider>().loadStories(token);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      _loadMoreData();
    }
  }

  Future<void> _loadMoreData() async {
    final token = await context.read<AuthRepository>().getToken();
    final storyProvider = context.read<StoryProvider>();

    if (token != null && !storyProvider.isLoading && storyProvider.hasMore) {
      await storyProvider.loadStories(token);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storyProvider = context.watch<StoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Cerita'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () async {
              final token = await context.read<AuthRepository>().getToken();
              if (token != null) {
                await storyProvider.refreshStories(token);
              }
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final token = await context.read<AuthRepository>().getToken();
          if (token != null) {
            await storyProvider.refreshStories(token);
          }
        },
        child: ListView.builder(
          controller: _scrollController,
          itemCount:
              storyProvider.stories.length + (storyProvider.hasMore ? 1 : 0),
          addAutomaticKeepAlives: false,
          addRepaintBoundaries: false,
          itemBuilder: (context, index) {
            if (index >= storyProvider.stories.length) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child:
                      storyProvider.hasMore
                          ? CircularProgressIndicator()
                          : Text('Tidak ada data lagi'),
                ),
              );
            }

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
                  child: CachedNetworkImage(
                    imageUrl: story.photoUrl,
                    memCacheWidth: 60,
                    memCacheHeight: 60,
                    imageBuilder:
                        (context, imageProvider) => Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: imageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    placeholder:
                        (context, url) => Container(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                    errorWidget:
                        (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image),
                        ),
                  ),
                ),
                title: Text(
                  story.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
