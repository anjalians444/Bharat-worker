import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/assets_paths.dart';

class CategoryProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController searchController = TextEditingController();
  final TextEditingController otherController = TextEditingController();

  // Categories
  final List<Map<String, dynamic>> _categories = [
    {"icon": MyAssetsPaths.ac, "key": "ac_repair"},
    {"icon": MyAssetsPaths.beauty, "key": "beauty"},
    {"icon": MyAssetsPaths.ac, "key": "appliance"},
    {"icon": MyAssetsPaths.ac, "key": "painter"},
    {"icon": MyAssetsPaths.ac, "key": "cleaning"},
    {"icon": MyAssetsPaths.ac, "key": "plumber"},
    {"icon": MyAssetsPaths.ac, "key": "electrician"},
    {"icon": MyAssetsPaths.ac, "key": "shifting"},
    {"icon": MyAssetsPaths.ac, "key": "mens_salon"},
  ];

  List<Map<String, dynamic>> get categories => _categories;

  // Selected categories (if needed)
  final List<int> _selectedIndexes = [];
  List<int> get selectedIndexes => _selectedIndexes;

  void toggleCategory(int index) {
    if (_selectedIndexes.contains(index)) {
      _selectedIndexes.remove(index);
    } else {
      _selectedIndexes.add(index);
    }
    notifyListeners();
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
    _selectedIndexes.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    searchController.dispose();
    otherController.dispose();
    super.dispose();
  }
} 