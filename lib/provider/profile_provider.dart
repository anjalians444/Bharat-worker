import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? profileImage;
  File? _frontImage;
  File? _backImage;
  File? _licenseImage;

  String? nameError;
  String? dobError;
  String? mobileError;
  String? emailError;
  String? imageError;

  File? get frontImage => _frontImage;
  File? get backImage => _backImage;
  File? get licenseImage => _licenseImage;

  double get profileCompletionPercent => _profileCompletionPercent;
  double _profileCompletionPercent = 0.7;
  set profileCompletionPercent(double value) {
    _profileCompletionPercent = value;
    notifyListeners();
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      profileImage = File(pickedFile.path);
      imageError = null;
      notifyListeners();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      dobError = null;
      notifyListeners();
    }
  }

  bool validate() {
    nameError = nameController.text.isEmpty ? 'Name is required' : null;
    dobError = dobController.text.isEmpty ? 'Date of birth is required' : null;
    mobileError = mobileController.text.isEmpty ? 'Mobile number is required' : null;
    emailError = emailController.text.isEmpty ? 'Email is required' : null;
    imageError = profileImage == null ? 'Profile image is required' : null;
    notifyListeners();
    return nameError == null && dobError == null && mobileError == null && emailError == null && imageError == null;
  }

  void clearErrors() {
    nameError = null;
    dobError = null;
    mobileError = null;
    emailError = null;
    imageError = null;
    notifyListeners();
  }

  // Profile details for profile details page
  String get profileName => 'Akshay Swami';
  String get profilePhone => '+91 987 654 3210';
  String get profileImageUrl => 'https://randomuser.me/api/portraits/women/2.jpg';
  String get profileCompletionText => 'Only 30% Left to Go!';
  String get profileCompletionSubtext => 'Unlock jobs, earn faster, and get certified today.';
  List<String> get serviceCategories => ['AC Repair', 'Plumbing'];
  String get availabilityDays => 'Monday to Saturday';
  String get availabilityTime => '9:00 AM – 7:00 PM';
  String get location => 'House No. 122, Sector 22B, Chandigarh, Punjab – 160022';
  String get serviceRange => 'Chandigarh (up to 40 km)';
  bool get isProfileComplete => profileCompletionPercent >= 1.0;

  void setFrontImage(File? file) {
    _frontImage = file;
    notifyListeners();
  }

  void setBackImage(File? file) {
    _backImage = file;
    notifyListeners();
  }

  void setLicenseImage(File? file) {
    _licenseImage = file;
    notifyListeners();
  }

  void removeFrontImage() {
    _frontImage = null;
    notifyListeners();
  }

  void removeBackImage() {
    _backImage = null;
    notifyListeners();
  }

  void removeLicenseImage() {
    _licenseImage = null;
    notifyListeners();
  }
} 