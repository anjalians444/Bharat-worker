class SubscriptionPlanModel {
  final String id;
  final String name;
  final List<String> features;
  final int mrp;
  final int price;
  final int flatDiscount;
  final double percentageDiscount;
  final String priceType;
  final String currency;
  final int duration;
  final String? description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.features,
    required this.mrp,
    required this.price,
    required this.flatDiscount,
    required this.percentageDiscount,
    required this.priceType,
    required this.currency,
    required this.duration,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      features: List<String>.from(json['features'] ?? []),
      mrp: json['mrp'] ?? 0,
      price: json['price'] ?? 0,
      flatDiscount: json['flat_discount'] ?? 0,
      percentageDiscount: (json['percentage_discount'] ?? 0).toDouble(),
      priceType: json['price_type'] ?? '',
      currency: json['currency'] ?? '',
      duration: json['duration'] ?? 0,
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      description: json['discription'],
    );
  }
} 