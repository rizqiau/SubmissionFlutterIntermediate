import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/screen/story_list_screen.dart';
import '../db/auth_repository.dart';
import '../routes/route_delegate.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authRepo = context.read<AuthRepository>();
    final routeState = context.read<RouteState>();

    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authRepo.logout();
              routeState.goToLogin();
            },
          ),
        ],
      ),
      body: StoryListScreen(),
    );
  }
}
