class SubscriptionModel {
  final String id;
  final String name;
  final String status; // 'active', 'scheduled', 'expired'
  final DateTime startDate;
  final DateTime expiryDate;
  final int remainingDays;
  final List<String> benefits;
  final String iconPath; // For different plan icons

  SubscriptionModel({
    required this.id,
    required this.name,
    required this.status,
    required this.startDate,
    required this.expiryDate,
    required this.remainingDays,
    required this.benefits,
    required this.iconPath,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      expiryDate: DateTime.parse(json['expiryDate']),
      remainingDays: json['remainingDays'] ?? 0,
      benefits: List<String>.from(json['benefits'] ?? []),
      iconPath: json['iconPath'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'expiryDate': expiryDate.toIso8601String(),
      'remainingDays': remainingDays,
      'benefits': benefits,
      'iconPath': iconPath,
    };
  }
} 