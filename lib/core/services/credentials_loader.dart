import 'dart:convert';
import 'package:flutter/services.dart';
import '../../features/friends/services/fcm_push_service.dart';

class CredentialsLoader {
  /// Load Firebase service account credentials from assets
  static Future<void> loadFirebaseCredentials() async {
    try {
      // Load credentials from assets
      final String credentialsJson = await rootBundle.loadString(
        'assets/chatas-9469d-firebase-adminsdk-fbsvc-8b422b1d38.json',
      );

      print('✅ Raw credentials loaded, length: ${credentialsJson.length}');

      final Map<String, dynamic> credentials = json.decode(credentialsJson);

      // Fix private key newlines - this is CRITICAL!
      if (credentials['private_key'] != null) {
        String privateKey = credentials['private_key'] as String;
        // Replace literal \n with actual newlines
        privateKey = privateKey.replaceAll('\\n', '\n');
        credentials['private_key'] = privateKey;
        print('🔧 Fixed private key newlines');
        print(
          '🔍 Private key after fix (first 100 chars): ${privateKey.substring(0, 100)}...',
        );
      }

      print('✅ Credentials parsed successfully');
      print('🔍 Project ID from file: ${credentials['project_id']}');
      print('🔍 Client email from file: ${credentials['client_email']}');

      // Initialize FCM service with credentials
      FCMPushService.initializeCredentials(credentials);

      print('✅ Firebase credentials loaded successfully');
    } catch (e) {
      print('❌ Error loading Firebase credentials: $e');
      print('❌ Error type: ${e.runtimeType}');
      print(
        '⚠️  Using fallback method - credentials should be added to assets',
      );

      // Fallback: Initialize with empty credentials (notifications will fail)
      FCMPushService.initializeCredentials({});
    }
  }
}
