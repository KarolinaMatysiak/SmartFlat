import 'package:flutter/material.dart';

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      elevation: 10,
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      duration: const Duration(seconds: 3),
    ),
  );
}