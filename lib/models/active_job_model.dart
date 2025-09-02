class ActiveJobResponse {
  final bool success;
  final String message;
  final ActiveJobData data;

  ActiveJobResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ActiveJobResponse.fromJson(Map<String, dynamic> json) {
    return ActiveJobResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ActiveJobData.fromJson(json['data'] ?? {}),
    );
  }
}

class ActiveJobData {
  final List<JobModel> activeJobs;

  ActiveJobData({
    required this.activeJobs,
  });

  factory ActiveJobData.fromJson(Map<String, dynamic> json) {
    return ActiveJobData(
      activeJobs: (json['activeJobs'] as List?)
              ?.map((job) => JobModel.fromJson(job))
              .toList() ??
          [],
    );
  }
}

class JobModel {
  final int? applicants;
  final int? jobDistance;
  final String? id;
  final ServiceInfo? serviceId;
  final int? price;
  final CustomerInfo? customerId;
  final String? title;
  final String? description;
  final String? jobDate;
  final String? jobTime;
  final String? estimatedTime;
  final String? fullAddress;
  final String? latitude;
  final String? longitude;
  final String? contactName;
  final String? contactNumber;
  final String? contactEmail;
  final String? status;
  final List<String>? image;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  JobModel({
    this.applicants,
    this.jobDistance,
    this.id,
    this.serviceId,
    this.price,
    this.customerId,
    this.title,
    this.description,
    this.jobDate,
    this.jobTime,
    this.estimatedTime,
    this.fullAddress,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactNumber,
    this.contactEmail,
    this.status,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      applicants: json['applicants'] ?? 0,
      jobDistance: json['job_distance'] ?? 0,
      id: json['_id'] ?? '',
      serviceId: ServiceInfo.fromJson(json['serviceId'] ?? {}),
      price: json['price'] ?? 0,
      customerId: CustomerInfo.fromJson(json['customerId'] ?? {}),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      jobDate: json['job_date'] ?? '',
      jobTime: json['job_time'] ?? '',
      estimatedTime: json['estimated_time'] ?? '',
      fullAddress: json['full_address'] ?? '',
      latitude: json['latitude'] ?? '',
      longitude: json['longitude'] ?? '',
      contactName: json['contact_name'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      contactEmail: json['contact_email'] ?? '',
      status: json['status'] ?? '',
      image: (json['image'] as List?)?.cast<String>() ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

class ServiceInfo {
  final String id;
  final String name;
  final String description;
  final String? image;
  final CategoryType? categorytype;

  ServiceInfo({
    required this.id,
    required this.name,
    required this.description,
    this.image,
    this.categorytype,
  });

  factory ServiceInfo.fromJson(Map<String, dynamic> json) {
    return ServiceInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      categorytype: json['categorytype'] != null ? CategoryType.fromJson(json['categorytype']) : null,
    );
  }
}

class CategoryType {
  final String id;
  final String name;

  CategoryType({
    required this.id,
    required this.name,
  });

  factory CategoryType.fromJson(Map<String, dynamic> json) {
    return CategoryType(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class CustomerInfo {
  final String id;
  final String phone;
  final String email;
  final String name;

  CustomerInfo({
    required this.id,
    required this.phone,
    required this.email,
    required this.name,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      id: json['_id'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }
}
