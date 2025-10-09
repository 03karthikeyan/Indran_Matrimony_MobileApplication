import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:matrimony/models/ProfileView.dart';
import 'package:matrimony/models/user_data.dart';

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

  //subscription Status API

  static Future<Map<String, dynamic>> getSubscriptionStatus(int userId) async {
    final url =
        "https://pheonixconstructions.com/Matrimony%20API/subscription_status.php?user_id=$userId";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {"status": "error", "message": "Server error"};
      }
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  //Profile matches

  static Future<Map<String, dynamic>> getMatchingProfiles(
    int userId, {
    Map<String, String>? filters,
  }) async {
    try {
      String url = '$baseUrl/matching_profile.php?user_id=$userId';

      if (filters != null) {
        filters.forEach((key, value) {
          if (value.isNotEmpty) {
            url += '&$key=$value';
          }
        });
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return {'success': true, 'data': json.decode(response.body)};
      } else {
        return {'success': false, 'error': 'Failed to load matches'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getFilteredMatches(
    int userId, {
    int? fromAge,
    int? toAge,
    String? higherEducation,
    String? employeeIn,
    String? city,
    int? fromIncome,
    int? toIncome,
  }) async {
    try {
      Map<String, String> filters = {};

      if (fromAge != null) filters['from_age'] = fromAge.toString();
      if (toAge != null) filters['to_age'] = toAge.toString();
      if (higherEducation != null && higherEducation.isNotEmpty)
        filters['higher_education'] = higherEducation;
      if (employeeIn != null && employeeIn.isNotEmpty)
        filters['employee_in'] = employeeIn;
      if (city != null && city.isNotEmpty) filters['city'] = city;
      if (fromIncome != null) filters['from_income'] = fromIncome.toString();
      if (toIncome != null) filters['to_income'] = toIncome.toString();

      return await getMatchingProfiles(userId, filters: filters);
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  //Message Get API

  static Future<Map<String, dynamic>> getMessages({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/get_messages.php?sender_id=$senderId&receiver_id=$receiverId',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to load messages'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  //Send Message API

  static Future<Map<String, dynamic>> sendMessage({
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      final uri = Uri.parse(
        "$baseUrl/send_message.php?sender_id=$senderId&receiver_id=$receiverId&message=${Uri.encodeComponent(message)}",
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': data['success'] ?? false,
          'message': data['message'] ?? 'Unknown response',
        };
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  //Fetching method for Profile data

  static Future<Map<String, dynamic>> getProfiles(int userId) async {
    try {
      String url = '$baseUrl/profile_fetch.php?user_id=$userId';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          return {
            'success': true,
            'user_data': data['user_data'],
            'badge': data['badge'],
          };
        } else {
          return {'success': false, 'error': 'Profile not found'};
        }
      } else {
        return {'success': false, 'error': 'Failed to load profile'};
      }
    } catch (e) {
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  //Update Profile Method
  static Future<Map<String, dynamic>> updateProfile(UserData user) async {
    final apiUrl =
        "https://pheonixconstructions.com/Matrimony API/profile_update.php";

    try {
      // Only send allowed fields, but include user_id
      final Map<String, String> params = {
        "user_id": user.userId?.toString() ?? '', // ✅ Required
        "name": user.name != null ? Uri.encodeQueryComponent(user.name!) : '',
        "email_id":
            user.emailId != null ? Uri.encodeQueryComponent(user.emailId!) : '',
        "dob": user.dob != null ? Uri.encodeQueryComponent(user.dob!) : '',
        "age": user.age ?? '',
        "gender":
            user.gender != null ? Uri.encodeQueryComponent(user.gender!) : '',
        "religion":
            user.religion != null
                ? Uri.encodeQueryComponent(user.religion!)
                : '',
        "inter_caste":
            user.interCaste != null
                ? Uri.encodeQueryComponent(user.interCaste!)
                : '',
        "caste":
            user.caste != null ? Uri.encodeQueryComponent(user.caste!) : '',
        "sub_caste":
            user.subCaste != null
                ? Uri.encodeQueryComponent(user.subCaste!)
                : '',
        "dosham":
            user.dosham != null ? Uri.encodeQueryComponent(user.dosham!) : '',
        "higher_education":
            user.higherEducation != null
                ? Uri.encodeQueryComponent(user.higherEducation!)
                : '',
        "employee_in":
            user.employeeIn != null
                ? Uri.encodeQueryComponent(user.employeeIn!)
                : '',
        "occupation":
            user.occupation != null
                ? Uri.encodeQueryComponent(user.occupation!)
                : '',
        "annual_income": user.annualIncome ?? '',
        "work_location":
            user.workLocation != null
                ? Uri.encodeQueryComponent(user.workLocation!)
                : '',
        "state":
            user.state != null ? Uri.encodeQueryComponent(user.state!) : '',
        "city": user.city != null ? Uri.encodeQueryComponent(user.city!) : '',
        "about_yourself":
            user.aboutYourself != null
                ? Uri.encodeQueryComponent(user.aboutYourself!)
                : '',
        "marital_status":
            user.maritalStatus != null
                ? Uri.encodeQueryComponent(user.maritalStatus!)
                : '',
        "skin_color":
            user.skinColor != null
                ? Uri.encodeQueryComponent(user.skinColor!)
                : '',
        "height": user.height ?? '',
        "weight": user.weight ?? '',
        "physical_status": user.physicalStatus ?? '',
        "financial_status": user.financialStatus ?? '',
        "district":
            user.district != null
                ? Uri.encodeQueryComponent(user.district!)
                : '',
        "address_lane1":
            user.addressLane1 != null
                ? Uri.encodeQueryComponent(user.addressLane1!)
                : '',
        "address_lane2":
            user.addressLane2 != null
                ? Uri.encodeQueryComponent(user.addressLane2!)
                : '',
        "pincode": user.pincode ?? '',
        "father_name":
            user.fatherName != null
                ? Uri.encodeQueryComponent(user.fatherName!)
                : '',
        "mother_name":
            user.motherName != null
                ? Uri.encodeQueryComponent(user.motherName!)
                : '',
        "siblings":
            user.siblings != null
                ? Uri.encodeQueryComponent(user.siblings!)
                : '',
        "native_place":
            user.nativePlace != null
                ? Uri.encodeQueryComponent(user.nativePlace!)
                : '',
        "mother_tongue":
            user.motherTongue != null
                ? Uri.encodeQueryComponent(user.motherTongue!)
                : '',
        "hobbies":
            user.diet != null ? Uri.encodeQueryComponent(user.diet!) : '',
        "interests":
            user.hobbies != null ? Uri.encodeQueryComponent(user.hobbies!) : '',
        "diet":
            user.interests != null
                ? Uri.encodeQueryComponent(user.interests!)
                : '',
        "profileFor":
            user.profileFor != null
                ? Uri.encodeQueryComponent(user.profileFor!)
                : '',
        "profile_img": user.profileImg ?? '',
        "profile_img_path": user.profileImgPath ?? '',
        "aadhar_img_path": user.aadharImgPath ?? '',
        "community_certificate_path": user.communityCertificatePath ?? '',
        "jathakam_path": user.jathakamPath ?? '',
        "badge": user.badge ?? '',
        "user_sts": (user.isActive == true) ? "0" : "1",
      };

      // Do NOT include contact_no or anything else forbidden
      params.remove('contact_no');

      // Build URI with encoded query parameters
      final uri = Uri.parse(apiUrl).replace(queryParameters: params);

      final response = await http.get(uri);

      print("HTTP status: ${response.statusCode}");
      print("HTTP body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data as Map<String, dynamic>;
        } catch (e) {
          print("JSON decode error: $e");
          return {"success": false, "message": "Invalid JSON response"};
        }
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e, stack) {
      print("Exception in updateProfile: $e");
      print(stack);
      return {"success": false, "message": "Network error: $e"};
    }
  }

  //Active & De- active nethod
  // inside ApiService (import 'dart:convert'; import 'package:http/http.dart' as http;)
  static Future<Map<String, dynamic>> activateUser(int userId) async {
    final url = "$baseUrl/activate_user.php?user_id=$userId";
    try {
      final uri = Uri.parse(Uri.encodeFull(url));
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  // Notice: user gave the endpoint name `de_activete_user.php` earlier.
  // Use whichever is the correct endpoint on the server. I include the spelled version you posted:
  static Future<Map<String, dynamic>> deactivateUser(int userId) async {
    final url =
        "$baseUrl/de_activete_user.php?user_id=$userId"; // <--- use server's exact file name
    try {
      final uri = Uri.parse(Uri.encodeFull(url));
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          "success": false,
          "message": "Server error: ${response.statusCode}",
        };
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  // Send Interest
  static Future<Map<String, dynamic>> sendInterest(
    int senderId,
    int receiverId,
  ) async {
    final url = Uri.parse(
      "$baseUrl/send_interest.php?sender_id=$senderId&receiver_id=$receiverId",
    );
    try {
      final response = await http.get(url); // ✅ API works with GET
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Server error"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  // Respond Interest (accept/decline)
  static Future<Map<String, dynamic>> respondInterest(
    int interestId,
    int receiverId,
    String action,
  ) async {
    final url = Uri.parse(
      "$baseUrl/respond_interest.php?interest_id=$interestId&receiver_id=$receiverId&action=$action",
    );
    try {
      final response = await http.get(url); // ✅ API works with GET
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Server error"};
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  //Viewed Profile data API

  // Who Viewed My Profile → who_viewed_my_profile.php
  // → Shows list of users who viewed your profile.

  // Recently Viewed Profiles → recently_viewed_profiles.php
  // → Shows the profiles that you recently viewed.

  // Who Viewed Profile Recently → who_viewed_profile_recently.php
  // → Shows the users who recently viewed your profile.

  // Who Viewed My Profile
  static Future<List<ProfileView>> fetchWhoViewedMyProfile(
    String profileId,
    int limit,
    int offset,
    String viewerId, // 👈 make viewerId dynamic
  ) async {
    final url = Uri.parse(
      "$baseUrl/who_viewed_my_profile.php?profile_id=$profileId&limit=$limit&offset=$offset&fields=basic&viewer_id=$viewerId",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data']?['recent_profiles'] != null) {
        return (data['data']['recent_profiles'] as List)
            .map((e) => ProfileView.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  // Recently Viewed Profiles
  static Future<List<ProfileView>> fetchRecentlyViewedProfiles(
    String viewerId,
    int limit,
    int offset,
  ) async {
    final url = Uri.parse(
      "$baseUrl/recently_viewed_profiles.php?viewer_id=$viewerId&limit=$limit&offset=$offset&fields=full",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['data']?['recently_viewed'] != null) {
        return (data['data']['recently_viewed'] as List)
            .map((e) => ProfileView.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  // Who Viewed Profile Recently
  static Future<List<ProfileView>> fetchWhoViewedProfileRecently(
    String profileId,
    int limit,
    int offset,
  ) async {
    final url = Uri.parse(
      "$baseUrl/who_viewed_profile_recently.php?profile_id=$profileId&limit=$limit&offset=$offset&fields=full",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true &&
          data['data']?['viewed_by_last_3_days'] != null) {
        return (data['data']['viewed_by_last_3_days'] as List)
            .map((e) => ProfileView.fromJson(e))
            .toList();
      }
    }
    return [];
  }

  //upload image
  static Future<Map<String, dynamic>> uploadProfileImage(
    int userId,
    File imageFile,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/uploadProfileImage.php'),
    );
    request.fields['user_id'] = userId.toString();
    request.files.add(
      await http.MultipartFile.fromPath('profile_img', imageFile.path),
    );

    final response = await request.send();
    final responseData = await http.Response.fromStream(response);

    return json.decode(responseData.body);
  }
}
