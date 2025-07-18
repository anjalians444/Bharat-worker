import 'dart:io';
import 'package:bharat_worker/helper/utility.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

import 'package:bharat_worker/services/api_paths.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/models/category_model.dart';
import 'package:bharat_worker/models/sub_category_model.dart';
import 'package:bharat_worker/services/api_service.dart';

// Add model for YearExperience
class YearExperience {
  final int value;
  final String name;
  YearExperience({required this.value, required this.name});
  factory YearExperience.fromJson(Map<String, dynamic> json) {
    return YearExperience(
      value: json['value'],
      name: json['name'],
    );
  }
}

class CategoryProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController otherController = TextEditingController();

  // Dynamic Categories
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  // Dynamic Subcategories
  List<SubCategoryModel> _subCategories = [];
  List<SubCategoryModel> get subCategories => _subCategories;

  // Loading/Error State
  bool isLoading = false;
  String? errorMessage;

  // Add year experience list and loading state
  List<YearExperience> _yearExperiences = [];
  List<YearExperience> get yearExperiences => _yearExperiences;
  bool isYearExperienceLoading = false;
  String? yearExperienceError;

  // Selected category IDs
  List<String> selectedCategoryIds = [];
  // Selected subcategory IDs
  List<String> selectedSubCategoryIds = [];
  List<String> _categoryTypes = [];
  final List<ServicesTypes> _serviceTypesList = [];
  SubCategoryModel _subCategoryModel = SubCategoryModel();
  List<ServicesTypes> get serviceTypesList => _serviceTypesList;
  List<String> get categoryTypes => _categoryTypes;
  SubCategoryModel get subCategoryModel => _subCategoryModel;
  CategoryProvider(){
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService().get(ApiPaths.getServices);
      final List data = response['data']['services'] ?? [];
      _categories = data.map((e) => CategoryModel.fromJson(e)).toList();
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSubCategories(BuildContext context,List<String> categoryIds) async {
    isLoading = true;
    errorMessage = null;
    // Clear old data to prevent duplicates
    _categoryTypes.clear();
    _subCategories.clear();
    notifyListeners();
    Future.delayed(Duration.zero, progressLoadingDialog(context,true));
    try {

      final response = await ApiService().post(ApiPaths.getServicesByCategory, body: {
        'categoryIds': categoryIds,
      });
     Future.delayed(Duration.zero, progressLoadingDialog(context,false));
      final data = response['data'];
      _subCategoryModel = SubCategoryModel.fromJson(response);
      var categoryTypes = data['categoryType'];
      if(categoryTypes != null){
        _categoryTypes.addAll(List<String>.from(categoryTypes));
        notifyListeners();
      }
   
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }

  void toggleCategorySelection(String id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
    notifyListeners();
  }
  Future<void> fetchSubCategories1(List<String> categoryIds) async {
    isLoading = true;
    errorMessage = null;
    // Clear old data to prevent duplicates
    _categoryTypes.clear();
    _subCategories.clear();
    notifyListeners();
    try {
      final response = await ApiService().post(ApiPaths.getServicesByCategory,body:  {
        'categoryIds': categoryIds,
      });
      print('API response keys: ${response.keys}');
      final data = response['data'];
      final List servicesTypes = data['servicesTypes'] ?? [];
      final List categoryTypes = data['categoryType'] ?? [];
      print('categoryTypes: ${categoryTypes}');
      print('servicesTypes: ${servicesTypes}');
      _categoryTypes = List<String>.from(categoryTypes);
      List<SubCategoryModel> temp = [];
      for (var cat in servicesTypes) {
        for (var type in _categoryTypes) {
          if (cat[type] != null) {
            for (var sub in cat[type]) {
              temp.add(SubCategoryModel.fromJson(sub));
            }
          }
        }
      }
      _subCategories = temp;
      print('_categoryTypes (final): ${_categoryTypes}');
      print('_subCategories (final): ${_subCategories}');
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  void toggleCategorySelection1(String id) {
    if (selectedCategoryIds.contains(id)) {
      selectedCategoryIds.remove(id);
    } else {
      selectedCategoryIds.add(id);
    }
    notifyListeners();
  }

  void toggleSubCategorySelection(String id) {
    if (selectedSubCategoryIds.contains(id)) {
      selectedSubCategoryIds.remove(id);
    } else {
      selectedSubCategoryIds.add(id);
    }
    notifyListeners();
  }

  void clearSelections() {
    selectedCategoryIds.clear();
    selectedSubCategoryIds.clear();
    notifyListeners();
  }

  List<CategoryModel> get filteredCategories {
    if (searchController.text.isEmpty) return _categories;
    final query = searchController.text.toLowerCase();
    return _categories.where((cat) => cat.name.toLowerCase().contains(query)).toList();
  }

  void setSearch(String value) {
    searchController.text = value;
    notifyListeners();
  }

  void setOther(String value) {
    otherController.text = value;
    print("value..$value");
    notifyListeners();
  }

  void clear() {
    searchController.clear();
    otherController.clear();
    selectedCategoryIds.clear();
    notifyListeners();
  }

  // Fetch year experience from API
  Future<void> fetchYearExperience() async {
    isYearExperienceLoading = true;
    yearExperienceError = null;
    notifyListeners();
    try {
      final response = await ApiService().get(ApiPaths.getYearExperience);
      if (response['success'] == true && response['data'] != null) {
        _yearExperiences = (response['data'] as List)
            .map((e) => YearExperience.fromJson(e))
            .toList();
      } else {
        yearExperienceError = response['message'] ?? 'Unknown error';
      }
    } catch (e) {
      yearExperienceError = e.toString();
    }
    isYearExperienceLoading = false;
    notifyListeners();
  }

  // Submit partner skills (multipart)
  Future<dynamic> submitPartnerSkills({
    required BuildContext context,
    required List<String> skills,
    required List<int> yearOfExprence,
    required Map<String, File?> certificateImages,
  }) async {

    final Map<String, String> fields = {};
    for (int i = 0; i < skills.length; i++) {
      fields['skills[$i]'] = skills[i];
      fields['yearOfExprence[$i]'] = yearOfExprence[i].toString();
    }
    List<http.MultipartFile> files = [];
    for (int i = 0; i < skills.length; i++) {
      final subId = skills[i];
      final certFile = certificateImages[subId];
      print("certFile...$certFile");
      if (certFile != null) {
        final mimeType = lookupMimeType(certFile.path);
        print('mimeType...$mimeType');
        if (mimeType == null) continue;
        final allowed = [
          'image/jpeg', 'image/jpg', 'image/png', 'image/webp', 'image/avif', 'application/pdf'
        ];
        if (!allowed.contains(mimeType)) {
          print('File type not allowed: $mimeType');
          continue;
        }
        final typeParts = mimeType.split('/');
        final file = await http.MultipartFile.fromPath(
          'experienceCertificates',
          certFile.path,
          contentType: MediaType(typeParts[0], typeParts[1]),
        );
        print("file...${file.filename}");
        files.add(file);
      }
    }


    final response = await ApiService().postMultipart(
      ApiPaths.partnerSkills,
      fields: fields,
      files: files,
    );


    print("response...$response");
    return response;
  }

  @override
  void dispose() {
    searchController.dispose();
    otherController.dispose();
    super.dispose();
  }
} 