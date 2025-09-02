import 'dart:io';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/services/user_prefences.dart';
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
  SubCategoryModel _subCategoryModel = SubCategoryModel();
  SubCategoryModel get subCategoryModel => _subCategoryModel;
  CategoryProvider(){
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService().get(ApiPaths.getServices,);
      final List data = response['data']['services'] ?? [];
      _categories = data.map((e) => CategoryModel.fromJson(e)).toList();
      setCategorySubcategory();
    } catch (e) {
      errorMessage = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchSubCategories(BuildContext context,List<String> categoryIds,bool isEdit) async {
    isLoading = true;
    errorMessage = null;
    _subCategories.clear();
    notifyListeners();
    Future.delayed(Duration.zero, progressLoadingDialog(context,true));
    try {
      final response = await ApiService().post(ApiPaths.getServicesByCategory, body: {
        'categoryIds': categoryIds,
      });
      Future.delayed(Duration.zero, progressLoadingDialog(context,false));
      _subCategoryModel = SubCategoryModel.fromJson(response);
      notifyListeners();
      if (isEdit) {
        print("widget.isEdit...${isEdit}");
        // final profile = await PreferencesServices.getProfileData();
        // final partner = profile?.data?.partner;
        // print("subCategory...${profile?.data!.partner!.services}");
        // if (partner!.services!.isNotEmpty) {
          setCategorySubcategory();
        // }
      }
      setCategorySubcategory();
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



  void toggleSubCategorySelection(String id) {
    if (selectedSubCategoryIds.contains(id)) {
      selectedSubCategoryIds.remove(id);
    } else {
      selectedSubCategoryIds.add(id);
    }
    notifyListeners();
  }

  setCategorySubcategory()async{
 var   profileResponse = await PreferencesServices.getProfileData();
    if(profileResponse != null){
      if(profileResponse.data!.partner != null){
        var model = profileResponse.data!.partner;
        for(var c in model!.category!){
          print("c.id...${c.id}");
          if (!selectedCategoryIds.contains(c.id)) {
            selectedCategoryIds.add(c.id.toString());
          }
        }
        for(var s in model.services!){
          print("s.id...${s.id}");
          if (!selectedSubCategoryIds.contains(s.id)) {
            selectedSubCategoryIds.add(s.id.toString());
          }
        }
      }
    }

    notifyListeners();
  }

  void clearSelections() {
    selectedCategoryIds.clear();
    selectedSubCategoryIds.clear();
    _yearExperiences.clear();
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
    selectedCategoryIds.clear();
    selectedSubCategoryIds.clear();
    searchController.clear();
    otherController.clear();
    selectedCategoryIds.clear();
    _yearExperiences.clear();
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
    
    // Add skills array
    for (int i = 0; i < skills.length; i++) {
      fields['skills[$i]'] = skills[i];
    }
    
    // Add yearOfExprence mapping to skill IDs
    for (int i = 0; i < skills.length; i++) {
      final subId = skills[i];
      fields['yearOfExprence[$subId]'] = yearOfExprence[i].toString();
    }
    
    List<http.MultipartFile> files = [];
    
    // Add experienceCertificates mapping to skill IDs
    for (int i = 0; i < skills.length; i++) {
      final subId = skills[i];
      final certFile = certificateImages[subId];
      print("certFile...$certFile");
      print("subId...$subId");
      if (certFile != null) {
        print("subId...$subId");
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
          'experienceCertificates[$subId]',
          certFile.path,
          contentType: MediaType(typeParts[0], typeParts[1]),
        );
        print("file...${file.filename}");
        files.add(file);
      }
    }
    print("fields...${fields}");
    print("files...${files.length}");

    var response = await ApiService().postMultipart(
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