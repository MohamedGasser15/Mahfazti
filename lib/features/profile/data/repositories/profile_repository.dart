// features/profile/data/repositories/profile_repository.dart
import 'dart:convert';
import 'package:my_wallet/core/constants/api_constants.dart';
import 'package:my_wallet/core/services/api_service.dart';
import 'package:my_wallet/core/utils/shared_prefs.dart';
import 'package:my_wallet/features/profile/data/models/user_profile.dart';

class ProfileRepository {
  final ApiService _apiService = ApiService();

  // Fetch profile from API and update local storage
  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiService.get(
        ApiEndpoints.profileGet,
        requiresAuth: true,
      );
      final data = response.data as Map<String, dynamic>;
      final profile = UserProfile.fromJson(data);
      // Save to SharedPrefs for offline use
      await SharedPrefs.setUserData(jsonEncode(profile.toJson()));
      return profile;
    } catch (e) {
      // Fallback to local data if API fails
      final userDataString = SharedPrefs.userData;
      if (userDataString != null) {
        final data = jsonDecode(userDataString);
        return UserProfile.fromJson(data);
      }
      rethrow;
    }
  }
  Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  if (newPassword != confirmPassword) {
    throw Exception('New passwords do not match');
  }

  final response = await _apiService.post(
    ApiEndpoints.changePassword,
    {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    },
    requiresAuth: true,
  );

  // Handle different response formats
  bool success = false;
  if (response.data is bool) {
    success = response.data as bool;
  } else if (response.data is String) {
    success = response.data.toLowerCase() == 'true';
  } else if (response.data is Map<String, dynamic>) {
    success = response.data['success'] == true;
  }

  if (!success) {
    final message = (response.data is Map && response.data['message'] != null)
        ? response.data['message']
        : 'Failed to change password';
    throw Exception(message);
  }

  // Update local passcode
  await SharedPrefs.setString('user_password', newPassword);
}
Future<UserProfile?> getCachedProfile() async {
  final userDataString = SharedPrefs.userData;
  if (userDataString != null) {
    return UserProfile.fromJson(jsonDecode(userDataString));
  }
  return null;
}
  // Update profile via PUT and refresh local storage
  Future<UserProfile> updateProfile({
    required String fullName,
    required String userName,
    required String phoneNumber,
    String? profileImage,
  }) async {
    final response = await _apiService.put(
      ApiEndpoints.profileUpdate,
      {
        'fullName': fullName,
        'userName': userName,
        'phoneNumber': phoneNumber,
        // 'profileImage': profileImage, // if image upload is implemented
      },
      requiresAuth: true,
    );
    final data = response.data as Map<String, dynamic>;
    final updated = UserProfile.fromJson(data);

    // Update local SharedPrefs
    final currentUserData = SharedPrefs.userData != null
        ? jsonDecode(SharedPrefs.userData!)
        : {};
    currentUserData['fullName'] = updated.fullName;
    currentUserData['userName'] = updated.userName;
    currentUserData['phoneNumber'] = updated.phoneNumber;
    if (updated.profileImageUrl != null) {
      currentUserData['profileImageUrl'] = updated.profileImageUrl;
    }
    await SharedPrefs.setUserData(jsonEncode(currentUserData));

    return updated;
  }
}