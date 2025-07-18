import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:bharat_worker/models/profile_model.dart';

class PreferencesServices {
  static String registerUserIdentityDetails = "RegisterUserIdentityDetails";
  static String loginUserIdentityDetails = "LoginUserIdentityDetails";
  static String deviceId = "deviceId";
  static String deviceType = "deviceType";
  static String isLogin = "isLogin";
  static String fcm = "FCM";
  static String idToken = "Id Token";
  static String userToken = "user Token";
  static String userId = "userId";
  static String userName = "userName";
  static String userEmail = "userEmail";
  static String loginType = "LoginType";
  static String profilePendingScreens = "profilePendingScreens";


  ///..... SharePrefences save data ........
  static void setPreferencesData(String key, dynamic data) async {
    final prefences = await SharedPreferences.getInstance();
    if (data is String) {
      prefences.setString(key, data);
    } else if (data is int) {
      prefences.setInt(key, data);
    } else if (data is bool) {
      prefences.setBool(key, data);
    } else if (data is double) {
      prefences.setDouble(key, data);
    } else {
      debugPrint("Invalid datatype");
    }
  }

  static Future<dynamic> getPreferencesData(String key) async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.containsKey(key)) {
      // Try to determine the type of the stored data
      dynamic data = preferences.get(key);
      return data;
    } else {
      debugPrint("Key not found");
      return null;
    }
  }

  static void setLogoutPreferencesData(){

    setPreferencesData(isLogin, false);
    setPreferencesData(userToken,"");
  }


  ///---------------------Delete Data------------------------

  static Future<bool> deleteData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }


  ///---------------------Clear all Data------------------------

  static Future clearData() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.clear();
  }

  static const String themeModeKey = 'theme_mode';

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
  }

  static ThemeMode getThemeMode() {
    final prefs = SharedPreferences.getInstance();
    final modeString = prefs.then((p) => p.getString(themeModeKey) ?? 'system');
    if (modeString == 'dark') return ThemeMode.dark;
    if (modeString == 'light') return ThemeMode.light;
    return ThemeMode.system;
  }

  static String profileDataKey = "profileData";

  static Future<void> saveProfileData(ProfileResponse profile) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(profileDataKey, jsonEncode(_profileToJson(profile)));
  }

  static Future<ProfileResponse?> getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(profileDataKey);
    if (jsonString == null) return null;
    return ProfileResponse.fromJson(jsonDecode(jsonString));
  }

  static Map<String, dynamic> _profileToJson(ProfileResponse profile) {
    return {
      'success': profile.success,
      'message': profile.message,
      'data': profile.data != null ? {
        'token': profile.data!.token,
        'jwtToken': profile.data!.jwtToken,
        'user': profile.data!.user != null ? {
          '_id': profile.data!.user!.id,
          'name': profile.data!.user!.name,
          'role': profile.data!.user!.role,
          'email': profile.data!.user!.email,
          'phone': profile.data!.user!.phone,
          'isActive': profile.data!.user!.isActive,
          '__v': profile.data!.user!.v,
        } : null,
        'partner': profile.data!.partner != null ? {
          'referredBy': profile.data!.partner!.referredBy,
          '_id': profile.data!.partner!.id,
          'user': profile.data!.partner!.userId,
          'address': profile.data!.partner!.address,
          'latitude': profile.data!.partner!.latitude,
          'longitude': profile.data!.partner!.longitude,
          'city': profile.data!.partner!.city,
          'state': profile.data!.partner!.state,
          'country': profile.data!.partner!.country,
          'pincode': profile.data!.partner!.pincode,
          'bookingHistory': profile.data!.partner!.bookingHistory,
          'paymentHistory': profile.data!.partner!.paymentHistory,
          'complaints': profile.data!.partner!.complaints,
          'aadharFront': profile.data!.partner!.aadharFront,
          'aadharBack': profile.data!.partner!.aadharBack,
          'aadharNo': profile.data!.partner!.aadharNo,
          'panFront': profile.data!.partner!.panFront,
          'panBack': profile.data!.partner!.panBack,
          'panNo': profile.data!.partner!.panNo,
          'experienceCertificates': profile.data!.partner!.experienceCertificates,
          'kycStatus': profile.data!.partner!.kycStatus,
          'kycRejectionReason': profile.data!.partner!.kycRejectionReason,
          'isOnline': profile.data!.partner!.isOnline,
          'profilePendingScreens': profile.data!.partner!.profilePendingScreens,
          'performanceScore': profile.data!.partner!.performanceScore,
          'dob': profile.data!.partner!.dob,
          'profile': profile.data!.partner!.profile,
          'serviceAreaDistance': profile.data!.partner!.serviceAreaDistance,
          'isSuspended': profile.data!.partner!.isSuspended,
          'category': profile.data!.partner!.category,
          'subCategory': profile.data!.partner!.subCategory,
          'categoryType': profile.data!.partner!.categoryType,
          'profileCompletion': profile.data!.partner!.profileCompletion,
          'skills': profile.data!.partner!.skills?.map((e) => e.toJson()).toList(),
          '__v': profile.data!.partner!.v,
          'referralCode': profile.data!.partner!.referralCode,
        } : null,
      } : null,
    };
  }
}
