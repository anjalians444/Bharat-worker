class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String description;
  final String status;
  final int v;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.description,
    required this.status,
    required this.v,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'],
      name: json['name'],
      image: json['image'],
      description: json['description'],
      status: json['status'],
      v: json['__v'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
} 