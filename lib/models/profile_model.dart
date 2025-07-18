import 'dart:convert';

class ProfileResponse {
  final bool? success;
  final String? message;
  final ProfileData? data;

  ProfileResponse({ this.success,  this.message, this.data});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ProfileData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class ProfileData {
  final String? token;
  final String? jwtToken;
  final UserModel? user;
  final PartnerModel? partner;

  ProfileData({ this.token, this.jwtToken,  this.user,  this.partner});

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      token: json['token'],
      jwtToken: json['jwtToken'],
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      partner: json['partner'] != null ? PartnerModel.fromJson(json['partner']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'jwtToken': jwtToken,
    'user': user?.toJson(),
    'partner': partner?.toJson(),
  };
}

class UserModel {
  final String? id;
  final String? name;
  final String? role;
  final String? email;
  final String? phone;
  final bool? isActive;
  final int? v;

  UserModel({
    this.id,
    this.name,
    this.role,
    this.email,
    this.phone,
    this.isActive,
    this.v,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
      phone: json['phone'],
      isActive: json['isActive'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'role': role,
    'email': email,
    'phone': phone,
    'isActive': isActive,
    '__v': v,
  };
}

class PartnerModel {
  final String? id;
  final String? userId;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? country;
  final int? pincode;
  final String? dob;
  final String? kycStatus;
  final String? kycRejectionReason;
  final bool? isOnline;
  final bool? isSuspended;
  final int? profileCompletion;
  final int? profilePendingScreens;
  final List<dynamic>? bookingHistory;
  final List<dynamic>? paymentHistory;
  final List<dynamic>? complaints;
  final String? aadharFront;
  final String? aadharBack;
  final String? aadharNo;
  final String? panFront;
  final String? panBack;
  final String? panNo;
  final List<String>? experienceCertificates;
  final List<dynamic>? performanceScore;
  final String? profile;
  final int? serviceAreaDistance;
  final List<String>? category;
  final List<String>? subCategory;
  final List<String>? categoryType;
  final List<SkillModel>? skills;
  final int? v;
  final String? referredBy;
  final String? referralCode;

  PartnerModel({
    this.id,
    this.userId,
    this.address,
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.pincode,
    this.dob,
    this.kycStatus,
    this.kycRejectionReason,
    this.isOnline,
    this.isSuspended,
    this.profileCompletion,
    this.profilePendingScreens,
    this.bookingHistory,
    this.paymentHistory,
    this.complaints,
    this.aadharFront,
    this.aadharBack,
    this.aadharNo,
    this.panFront,
    this.panBack,
    this.panNo,
    this.experienceCertificates,
    this.performanceScore,
    this.profile,
    this.serviceAreaDistance,
    this.category,
    this.subCategory,
    this.categoryType,
    this.skills,
    this.v,
    this.referredBy,
    this.referralCode,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['_id'],
      userId: json['user'],
      address: json['address'],
      latitude: json['latitude'] != null ? (json['latitude'] is double ? json['latitude'] : double.tryParse(json['latitude'].toString())) : null,
      longitude: json['longitude'] != null ? (json['longitude'] is double ? json['longitude'] : double.tryParse(json['longitude'].toString())) : null,
      city: json['city'],
      state: json['state'],
      country: json['country'],
      pincode: json['pincode'] is int ? json['pincode'] : int.tryParse(json['pincode'].toString()),
      dob: json['dob'],
      kycStatus: json['kycStatus'],
      kycRejectionReason: json['kycRejectionReason'],
      isOnline: json['isOnline'],
      isSuspended: json['isSuspended'],
      profileCompletion: json['profileCompletion'],
      profilePendingScreens: json['profilePendingScreens'],
      bookingHistory: json['bookingHistory'] ?? [],
      paymentHistory: json['paymentHistory'] ?? [],
      complaints: json['complaints'] ?? [],
      aadharFront: json['aadharFront'],
      aadharBack: json['aadharBack'],
      aadharNo: json['aadharNo'],
      panFront: json['panFront'],
      panBack: json['panBack'],
      panNo: json['panNo'],
      experienceCertificates: (json['experienceCertificates'] as List?)?.map((e) => e.toString()).toList(),
      performanceScore: json['performanceScore'] ?? [],
      profile: json['profile'],
      serviceAreaDistance: json['serviceAreaDistance'] is int ? json['serviceAreaDistance'] : int.tryParse(json['serviceAreaDistance'].toString()),
      category: (json['category'] as List?)?.map((e) => e.toString()).toList() ?? [],
      subCategory: (json['subCategory'] as List?)?.map((e) => e.toString()).toList() ?? [],
      categoryType: (json['categoryType'] as List?)?.map((e) => e.toString()).toList() ?? [],
      skills: (json['skills'] as List?)?.map((e) => SkillModel.fromJson(e)).toList() ?? [],
      v: json['__v'],
      referredBy: json['referredBy'],
      referralCode: json['referralCode'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'user': userId,
    'address': address,
    'latitude': latitude,
    'longitude': longitude,
    'city': city,
    'state': state,
    'country': country,
    'pincode': pincode,
    'dob': dob,
    'kycStatus': kycStatus,
    'kycRejectionReason': kycRejectionReason,
    'isOnline': isOnline,
    'isSuspended': isSuspended,
    'profileCompletion': profileCompletion,
    'profilePendingScreens': profilePendingScreens,
    'bookingHistory': bookingHistory,
    'paymentHistory': paymentHistory,
    'complaints': complaints,
    'aadharFront': aadharFront,
    'aadharBack': aadharBack,
    'aadharNo': aadharNo,
    'panFront': panFront,
    'panBack': panBack,
    'panNo': panNo,
    'experienceCertificates': experienceCertificates,
    'performanceScore': performanceScore,
    'profile': profile,
    'serviceAreaDistance': serviceAreaDistance,
    'category': category,
    'subCategory': subCategory,
    'categoryType': categoryType,
    'skills': skills?.map((e) => e.toJson()).toList(),
    '__v': v,
    'referredBy': referredBy,
    'referralCode': referralCode,
  };
}

class SkillModel {
  final String? id;
  final String? skill;
  final int? yearOfExprence;
  final String? experienceCertificates;

  SkillModel({this.id, this.skill, this.yearOfExprence, this.experienceCertificates});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['_id'],
      skill: json['skill'],
      yearOfExprence: json['yearOfExprence'] is int ? json['yearOfExprence'] : int.tryParse(json['yearOfExprence'].toString()),
      experienceCertificates: json['experienceCertificates'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'skill': skill,
    'yearOfExprence': yearOfExprence,
    'experienceCertificates': experienceCertificates,
  };
} 