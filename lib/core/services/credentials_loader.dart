import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/friends/services/fcm_push_service.dart';

class CredentialsLoader {
  /// Load Firebase service account credentials from assets
  static Future<void> loadFirebaseCredentials() async {
    try {
      // Load credentials from assets (create this file in assets folder)
      final String credentialsJson = await rootBundle.loadString(
        'assets/firebase_credentials.json',
      );

      final Map<String, dynamic> credentials = json.decode(credentialsJson);

      // Initialize FCM service with credentials
      FCMPushService.initializeCredentials(credentials);

      print('✅ Firebase credentials loaded successfully');
    } catch (e) {
      print('❌ Error loading Firebase credentials: $e');
      print(
        '⚠️  Using fallback method - credentials should be added to assets',
      );

      // Fallback: Initialize with empty credentials (notifications will fail)
      FCMPushService.initializeCredentials({});
    }
  }
}
