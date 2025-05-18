import 'package:flutter/material.dart';
import '../screen/login_screen.dart';
import '../screen/register_screen.dart';
import '../screen/splash_screen.dart';
import '../screen/home_screen.dart';

enum AppPage { splash, login, register, home }

class RouteState extends ChangeNotifier {
  AppPage _currentPage = AppPage.splash;

  AppPage get currentPage => _currentPage;

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
}

class AppRouteDelegate extends RouterDelegate<Object>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Object> {
  final GlobalKey<NavigatorState> navigatorKey;

  final RouteState routeState;

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
    }

    return Navigator(
      key: navigatorKey,
      pages: stack,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        // Handle back button behavior
        if (routeState.currentPage == AppPage.register) {
          routeState.goToLogin();
        } else if (routeState.currentPage == AppPage.home) {
          routeState.goToLogin();
        }
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(void configuration) async {
    // No deep linking support for now
  }
}
