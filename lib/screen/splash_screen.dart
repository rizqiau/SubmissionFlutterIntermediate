import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/auth_repository.dart';
import '../routes/route_delegate.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final authRepo = context.read<AuthRepository>();
    final token = await authRepo.getToken();
    final routeState = context.read<RouteState>();

    await Future.delayed(Duration(seconds: 2)); // Simulate loading

    if (token != null) {
      routeState.goToHome();
    } else {
      routeState.goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
