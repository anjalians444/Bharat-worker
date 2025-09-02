class SubscriptionDetailsResponse {
  final bool success;
  final SubscriptionDetailsData data;
  final String message;

  SubscriptionDetailsResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SubscriptionDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionDetailsResponse(
      success: json['success'] ?? false,
      data: SubscriptionDetailsData.fromJson(json['data'] ?? {}),
      message: json['message'] ?? '',
    );
  }
}

class SubscriptionDetailsData {
  final ActivePlan? activePlane;
  final List<UpcomingPlan> upcomingPlans;

  SubscriptionDetailsData({
    this.activePlane,
    required this.upcomingPlans,
  });

  factory SubscriptionDetailsData.fromJson(Map<String, dynamic> json) {
    List<UpcomingPlan> upcomingPlansList = [];
    if (json['upcomingPlans'] != null) {
      final List<dynamic> upcomingPlansData = json['upcomingPlans'] as List<dynamic>;
      upcomingPlansList = upcomingPlansData
          .map((plan) => UpcomingPlan.fromJson(plan as Map<String, dynamic>))
          .toList();
    }
    
    return SubscriptionDetailsData(
      activePlane: json['activePlane'] != null 
          ? ActivePlan.fromJson(json['activePlane']) 
          : null,
      upcomingPlans: upcomingPlansList,
    );
  }
}

class ActivePlan {
  final String id;
  final SubscriptionPlans subscriptionPlans;
  final int price;
  final int discountAmount;
  final String discountType;
  final int payableAmount;
  final String startDate;
  final String endDate;
  final String status;
  final int remainingDays;

  ActivePlan({
    required this.id,
    required this.subscriptionPlans,
    required this.price,
    required this.discountAmount,
    required this.discountType,
    required this.payableAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.remainingDays,
  });

  factory ActivePlan.fromJson(Map<String, dynamic> json) {
    return ActivePlan(
      id: json['_id'] ?? '',
      subscriptionPlans: SubscriptionPlans.fromJson(json['subscriptionPlans'] ?? {}),
      price: json['price'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      discountType: json['discountType'] ?? '',
      payableAmount: json['payableAmount'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? '',
      remainingDays: json['remainingDays'] ?? 0,
    );
  }
}

class UpcomingPlan {
  final String id;
  final SubscriptionPlans subscriptionPlans;
  final int price;
  final int discountAmount;
  final String discountType;
  final int payableAmount;
  final String startDate;
  final String endDate;
  final String status;

  UpcomingPlan({
    required this.id,
    required this.subscriptionPlans,
    required this.price,
    required this.discountAmount,
    required this.discountType,
    required this.payableAmount,
    required this.startDate,
    required this.endDate,
    required this.status,
  });

  factory UpcomingPlan.fromJson(Map<String, dynamic> json) {
    return UpcomingPlan(
      id: json['_id'] ?? '',
      subscriptionPlans: SubscriptionPlans.fromJson(json['subscriptionPlans'] ?? {}),
      price: json['price'] ?? 0,
      discountAmount: json['discountAmount'] ?? 0,
      discountType: json['discountType'] ?? '',
      payableAmount: json['payableAmount'] ?? 0,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class SubscriptionPlans {
  final String id;
  final String name;
  final List<String> features;
  final String priceType;
  final String currency;
  final String description;

  SubscriptionPlans({
    required this.id,
    required this.name,
    required this.features,
    required this.priceType,
    required this.currency,
    required this.description,
  });

  factory SubscriptionPlans.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlans(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      priceType: json['price_type'] ?? '',
      currency: json['currency'] ?? '',
      description: json['discription'] ?? '',
    );
  }
} 