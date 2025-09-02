class BookingJobResponse {
  final bool success;
  final String message;
  final BookingJobData data;

  BookingJobResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookingJobResponse.fromJson(Map<String, dynamic> json) {
    return BookingJobResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: BookingJobData.fromJson(json['data'] ?? {}),
    );
  }
}

class JobDetailResponse {
  final bool success;
  final String message;
  final JobDetailData data;

  JobDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory JobDetailResponse.fromJson(Map<String, dynamic> json) {
    return JobDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: JobDetailData.fromJson(json['data'] ?? {}),
    );
  }
}

class JobDetailData {
  final BookingJob job;
  final Bid? bid;

  JobDetailData({
    required this.job,
    this.bid,
  });

  factory JobDetailData.fromJson(Map<String, dynamic> json) {
    return JobDetailData(
      job: BookingJob.fromJson(json['job'] ?? {}),
      bid: json['bid'] != null ? Bid.fromJson(json['bid']) : null,
    );
  }
}

class BookingJobData {
  final List<BookingJob> activeJobs;

  BookingJobData({
    required this.activeJobs,
  });

  factory BookingJobData.fromJson(Map<String, dynamic> json) {
    return BookingJobData(
      activeJobs: (json['activeJobs'] as List?)
              ?.map((job) => BookingJob.fromJson(job))
              .toList() ??
          [],
    );
  }
}

class Bid {
  final String? id;
  final String? availableTime;
  final String? message;
  final int? price;
  final String? status;

  Bid({
    this.id,
    this.availableTime,
    this.message,
    this.price,
    this.status,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    try {
      return Bid(
        id: json['_id']?.toString() ?? '',
        availableTime: json['availableTime']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        price: json['price'] is int ? json['price'] : (json['price'] is String ? int.tryParse(json['price']) ?? 0 : 0),
        status: json['status']?.toString() ?? '',
      );
    } catch (e) {
      print("Bid.fromJson error: $e");
      print("JSON data: $json");
      rethrow;
    }
  }
}

class BookingJob {
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

  BookingJob({
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

  factory BookingJob.fromJson(Map<String, dynamic> json) {
    try {
      return BookingJob(
        applicants: json['applicants'] is int ? json['applicants'] : (json['applicants'] is String ? int.tryParse(json['applicants']) ?? 0 : 0),
        jobDistance: json['job_distance'] is int ? json['job_distance'] : (json['job_distance'] is String ? int.tryParse(json['job_distance']) ?? 0 : 0),
        id: json['_id']?.toString() ?? '',
        serviceId: json['serviceId'] is Map<String, dynamic> ? ServiceInfo.fromJson(json['serviceId']) : ServiceInfo(id: '', name: '', description: ''),
        price: json['price'] is int ? json['price'] : (json['price'] is String ? int.tryParse(json['price']) ?? 0 : 0),
        customerId: json['customerId'] is Map<String, dynamic> ? CustomerInfo.fromJson(json['customerId']) : CustomerInfo(id: '', phone: '', email: '', name: ''),
        title: json['title']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        jobDate: json['job_date']?.toString() ?? '',
        jobTime: json['job_time']?.toString() ?? '',
        estimatedTime: json['estimated_time']?.toString() ?? '',
        fullAddress: json['full_address']?.toString() ?? '',
        latitude: json['latitude']?.toString() ?? '',
        longitude: json['longitude']?.toString() ?? '',
        contactName: json['contact_name']?.toString() ?? '',
        contactNumber: json['contact_number']?.toString() ?? '',
        contactEmail: json['contact_email']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        image: json['image'] is List ? (json['image'] as List).map((e) => e.toString()).toList() : [],
        createdAt: json['createdAt']?.toString() ?? '',
        updatedAt: json['updatedAt']?.toString() ?? '',
        v: json['__v'] is int ? json['__v'] : (json['__v'] is String ? int.tryParse(json['__v']) ?? 0 : 0),
      );
    } catch (e) {
      print("BookingJob.fromJson error: $e");
      print("JSON data: $json");
      rethrow;
    }
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
    try {
      return ServiceInfo(
        id: json['_id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        image: json['image']?.toString(),
        categorytype: json['categorytype'] is Map<String, dynamic> ? CategoryType.fromJson(json['categorytype']) : null,
      );
    } catch (e) {
      print("ServiceInfo.fromJson error: $e");
      print("JSON data: $json");
      rethrow;
    }
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
    try {
      return CustomerInfo(
        id: json['_id']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        email: json['email']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
      );
    } catch (e) {
      print("CustomerInfo.fromJson error: $e");
      print("JSON data: $json");
      rethrow;
    }
  }
}
