class ReferralHistoryResponse {
  final bool? success;
  final String? message;
  final ReferralHistoryData? data;

  ReferralHistoryResponse({
    this.success,
    this.message,
    this.data,
  });

  factory ReferralHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ReferralHistoryData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data?.toJson(),
  };
}

class ReferralHistoryData {
  final List<ReferralHistoryItem>? referralHistory;

  ReferralHistoryData({
    this.referralHistory,
  });

  factory ReferralHistoryData.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryData(
      referralHistory: json['referralHistory'] != null
          ? List<ReferralHistoryItem>.from(
              json['referralHistory'].map((x) => ReferralHistoryItem.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'referralHistory': referralHistory?.map((x) => x.toJson()).toList(),
  };
}

class ReferralHistoryItem {
  final String? name;
  final int? referralFromPoint;

  ReferralHistoryItem({
    this.name,
    this.referralFromPoint,
  });

  factory ReferralHistoryItem.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryItem(
      name: json['name'],
      referralFromPoint: json['referralFromPoint'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'referralFromPoint': referralFromPoint,
  };
} 