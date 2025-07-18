
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
  List<String>? categoryType;
  List<ServicesTypes>? servicesTypes;

  Data({this.categoryType, this.servicesTypes});

  Data.fromJson(Map<String, dynamic> json) {
    categoryType = json['categoryType'].cast<String>();
    if (json['servicesTypes'] != null) {
      servicesTypes = <ServicesTypes>[];
      json['servicesTypes'].forEach((v) {
        servicesTypes!.add(new ServicesTypes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['categoryType'] = this.categoryType;
    if (this.servicesTypes != null) {
      data['servicesTypes'] =
          this.servicesTypes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ServicesTypes {
  String? sId;
  String? name;
  String? image;
  String? description;
  String? status;
  int? iV;
  String? createdAt;
  String? updatedAt;
  List<Commercial>? commercial;
  List<Commercial>? industrial;
  List<Commercial>? residential;

  ServicesTypes(
      {this.sId,
        this.name,
        this.image,
        this.description,
        this.status,
        this.iV,
        this.createdAt,
        this.updatedAt,
        this.commercial,
        this.industrial,
        this.residential});

  ServicesTypes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    image = json['image'];
    description = json['description'];
    status = json['status'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    if (json['commercial'] != null) {
      commercial = <Commercial>[];
      json['commercial'].forEach((v) {
        commercial!.add(new Commercial.fromJson(v));
      });
    }
    if (json['industrial'] != null) {
      industrial = <Commercial>[];
      json['industrial'].forEach((v) {
        industrial!.add(new Commercial.fromJson(v));
      });
    }
    if (json['residential'] != null) {
      residential = <Commercial>[];
      json['residential'].forEach((v) {
        residential!.add(new Commercial.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['image'] = this.image;
    data['description'] = this.description;
    data['status'] = this.status;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.commercial != null) {
      data['commercial'] = this.commercial!.map((v) => v.toJson()).toList();
    }
    if (this.industrial != null) {
      data['industrial'] = this.industrial!.map((v) => v.toJson()).toList();
    }
    if (this.residential != null) {
      data['residential'] = this.residential!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Commercial {
  String? sId;
  String? name;
  String? typeOfCategory;
  String? category;
  String? image;
  String? status;
  int? iV;
  String? createdAt;
  String? updatedAt;

  Commercial(
      {this.sId,
        this.name,
        this.typeOfCategory,
        this.category,
        this.image,
        this.status,
        this.iV,
        this.createdAt,
        this.updatedAt});

  Commercial.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    typeOfCategory = json['typeOfCategory'];
    category = json['category'];
    image = json['image'];
    status = json['status'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['typeOfCategory'] = this.typeOfCategory;
    data['category'] = this.category;
    data['image'] = this.image;
    data['status'] = this.status;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}