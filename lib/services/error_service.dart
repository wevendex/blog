import 'package:flutter/material.dart';

class ErrorService {
  static final ErrorService _instance = ErrorService._internal();
  factory ErrorService() => _instance;
  ErrorService._internal();

  final GlobalKey<ScaffoldMessengerState> messengerKey = GlobalKey<ScaffoldMessengerState>();

  void showError(String message) {
    final ctx = messengerKey.currentContext;
    if (ctx == null) return;
    messengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red, duration: const Duration(seconds: 3)),
    );
  }
}