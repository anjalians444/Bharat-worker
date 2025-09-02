
class SubCategoryModel {
  bool? success;
  Data? data;
  String? message;

  SubCategoryModel({this.success, this.data, this.message});

  SubCategoryModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  List<Services>? services;

  Data({this.services});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['services'] != null) {
      services = <Services>[];
      json['services'].forEach((v) {
        services!.add(new Services.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Services {
  List<CategoryTypes>? categorytypes;
  String? categoryId;
  String? categoryName;
  String? image;

  Services({this.categorytypes, this.categoryId, this.categoryName, this.image});

  Services.fromJson(Map<String, dynamic> json) {
    if (json['categorytypes'] != null) {
      categorytypes = <CategoryTypes>[];
      json['categorytypes'].forEach((v) {
        categorytypes!.add(new CategoryTypes.fromJson(v));
      });
    }
    categoryId = json['categoryId'];
    categoryName = json['categoryName'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categorytypes != null) {
      data['categorytypes'] = this.categorytypes!.map((v) => v.toJson()).toList();
    }
    data['categoryId'] = this.categoryId;
    data['categoryName'] = this.categoryName;
    data['image'] = this.image;
    return data;
  }
}

class CategoryTypes {
  String? categoryTypeId;
  String? categoryTypeName;
  List<ServiceItem>? services;

  CategoryTypes({this.categoryTypeId, this.categoryTypeName, this.services});

  CategoryTypes.fromJson(Map<String, dynamic> json) {
    categoryTypeId = json['categoryTypeId'];
    categoryTypeName = json['categoryTypeName'];
    if (json['services'] != null) {
      services = <ServiceItem>[];
      json['services'].forEach((v) {
        services!.add(new ServiceItem.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryTypeId'] = this.categoryTypeId;
    data['categoryTypeName'] = this.categoryTypeName;
    if (this.services != null) {
      data['services'] = this.services!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServiceItem {
  String? sId;
  String? name;
  String? description;
  bool? isCertificate;

  ServiceItem({this.sId, this.name, this.description, this.isCertificate});

  ServiceItem.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    description = json['description'];
    isCertificate = json['isCertificate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['description'] = this.description;
    data['isCertificate'] = this.isCertificate;
    return data;
  }
}