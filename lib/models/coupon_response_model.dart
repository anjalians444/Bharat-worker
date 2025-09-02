class CouponResponseModel {
  final bool success;
  final CouponData? data;
  final String message;

  CouponResponseModel({
    required this.success,
    this.data,
    required this.message,
  });

  factory CouponResponseModel.fromJson(Map<String, dynamic> json) {
    return CouponResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? CouponData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}

class CouponData {
  final String? planPrice;
  final String? discount;
  final String? totalPayable;
  final String? discountType;
  final String? discountAmount;
  final String? referalPoints;
  final String? codeType;

  CouponData({
    this.planPrice,
    this.discount,
    this.totalPayable,
    this.discountType,
    this.discountAmount,
    this.referalPoints,
    this.codeType,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      planPrice: json['planPrice'],
      discount: json['discount'],
      totalPayable:json['totalPayable'],
      discountType: json['discountType']?.toString(),
      discountAmount: json['discountAmount'],
      referalPoints:json['referalPoints'].toString(),
      codeType: json['codeType']?.toString(),
    );
  }

  // Helper method to parse string/int/double to double
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  // Helper method to parse string/int to int
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }
} 