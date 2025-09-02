class MessageModel {
  final String text;
  final DateTime timestamp;
  final bool isSentByMe;

  MessageModel({
    required this.text,
    required this.timestamp,
    required this.isSentByMe,
  });
}

// User List API Response Models
class UserListResponse {
  final bool success;
  final String message;
  final UserListData data;

  UserListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UserListData.fromJson(json['data'] ?? {}),
    );
  }
}

class UserListData {
  final List<BookedCustomer> bookedCustomer;

  UserListData({
    required this.bookedCustomer,
  });

  factory UserListData.fromJson(Map<String, dynamic> json) {
    return UserListData(
      bookedCustomer: (json['bookedCustomer'] as List?)
          ?.map((customer) => BookedCustomer.fromJson(customer))
          .toList() ?? [],
    );
  }
}

class BookedCustomer {
  final String id;
  final User user;
  final String address;
  final double latitude;
  final double longitude;
  final String city;
  final String state;
  final String country;
  final int pincode;
  final int profilePendingScreens;
  final List<dynamic> bookingHistory;
  final List<dynamic> paymentHistory;
  final List<dynamic> complaints;
  final String profile;
  String unreadCount = "0"; // Add this property

  BookedCustomer({
    required this.id,
    required this.user,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.state,
    required this.country,
    required this.pincode,
    required this.profilePendingScreens,
    required this.bookingHistory,
    required this.paymentHistory,
    required this.complaints,
    required this.profile,
    this.unreadCount = "0",
  });

  factory BookedCustomer.fromJson(Map<String, dynamic> json) {
    return BookedCustomer(
      id: json['_id'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
      address: json['address'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      pincode: json['pincode'] ?? 0,
      profilePendingScreens: json['profilePendingScreens'] ?? 0,
      bookingHistory: json['bookingHistory'] ?? [],
      paymentHistory: json['paymentHistory'] ?? [],
      complaints: json['complaints'] ?? [],
      profile: json['profile'] ?? '',
      unreadCount: "0", // Default value
    );
  }
}

class User {
  final String id;
  final String role;
  final String? uid;
  final String joinVia;
  final String email;
  final String phone;
  final bool isActive;
  final String name;

  User({
    required this.id,
    required this.role,
    this.uid,
    required this.joinVia,
    required this.email,
    required this.phone,
    required this.isActive,
    required this.name,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      role: json['role'] ?? '',
      uid: json['uid'],
      joinVia: json['joinVia'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      isActive: json['isActive'] ?? false,
      name: json['name'] ?? '',
    );
  }
} 