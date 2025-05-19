import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:story_app/db/auth_repository.dart';
import 'package:story_app/db/story_repository.dart';
import 'package:story_app/provider/add_story_provider.dart';
import 'package:story_app/provider/story_provider.dart';
import 'package:story_app/routes/route_delegate.dart';
import 'package:story_app/routes/simple_route_information_parser.dart';
import 'package:story_app/services/api_service.dart';

void main() {
  final apiService = ApiService();
  final authRepository = AuthRepository(apiService);
  final storyRepository = StoryRepository(apiService);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<StoryRepository>.value(value: storyRepository),
        ChangeNotifierProvider<RouteState>(create: (_) => RouteState()),
        ChangeNotifierProvider(create: (_) => AddStoryProvider()),
        ChangeNotifierProvider<StoryProvider>(
          create: (_) => StoryProvider(storyRepository),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final routeState = context.watch<RouteState>();
    return MaterialApp.router(
      routerDelegate: AppRouteDelegate(routeState),
      routeInformationParser: SimpleRouteInformationParser(), // dummy parser
    );
  }
}
