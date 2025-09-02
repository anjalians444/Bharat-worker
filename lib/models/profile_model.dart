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
      jwtToken: json['jwtToken']?.toString(),
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
  final String? uid;
  final String? joinVia;

  UserModel({
    this.id,
    this.name,
    this.role,
    this.email,
    this.phone,
    this.isActive,
    this.v,
    this.uid,
    this.joinVia,
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
      uid: json['uid'],
      joinVia: json['joinVia'],
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
    'uid': uid,
    'joinVia': joinVia,
  };
}

class CategoryItem {
  final String? id;
  final String? name;

  CategoryItem({this.id, this.name});

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
  };
}

class ReferredByModel {
  final String? id;
  final String? name;

  ReferredByModel({this.id, this.name});

  factory ReferredByModel.fromJson(Map<String, dynamic> json) {
    return ReferredByModel(
      id: json['_id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
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
  final List<String>? subscriptionPlans;
  final List<dynamic>? referralHistory;
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
  final List<CategoryItem>? category;
  final List<CategoryItem>? services;
  final List<CategoryItem>? categoryType;
  final List<SkillModel>? skills;
  final int? v;
  final ReferredByModel? referredBy;
  final String? referralCode;
  final int? referralPoints;
  final int? totalExperience;
  final bool? waitingForApproval;
  final bool? isSubscriptionPlaneActive;
  final String? activeSubscriptionPlan;
  final String? subscriptionExpiresAt;

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
    this.subscriptionPlans,
    this.referralHistory,
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
    this.services,
    this.categoryType,
    this.skills,
    this.v,
    this.referredBy,
    this.referralCode,
    this.referralPoints,
    this.totalExperience,
    this.waitingForApproval,
    this.isSubscriptionPlaneActive,
    this.activeSubscriptionPlan,
    this.subscriptionExpiresAt,
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
      subscriptionPlans: (json['subscriptionPlans'] as List?)?.map((e) => e.toString()).toList() ?? [],
      referralHistory: json['referralHistory'] ?? [],
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
      category: (json['category'] as List?)?.map((e) => CategoryItem.fromJson(e)).toList() ?? [],
      services: (json['services'] as List?)?.map((e) => CategoryItem.fromJson(e)).toList() ?? [],
      categoryType: (json['categoryType'] as List?)?.map((e) => CategoryItem.fromJson(e)).toList() ?? [],
      skills: (json['skills'] as List?)?.map((e) => SkillModel.fromJson(e)).toList() ?? [],
      v: json['__v'],
      referredBy: json['referredBy'] != null ? ReferredByModel.fromJson(json['referredBy']) : null,
      referralCode: json['referralCode'],
      referralPoints: json['referralPoints'] is int ? json['referralPoints'] : int.tryParse(json['referralPoints'].toString()),
      totalExperience: json['totalExperience'],
      waitingForApproval: json['waitingForApproval'],
      isSubscriptionPlaneActive: json['isSubscriptionPlaneActive'],
      activeSubscriptionPlan: json['activeSubscriptionPlan'],
      subscriptionExpiresAt: json['subscriptionExpiresAt'],
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
    'subscriptionPlans': subscriptionPlans,
    'referralHistory': referralHistory,
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
    'category': category?.map((e) => e.toJson()).toList(),
    'services': services?.map((e) => e.toJson()).toList(),
    'categoryType': categoryType?.map((e) => e.toJson()).toList(),
    'skills': skills?.map((e) => e.toJson()).toList(),
    '__v': v,
    'referredBy': referredBy?.toJson(),
    'referralCode': referralCode,
    'referralPoints': referralPoints,
    'totalExperience': totalExperience,
    'waitingForApproval': waitingForApproval,
    'isSubscriptionPlaneActive': isSubscriptionPlaneActive,
    'activeSubscriptionPlan': activeSubscriptionPlan,
    'subscriptionExpiresAt': subscriptionExpiresAt,
  };
}

class SkillModel {
  final String? id;
  final String? serviceId;
  final String? skill;
  final int? yearOfExprence;
  final String? experienceCertificates;

  SkillModel({this.id, this.serviceId, this.skill, this.yearOfExprence, this.experienceCertificates});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['_id'],
      serviceId: json['serviceId'],
      skill: json['skill'],
      yearOfExprence: json['yearOfExprence'] is int ? json['yearOfExprence'] : int.tryParse(json['yearOfExprence'].toString()),
      experienceCertificates: json['experienceCertificates'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'serviceId': serviceId,
    'skill': skill,
    'yearOfExprence': yearOfExprence,
    'experienceCertificates': experienceCertificates,
  };
} 