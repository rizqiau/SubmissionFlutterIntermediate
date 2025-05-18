import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../db/auth_repository.dart';
import '../models/user.dart';
import '../routes/route_delegate.dart';

class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final authRepo = context.read<AuthRepository>();
      final user = User(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      final result = await authRepo.register(user);
      if (result) {
        setState(() {
          _successMessage = "Registration successful! Please login.";
        });
        Future.delayed(Duration(seconds: 2), () {
          context.read<RouteState>().goToLogin();
        });
      } else {
        setState(() {
          _errorMessage = "Registration failed.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeState = context.read<RouteState>();

    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: Colors.red)),
              if (_successMessage != null)
                Text(_successMessage!, style: TextStyle(color: Colors.green)),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator:
                    (val) =>
                        val != null && val.isNotEmpty
                            ? null
                            : "Name is required",
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator:
                    (val) =>
                        val != null && val.contains('@')
                            ? null
                            : "Enter valid email",
                keyboardType: TextInputType.emailAddress,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                validator:
                    (val) =>
                        val != null && val.length >= 8
                            ? null
                            : "Password min 8 characters",
                obscureText: true,
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _register,
                    child: Text("Register"),
                  ),
              TextButton(
                onPressed: () => routeState.goToLogin(),
                child: Text("Already have an account? Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
