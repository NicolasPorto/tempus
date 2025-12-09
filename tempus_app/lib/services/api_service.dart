import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:tempus_app/services/authentication_service.dart';
import 'package:tempus_app/libraries/globals.dart';
import 'package:tempus_app/models/category.dart';
import 'package:tempus_app/models/task.dart';

class ApiService {
  final AuthenticationService _authService;
  final TempusGlobals _globals;

  String get _baseUrl {
    return "https://tempusapi.fly.dev";
  }
  ApiService(this._authService, this._globals);

  Future<T> _requestWrapper<T>(Future<T> Function() request) async {
    _globals.startLoading();
    try {
      return await request();
    } finally {
      _globals.stopLoading();
    }
  }

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

  Future<String?> initiateFocus(DateTime startTime, int studyingMinutes,
      String categoryUuid, [int? breakMinutes]) async {
    return _requestWrapper(() async {
      final url = Uri.parse('$_baseUrl/SessionFocus');
      Map<String, String> headers;
      String body;

      try {
        headers = await _getAuthHeaders();
        body = jsonEncode({
          'startTime': startTime.toIso8601String(),
          'studyingMinutes': studyingMinutes,
          'breakMinutes': breakMinutes,
          'auth0UserId': _authService.credentials!.user.sub,
          'categoryUuid': categoryUuid
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
          return response.body.replaceAll('"', '');
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
    });
  }

  Future<String?> createCategory(String categoryName, String hexColor) async {
    return _requestWrapper(() async {
      final url = Uri.parse('$_baseUrl/Category');
      Map<String, String> headers;
      String body;

      try {
        headers = await _getAuthHeaders();
        body = jsonEncode({
          'HexColor': hexColor,
          'Name': categoryName,
          'Auth0Identifier': _authService.credentials!.user.sub
        });
      } catch (e) {
        print('Error preparing request: $e');
        return null;
      }

      print('--- API REQUEST: createCategory ---');
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

        print('--- API RESPONSE: createCategory ---');
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('-----------------------------------');

        if (response.statusCode == 200) {
          return response.body;
        } else {
          print('Failed to create category. Status was not 200.');
          return null;
        }
      } catch (e) {
        print('--- API ERROR: createCategory ---');
        print('Exception during HTTP call: $e');
        print('--------------------------------');
        return null;
      }
    });
  }

  Future<void> removeCategory(String categoryUuid) async {
    return _requestWrapper(() async {
      final url = Uri.parse('$_baseUrl/Category/$categoryUuid');
      Map<String, String> headers;

      try {
        headers = await _getAuthHeaders();
      } catch (e) {
        print('Error preparing request: $e');
        return;
      }

      print('--- API REQUEST: removeCategory ---');
      print('URL: $url');
      print('METHOD: DELETE');
      print('HEADERS: $headers');
      print('----------------------------------');

      try {
        final response = await http.delete(url, headers: headers);

        print('--- API RESPONSE: removeCategory ---');
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('-----------------------------------');

        if (response.statusCode == 200) {
          return;
        } else {
          print('Failed to remove category. Status was not 200.');
          return;
        }
      } catch (e) {
        print('--- API ERROR: removeCategory ---');
        print('Exception during HTTP call: $e');
        print('--------------------------------');
        return;
      }
    });
  }

  Future<List<Category>> listAllCategories() async {
    return _requestWrapper(() async {
      final identifier = _authService.credentials!.user.sub;
      final url = Uri.parse('$_baseUrl/Category/$identifier');
      Map<String, String> headers;

      try {
        headers = await _getAuthHeaders();
      } catch (e) {
        print('Error preparing request: $e');
        return [];
      }

      print('--- API REQUEST: listAllCategories ---');
      print('URL: $url');
      print('METHOD: GET');
      print('HEADERS: $headers');
      print('----------------------------------');

      try {
        final response = await http.get(url, headers: headers);

        print('--- API RESPONSE: listAllCategories ---');
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('-----------------------------------');

        if (response.statusCode == 200) {
          final List<dynamic> parsedJson = jsonDecode(response.body);
          return parsedJson
              .map((x) => Category.fromJson(x as Map<String, dynamic>))
              .toList();
        } else {
          print('Failed to list categories. Status was not 200.');
          return [];
        }
      } catch (e) {
        print('--- API ERROR: listAllCategories ---');
        print('Exception during HTTP call: $e');
        print('--------------------------------');
        return [];
      }
    });
  }

  Future<dynamic> obtainAverageSessionStats() async {
    return _requestWrapper(() async {
      final identifier = _authService.credentials!.user.sub;
      final url = Uri.parse('$_baseUrl/SessionFocus/stats/average/$identifier');
      Map<String, String> headers;

      try {
        headers = await _getAuthHeaders();
      } catch (e) {
        print('Error preparing request: $e');
        return [];
      }

      print('--- API REQUEST: obtainAverageSessionStats ---');
      print('URL: $url');
      print('METHOD: GET');
      print('HEADERS: $headers');
      print('----------------------------------');

      try {
        final response = await http.get(url, headers: headers);

        print('--- API RESPONSE: obtainAverageSessionStats ---');
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('-----------------------------------');

        if (response.statusCode == 200) {
          final parsedJson = jsonDecode(response.body);
          return parsedJson;
        } else {
          print('Failed to obtain stats. Status was not 200.');
          return [];
        }
      } catch (e) {
        print('--- API ERROR: obtainAverageSessionStats ---');
        print('Exception during HTTP call: $e');
        print('--------------------------------');
        return [];
      }
    });
  }

  Future<dynamic> obtainFinishedSessions() async {
    return _requestWrapper(() async {
      final identifier = _authService.credentials!.user.sub;
      final url =
      Uri.parse('$_baseUrl/SessionFocus/stats/finished-sessions/$identifier');
      Map<String, String> headers;

      try {
        headers = await _getAuthHeaders();
      } catch (e) {
        print('Error preparing request: $e');
        return [];
      }

      print('--- API REQUEST: obtainFinishedSessions ---');
      print('URL: $url');
      print('METHOD: GET');
      print('HEADERS: $headers');
      print('----------------------------------');

      try {
        final response = await http.get(url, headers: headers);

        print('--- API RESPONSE: obtainFinishedSessions ---');
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('-----------------------------------');

        if (response.statusCode == 200) {
          final parsedJson = jsonDecode(response.body);
          return parsedJson['finishedSessions'];
        } else {
          print('Failed to obtain finished sessions. Status was not 200.');
          return [];
        }
      } catch (e) {
        print('--- API ERROR: obtainFinishedSessions ---');
        print('Exception during HTTP call: $e');
        print('--------------------------------');
        return [];
      }
    });
  }

  Future<dynamic> obtainSessionStreak() async {
    return _requestWrapper(() async {
      final identifier = _authService.credentials!.user.sub;
      final url =
      Uri.parse('$_baseUrl/SessionFocus/stats/session-streak/$identifier');
      Map<String, String> headers;

      try {
        headers = await _getAuthHeaders();
      } catch (e) {
        print('Error preparing request: $e');
        return [];
      }

      print('--- API REQUEST: obtainSessionStreak ---');
      print('URL: $url');
      print('METHOD: GET');
      print('HEADERS: $headers');
      print('----------------------------------');

      try {
        final response = await http.get(url, headers: headers);

        print('--- API RESPONSE: obtainSessionStreak ---');
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('-----------------------------------');

        if (response.statusCode == 200) {
          final parsedJson = jsonDecode(response.body);
          return parsedJson['currentStreak'];
        } else {
          print('Failed to obtain streak. Status was not 200.');
          return [];
        }
      } catch (e) {
        print('--- API ERROR: obtainSessionStreak ---');
        print('Exception during HTTP call: $e');
        print('--------------------------------');
        return [];
      }
    });
  }

  Future<void> stopFocus(String sessionUuid, [DateTime? dtFinishTime]) async {
    return _requestWrapper(() async {
      final dtFinishTime = DateTime.now();

      final uri = Uri.parse('$_baseUrl/SessionFocus/stop/$sessionUuid');
      final url = uri.replace(queryParameters: {
        'dtFinishTime': dtFinishTime.toIso8601String(),
      });

      Map<String, String> headers;

      try {
        headers = await _getAuthHeaders();
      } catch (e) {
        print('Error preparing request: $e');
        return;
      }

      print('--- API REQUEST: stopFocus ---');
      print('URL: $url');
      print('METHOD: PUT');
      print('HEADERS: $headers');
      print('----------------------------------');

      try {
        final response = await http.put(
          url,
          headers: headers,
        );

        print('--- API RESPONSE: stopFocus ---');
        print('STATUS CODE: ${response.statusCode}');
        print('BODY: ${response.body}');
        print('-----------------------------------');

        if (response.statusCode == 200) {
          return;
        } else {
          print('Failed to stop focus. Status was not 200.');
          return;
        }
      } catch (e) {
        print('--- API ERROR: stopFocus ---');
        print('Exception during HTTP call: $e');
        print('--------------------------------');
        return;
      }
    });
  }

  Future<List<TaskItem>> getAllTasks() async {
    return _requestWrapper(() async {
      final identifier = _authService.credentials?.user.sub;
      if (identifier == null) return [];

      final url = Uri.parse('$_baseUrl/Task/$identifier');

      try {
        final headers = await _getAuthHeaders();
        final response = await http.get(url, headers: headers);

        if (response.statusCode == 200) {
          final List<dynamic> parsedJson = jsonDecode(response.body);
          print(parsedJson);
          return parsedJson
              .map((x) => TaskItem.fromJson(x as Map<String, dynamic>))
              .toList();
        } else {
          print('Failed to fetch tasks. Status: ${response.statusCode}');
          return [];
        }
      } catch (e) {
        print('Error fetching tasks: $e');
        return [];
      }
    });
  }

  Future<bool> createTask(String title, String categoryUuid,
      {int minutesMeta = 25}) async {
    return _requestWrapper(() async {
      final url = Uri.parse('$_baseUrl/Task');

      try {
        final headers = await _getAuthHeaders();
        final body = jsonEncode({
          'Name': title,
          'MinutesMeta': minutesMeta,
          'CategoryUUID': categoryUuid,
          'Auth0Identifier': _authService.credentials?.user.sub,
        });

        final response = await http.post(url, headers: headers, body: body);
        return response.statusCode == 200;
      } catch (e) {
        print('Error creating task: $e');
        return false;
      }
    });
  }

  Future<bool> toggleTaskStatus(String taskUuid, bool isDone) async {
    return _requestWrapper(() async {
      final url = Uri.parse('$_baseUrl/Task/toggle/$taskUuid?done=$isDone');

      try {
        final headers = await _getAuthHeaders();
        final response = await http.post(url, headers: headers);
        return response.statusCode == 200;
      } catch (e) {
        print('Error finishing task: $e');
        return false;
      }
    });
  }

  Future<bool> deleteTask(String taskUuid) async {
    return _requestWrapper(() async {
      final url = Uri.parse('$_baseUrl/Task/$taskUuid');

      try {
        final headers = await _getAuthHeaders();
        final response = await http.delete(url, headers: headers);
        return response.statusCode == 200;
      } catch (e) {
        print('Error deleting task: $e');
        return false;
      }
    });
  }
}