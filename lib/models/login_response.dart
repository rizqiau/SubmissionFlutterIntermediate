class LoginResponse {
  final bool error;
  final String message;
  final String token;
  final String name;

  LoginResponse({
    required this.error,
    required this.message,
    required this.token,
    required this.name,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      error: json['error'],
      message: json['message'],
      token: json['loginResult']?['token'] ?? '',
      name: json['loginResult']?['name'] ?? '',
    );
  }
}
