import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:story_app/screen/location_picker_screen.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';
import '../screen/story_list_screen.dart';
import '../screen/story_detail_screen.dart';
import '../screen/add_story_screen.dart';
import '../screen/splash_screen.dart';
import '../screen/home_screen.dart';

enum AppPage {
  splash,
  login,
  register,
  home,
  storyList,
  storyDetail,
  addStory,
  locationPicker,
}

class RouteState extends ChangeNotifier {
  AppPage _currentPage = AppPage.splash;
  String? _selectedStoryId;
  LatLng? _initialLocationForPicker;

  AppPage get currentPage => _currentPage;
  String? get selectedStoryId => _selectedStoryId;
  LatLng? get initialLocationForPicker => _initialLocationForPicker;

  void goToSplash() {
    _currentPage = AppPage.splash;
    notifyListeners();
  }

  void goToLogin() {
    _currentPage = AppPage.login;
    notifyListeners();
  }

  void goToRegister() {
    _currentPage = AppPage.register;
    notifyListeners();
  }

  void goToHome() {
    _currentPage = AppPage.home;
    notifyListeners();
  }

  void goToStoryList() {
    _currentPage = AppPage.storyList;
    notifyListeners();
  }

  void goToStoryDetail(String storyId) {
    _selectedStoryId = storyId;
    _currentPage = AppPage.storyDetail;
    notifyListeners();
  }

  void goToAddStory() {
    _currentPage = AppPage.addStory;
    notifyListeners();
  }

  void goToLocationPicker({LatLng? initialLocation}) {
    _initialLocationForPicker = initialLocation;
    _currentPage = AppPage.locationPicker;
    notifyListeners();
  }

  void setPickedLocation(LatLng location) {
    _initialLocationForPicker = location;
    notifyListeners();
  }

  void goBack() {
    if (_currentPage == AppPage.locationPicker) {
      goToAddStory();
    } else if (_currentPage == AppPage.storyDetail) {
      goToHome();
    } else if (_currentPage == AppPage.storyList ||
        _currentPage == AppPage.addStory) {
      goToHome();
    } else {
      goToLogin();
    }
  }
}

class AppRouteDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  final GlobalKey<NavigatorState> navigatorKey;

  final RouteState routeState;
  AddStoryScreen? _addStoryScreen;

  AppRouteDelegate(this.routeState)
    : navigatorKey = GlobalKey<NavigatorState>() {
    routeState.addListener(notifyListeners);
  }

  @override
  void dispose() {
    routeState.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Page> stack;

    switch (routeState.currentPage) {
      case AppPage.splash:
        stack = [
          MaterialPage(child: SplashScreen(), key: ValueKey('SplashScreen')),
        ];
        break;
      case AppPage.login:
        stack = [
          MaterialPage(child: LoginScreen(), key: ValueKey('LoginScreen')),
        ];
        break;
      case AppPage.register:
        stack = [
          MaterialPage(
            child: RegisterScreen(),
            key: ValueKey('RegisterScreen'),
          ),
        ];
        break;
      case AppPage.home:
        stack = [
          MaterialPage(child: HomeScreen(), key: ValueKey('HomeScreen')),
        ];
        break;
      case AppPage.storyList:
        stack = [
          MaterialPage(
            child: StoryListScreen(),
            key: ValueKey('StoryListScreen'),
          ),
        ];
        break;
      case AppPage.storyDetail:
        final storyId = routeState.selectedStoryId;
        if (storyId == null) {
          stack = [
            MaterialPage(
              child: StoryListScreen(),
              key: ValueKey('StoryListScreen'),
            ),
          ];
        } else {
          stack = [
            MaterialPage(
              child: StoryListScreen(),
              key: ValueKey('StoryListScreen'),
            ),
            MaterialPage(
              child: StoryDetailScreen(storyId: storyId),
              key: ValueKey('StoryDetailScreen-$storyId'),
            ),
          ];
        }
        break;
      case AppPage.addStory:
        _addStoryScreen ??= AddStoryScreen();
        stack = [
          MaterialPage(
            child: StoryListScreen(),
            key: ValueKey('StoryListScreen'),
          ),
          MaterialPage(
            child: _addStoryScreen!,
            key: ValueKey('AddStoryScreen'),
          ),
        ];
        break;

      case AppPage.locationPicker:
        _addStoryScreen ??= AddStoryScreen();
        stack = [
          MaterialPage(
            child: StoryListScreen(),
            key: ValueKey('StoryListScreen'),
          ),
          MaterialPage(
            child: _addStoryScreen!,
            key: ValueKey('AddStoryScreen'),
          ),
          MaterialPage(
            child: LocationPickerScreen(
              initialLocation: routeState.initialLocationForPicker,
            ),
            key: ValueKey('LocationPickerScreen'),
          ),
        ];
        break;
    }

    return Navigator(
      key: navigatorKey,
      pages: stack,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        routeState.goBack();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(void configuration) async {
    // No deep linking support for now
  }
}
