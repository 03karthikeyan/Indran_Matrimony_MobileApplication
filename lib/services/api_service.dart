import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://pheonixconstructions.com/Matrimony API';

  static Future<Map<String, dynamic>> login(String mobile) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/login.php?mobile=$mobile'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to send OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyOtp(
    String mobile,
    String otp,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/otp_verify.php?mobile=$mobile&otp=$otp'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to verify OTP'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> registerUser(
    Map<String, String> userData,
  ) async {
    try {
      // Convert parameters to query string
      final uri = Uri.parse(
        '$baseUrl/register_user.php',
      ).replace(queryParameters: userData);

      final response = await http
          .get(
            uri,
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          )
          .timeout(Duration(seconds: 30));

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'success' ||
              responseData['success'] == true) {
            return {'success': true, 'data': responseData};
          } else {
            return {
              'success': false,
              'error': responseData['message'] ?? 'Registration failed',
            };
          }
        } catch (jsonError) {
          print('Raw Response: ${response.body}');

          return {'success': false, 'error': 'Invalid server response'};
        }
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  //Religion API

  static Future<List<String>> getReligions() async {
    final uri = Uri.parse("$baseUrl/religionList.php");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        return List<String>.from(
          jsonData['data'].map((item) => item['religion']),
        );
      } else {
        throw Exception("No religion data found");
      }
    } else {
      throw Exception("Failed to load religion data");
    }
  }

  //State API
  static Future<List<String>> getStates() async {
    final uri = Uri.parse("$baseUrl/state_list.php");
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        return List<String>.from(
          jsonData['data'].map((item) => item['entity_name']),
        );
      } else {
        throw Exception("No State data found");
      }
    } else {
      throw Exception("Failed to load State data");
    }
  }

  //subscription list

  static Future<Map<String, dynamic>> getSubscriptionPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription_plan_list.php'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to load subscription plans'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> purchaseSubscription(
    String userId,
    String planId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/subscription.php?user_id=$userId&plan_id=$planId'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to purchase subscription'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  //Profile matches

  static Future<Map<String, dynamic>> getMatchingProfiles(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/matching_profile.php?user_id=$userId'),
      );

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to load matches'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }
}
