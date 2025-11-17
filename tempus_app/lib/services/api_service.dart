import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:tempus_app/services/authentication_service.dart';
import 'package:auth0_flutter/auth0_flutter.dart';

class ApiService {
  final AuthenticationService _authService;

  String get _baseUrl {
    return "https://tempusapi.fly.dev";
  }

  ApiService(this._authService);

  Future<Map<String, String>> _getAuthHeaders() async {
    final Credentials? credentials = _authService.credentials;

    if (credentials == null) {
      print('--- API ERROR: _getAuthHeaders ---');
      print('User credentials are null. Cannot create auth headers.');
      print('---------------------------------');
      throw Exception('User is not authenticated.');
    }

    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer ${credentials.accessToken}'
    };
  }

  Future<void> syncUser() async {
    // ... (This logic should be updated with logging too)
  }

  Future<String?> initiateFocus(DateTime startTime, int studyingMinutes,
      [int? breakMinutes]) async {

    final url = Uri.parse('$_baseUrl/SessionFocus');
    Map<String, String> headers;
    String body;

    try {
      headers = await _getAuthHeaders();
      body = jsonEncode({
        'startTime': startTime.toIso8601String(),
        'studyingMinutes': studyingMinutes,
        'breakMinutes': breakMinutes,
      });
    } catch (e) {
      print('Error preparing request: $e');
      return null;
    }

    print('--- API REQUEST: initiateFocus ---');
    print('URL: $url');
    print('METHOD: POST');
    print('HEADERS: $headers');
    print('BODY: $body');
    print('----------------------------------');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      print('--- API RESPONSE: initiateFocus ---');
      print('STATUS CODE: ${response.statusCode}');
      print('BODY: ${response.body}');
      print('-----------------------------------');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Failed to initiate focus. Status was not 200.');
        return null;
      }
    } catch (e) {
      print('--- API ERROR: initiateFocus ---');
      print('Exception during HTTP call: $e');
      print('--------------------------------');
      return null;
    }
  }

  Future<void> stopFocus(String sessionUuid) async {
    // ... (This logic should be updated with logging too)
  }
}