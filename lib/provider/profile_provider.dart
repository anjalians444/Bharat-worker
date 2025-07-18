import 'dart:io';
import 'package:bharat_worker/constants/all_key.dart';
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bharat_worker/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'package:bharat_worker/services/api_paths.dart';
import 'package:bharat_worker/models/profile_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';

// CertificateFileModel to manage both local files and URLs for certificates
class CertificateFileModel {
  final String? url;      // Uploaded file ka URL
  final File? file;       // Local file
  final bool isPdf;       // PDF hai ya nahi
  final bool isLocal;     // Local file hai ya uploaded URL

  CertificateFileModel({
    this.url,
    this.file,
    required this.isPdf,
    required this.isLocal,
  });
}

class ProfileProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  File? profileImage;
  File? _frontImage;
  File? _backImage;
  File? _licenseImage;
  String? _frontImageUrl;
  String? _backImageUrl;
  String? _licenseImageUrl;

  String? nameError;
  String? dobError;
  String? mobileError;
  String? emailError;
  String? imageError;
  String? aadharNumber;

  File? get frontImage => _frontImage;
  File? get backImage => _backImage;
  String? get frontImageUrl => _frontImageUrl;
  String? get backImageUrl => _backImageUrl;
  String? get licenseImageUrl => _licenseImageUrl;
  File? get licenseImage => _licenseImage;
  ProfileResponse? _profileResponse;
  PartnerModel? _partner;
  UserModel? _user;
  ProfileResponse? get profileResponse => _profileResponse;
  PartnerModel? get partner => _partner;
  UserModel? get user => _user;
  double get profileCompletionPercent => _profileCompletionPercent;
 // String? get aadharNumber => _aadharNumber;
  double _profileCompletionPercent = 0.7;
  set profileCompletionPercent(double value) {
    _profileCompletionPercent = value;
    notifyListeners();
  }

  // Experience certificate files
  List<File> _experienceCertificates = [];
  List<File> get experienceCertificates => _experienceCertificates;

  // New: Unified certificate files list
  List<CertificateFileModel> _certificateFiles = [];
  List<CertificateFileModel> get certificateFiles => _certificateFiles;

  // Helper to refresh the unified list from licenseFiles and licenseFilesUrl
  void refreshCertificateFiles() {
    _certificateFiles = [
      ...licenseFilesUrl.map((url) => CertificateFileModel(
        url: url,
        file: null,
        isPdf: url.toLowerCase().endsWith('.pdf'),
        isLocal: false,
      )),
      ...licenseFiles.map((file) => CertificateFileModel(
        url: null,
        file: file,
        isPdf: file.path.toLowerCase().endsWith('.pdf'),
        isLocal: true,
      )),
    ];
    notifyListeners();
  }

  // Add a local file
  void addCertificateFile(File file) {
    if (!_certificateFiles.any((c) => c.file?.path == file.path)) {
      _certificateFiles.add(CertificateFileModel(
        url: null,
        file: file,
        isPdf: file.path.toLowerCase().endsWith('.pdf'),
        isLocal: true,
      ));
      licenseFiles.add(file); // keep old logic in sync
      notifyListeners();
    }
  }

  // Add a URL
  void addCertificateUrl(String url) {
    if (!_certificateFiles.any((c) => c.url == url)) {
      _certificateFiles.add(CertificateFileModel(
        url: url,
        file: null,
        isPdf: url.toLowerCase().endsWith('.pdf'),
        isLocal: false,
      ));
      licenseFilesUrl.add(url); // keep old logic in sync
      notifyListeners();
    }
  }

  // Remove by file
  void removeCertificateFile(File file) {
    _certificateFiles.removeWhere((c) => c.file?.path == file.path);
    licenseFiles.removeWhere((f) => f.path == file.path);
    notifyListeners();
  }

  // Remove by url
  void removeCertificateUrl(String url) {
    _certificateFiles.removeWhere((c) => c.url == url);
    licenseFilesUrl.removeWhere((f) => f == url);
    notifyListeners();
  }

  // Remove by model
  void removeCertificate(CertificateFileModel cert) {
    if (cert.isLocal && cert.file != null) {
      removeCertificateFile(cert.file!);
    } else if (!cert.isLocal && cert.url != null) {
      removeCertificateUrl(cert.url!);
    }
  }

  // Clear all
  void clearCertificateFiles() {
    _certificateFiles.clear();
    licenseFiles.clear();
    licenseFilesUrl.clear();
    notifyListeners();
  }

  // Get only local files for upload
  List<File> get filesToUpload => _certificateFiles.where((c) => c.isLocal && c.file != null).map((c) => c.file!).toList();

  // Selected ID type and controller for ID number
  String? _selectedIdType;
  String? get selectedIdType => _selectedIdType;
  set selectedIdType(String? value) {
    _selectedIdType = value;
    notifyListeners();
  }

  final TextEditingController idController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  void addExperienceCertificate(File file) {
    _experienceCertificates.add(file);
    notifyListeners();
  }

  void removeExperienceCertificate(File file) {
    _experienceCertificates.remove(file);
    notifyListeners();
  }

  void clearExperienceCertificates() {
    _experienceCertificates.clear();
    notifyListeners();
  }

  List<File> licenseFiles = [];
  List<String> licenseFilesUrl = [];

  void addLicenseFile(File file) {
    if (!licenseFiles.any((f) => f.path == file.path)) {
      licenseFiles.add(file);
      certificateFiles.add(CertificateFileModel(isPdf: file.path.toLowerCase().endsWith('.pdf'), isLocal: true,file: file,url: ""));
      notifyListeners();
    }
  }

  void removeLicenseFile(File file) {
    licenseFiles.removeWhere((f) => f.path == file.path);
    notifyListeners();
  }

  void removeLicenseUrl(String file) {
    licenseFilesUrl.removeWhere((f) => f == file);
    notifyListeners();
  }

  ProfileProvider(){
    getProfileData();
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
      dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
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
  setData(PartnerModel? partnerModel){
    licenseFilesUrl.clear();
    licenseFiles.clear();
    certificateFiles.clear();
    final partner = partnerModel;
    if (partner != null){
      idController.text = partnerModel!.panFront == null? partner.aadharNo.toString(): partner.panNo.toString();
      _selectedIdType = partnerModel.panFront == null?   "Aadhar Card":"PAN Card";
      setFrontImageUrl(partnerModel);
      setBackImageUrl(partnerModel);
       licenseFilesUrl = partnerModel.experienceCertificates??[];
       for(var url in licenseFilesUrl){
         certificateFiles.add(CertificateFileModel(isPdf: url.toLowerCase().endsWith('.pdf'), isLocal: false,file: null,url: url));
       }
    //  certificateFiles = partnerModel.experienceCertificates??[];
       print("licenseFilesUrl...${licenseFilesUrl.length}");
      print(idController.text);
      print(idController.text);
    }
  }

  getProfileData() async{
    _profileResponse = await PreferencesServices.getProfileData();
    print("_profileResponse...${_profileResponse!.data!}");
    if(_profileResponse != null){
      if(_profileResponse!.data != null){
        if(_profileResponse!.data!.user != null){
          var profile = _profileResponse!.data!.user;
          _user = profile;
          if (profile != null) {
            if (profile.name != null && profile.name!.isNotEmpty) {
              nameController.text = profile.name!;
            }
            if (profile.email != null && profile.email!.isNotEmpty) {
              emailController.text = profile.email!;
            }
            if (profile.phone != null && profile.phone!.isNotEmpty) {
              mobileController.text = profile.phone!;
            }
          }
        }
        if(_profileResponse!.data!.partner != null){
          _partner = _profileResponse!.data!.partner;
          var partner = _partner;
          print("partner...${partner!.aadharFront}");
          if (partner != null) {
            if (partner.dob != null && partner.dob!.isNotEmpty) {
              try {
                DateTime parsedDob = DateTime.parse(partner.dob!);
                String formattedDob = DateFormat('d MMMM yyyy').format(parsedDob);
                dobController.text = formattedDob;
              } catch (e) {
                dobController.text = partner.dob!;
              }
            }
            if(partner.profile != null){
              _userProfileImage = partner.profile;
              notifyListeners();
            }
            // if (!profileProvider.isProfileComplete) {
            //   profileProvider.profileCompletionPercent = 1.0;
            // }
          }
        }
      }
    }
    notifyListeners();
  }

  // Profile details for profile details page
  String get profileName => _user?.name ?? _profileResponse?.data?.user?.name ?? '';
  String get profilePhone => _user?.phone != null && _user!.phone!.isNotEmpty ? _user!.phone! : (_profileResponse?.data?.user?.phone ?? '');
  String get profileImageUrl {
    if (_partner?.profile != null && _partner!.profile!.isNotEmpty) {
      return _partner!.profile!;
    }
    return 'https://randomuser.me/api/portraits/women/2.jpg';
  }
  String get profileCompletionText {
    if (_partner!.profileCompletion == 100) {
      return 'Profile 100% Complete!';
    } else if (_partner!.profileCompletion != 100 ) {
      return 'Only ${_partner!.profileCompletion}% Left to Go!';
    } else {
      return 'Complete your profile to unlock more features!';
    }
  }
  String get profileCompletionSubtext {
    if (profileCompletionPercent >= 1.0) {
      return 'You are ready to get jobs and earn!';
    } else {
      return 'Unlock jobs, earn faster, and get certified today.';
    }
  }
  List<String> get serviceCategories => _partner?.category ?? [];
  String get availabilityDays =>  'Monday to Saturday';
  String get availabilityTime =>  '9:00 AM – 7:00 PM';
  String get location {
    if (_partner != null) {
      String loc = '';
      if (_partner!.address != null && _partner!.address!.isNotEmpty) {
        loc += _partner!.address!;
      }
      if (_partner!.city != null && _partner!.city!.isNotEmpty) {
        loc += ', ${_partner!.city!}';
      }
      if (_partner!.state != null && _partner!.state!.isNotEmpty) {
        loc += ', ${_partner!.state!}';
      }
      if (_partner!.country != null && _partner!.country!.isNotEmpty) {
        loc += ', ${_partner!.country!}';
      }
      if (_partner!.pincode != null) {
        loc += ' – ${_partner!.pincode!}';
      }
      return loc.isNotEmpty ? loc : 'N/A';
    }
    return 'N/A';
  }
  String get serviceRange {
    if (_partner?.city != null && _partner?.serviceAreaDistance != null) {
      return '${_partner!.city!} (up to ${_partner!.serviceAreaDistance} km)';
    }
    return 'N/A';
  }
  bool get isProfileComplete => profileCompletionPercent >= 1.0;

  // Add these getters for use in TellUsAboutView
  String get name => nameController.text;
  String get dob => dobController.text;
  String get phone => mobileController.text;
  String get email => emailController.text;
  String? get userProfileImage => _userProfileImage;
  String? _userProfileImage;

  // Profile update API call
  Future<ProfileResponse> updateProfile(BuildContext context) async {
    ProfileResponse profileResponse = ProfileResponse();
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      //if (!validate()) return false;
      final fields = {
        AllKey.name: nameController.text,
        AllKey.email: emailController.text,
        AllKey.dob: dobController.text,
        AllKey.phone: mobileController.text,
      };
      final files = <http.MultipartFile>[];
      if (profileImage != null) {
        files.add(
          await http.MultipartFile.fromPath(AllKey.profile, profileImage!.path),
        );
      }
      final response = await ApiService().postMultipart(
        ApiPaths.profileUpdate,
        fields: fields,
        files: files,
      );

       profileResponse = ProfileResponse.fromJson(response);

      Navigator.of(context).pop(); // Remove
      if (profileResponse.success == true) {
        PreferencesServices.setPreferencesData(PreferencesServices.profilePendingScreens, profileResponse.data!.partner!.profilePendingScreens);
        await PreferencesServices.saveProfileData(profileResponse);
        if(profileResponse.data!.partner!.profilePendingScreens == 2){
          context.push(AppRouter.allCategory, extra: {
            'isEdit': true,
          },);
        }
        return profileResponse;
      } else {
        customToast(context, profileResponse.message.toString());
        return profileResponse;
      }
    } catch (e) {
      // Optionally set an error message here
      return profileResponse;
    }
  }

  // Loading state for document upload
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Upload Partner Documents API call
  Future<bool> uploadPartnerDocuments({
    required BuildContext context,
    required String? selectedIdType,
    required String idNumber,
  }) async {
    _isLoading = true;
    notifyListeners();
    // Validation for front and back images
    // if ((selectedIdType == "Aadhar Card" || selectedIdType == "PAN Card")) {
    //   if (_frontImage == null) {
    //     _isLoading = false;
    //     notifyListeners();
    //     customToast(context, "Please select the front image of your ${selectedIdType}.");
    //     return false;
    //   }
    //   if (_backImage == null) {
    //     _isLoading = false;
    //     notifyListeners();
    //     customToast(context, "Please select the back image of your ${selectedIdType}.");
    //     return false;
    //   }
    // }
    try {
      progressLoadingDialog(context, true);
      Map<String, String> fields = {};
      List<http.MultipartFile> files = [];
      // Flags and fields based on selected ID type
      if (selectedIdType == "Aadhar Card") {
        fields['isAadharCard'] = 'true';
        fields['aadharNo'] = idNumber;
        if (_frontImage != null) {
          final mimeType = lookupMimeType(_frontImage!.path);
          files.add(await http.MultipartFile.fromPath(
            'aadharFront',
            _frontImage!.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
        }
        if (_backImage != null) {
          final mimeType = lookupMimeType(_backImage!.path);
          files.add(await http.MultipartFile.fromPath(
            'aadharBack',
            _backImage!.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
        }
      }
      if (selectedIdType == "PAN Card") {
        fields['isPanCard'] = 'true';
        fields['panNo'] = idNumber;
        if (_frontImage != null) {
          final mimeType = lookupMimeType(_frontImage!.path);
          files.add(await http.MultipartFile.fromPath(
            'panFront',
            _frontImage!.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
        }
        if (_backImage != null) {
          final mimeType = lookupMimeType(_backImage!.path);
          files.add(await http.MultipartFile.fromPath(
            'panBack',
            _backImage!.path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
        }
      }
      // Experience certificates (multiple files, can be images or pdf)
      print("_experienceCertificates455..${licenseFiles.length}");

       for (int i = 0; i < licenseFiles.length; i++) {
           final mimeType = lookupMimeType(licenseFiles[i].path);
           files.add(await http.MultipartFile.fromPath(
             'experienceCertificates',
             licenseFiles[i].path,
             contentType: mimeType != null ? MediaType.parse(mimeType) : null,
           ));
        // }
       }
      // Call API
      final response = await ApiService().postMultipart(
        ApiPaths.uploadPartnerDocuments,
        fields: fields,
        files: files,
      );
      progressLoadingDialog(context, false);
     // Navigator.of(context).pop(); // Remove
      _isLoading = false;
      notifyListeners();



      if (response['success'] == true) {
        _profileResponse = ProfileResponse.fromJson(response);
        print("response...$response");
        PreferencesServices.setPreferencesData(PreferencesServices.profilePendingScreens, profileResponse!.data!.partner!.profilePendingScreens);
        await PreferencesServices.saveProfileData(_profileResponse!);
        notifyListeners();
       // if(_profileResponse!.data!.partner!.profilePendingScreens == 2){
          // context.go(AppRouter.allCategory);
          showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => CommonSuccessDialog(
                      image:SvgPicture.asset(MyAssetsPaths.certified,height: 132,width: 132,),
                      title: "You're Now a Certified Partner!",
                      subtitle: "You can now access more job requests and earn trust faster.",
                      buttonText: "Go to Dashboard",
                      onButtonTap: () {
                        Navigator.of(context).pop();
                        context.go(AppRouter.dashboard);
                      },
                    ),
                  );
       // }
        return true;
      } else {

        customToast(context,response['message']);
        return false;
      }
    } catch (e) {
      progressLoadingDialog(context, false);
      _isLoading = false;
      notifyListeners();
      customToast(context, e.toString());
      return false;
    }
  }

  // Validation method
  bool validateDocumentUpload( BuildContext context) {
    if (selectedIdType == null || selectedIdType!.isEmpty) {
      customToast(context, "Please select ID type.");
      return false;
    }
    else if (idController.text.trim().isEmpty) {
      customToast(context, "Please enter ID number.");
      return false;
    }
    //if (profileProvider.selectedIdType == "Aadhar Card" || profileProvider.selectedIdType == "PAN Card") {
    else  if (frontImage == null) {
      customToast(context, "Please select the front image of your ${selectedIdType}.");
      return false;
    }
    else if (backImage == null) {
      customToast(context, "Please select the back image of your ${selectedIdType}.");
      return false;
    }
    else if (experienceCertificates.isEmpty && experienceCertificates == null) {
      customToast(context, "Please select the experienceCertificates image of your ${selectedIdType}.");
      return false;
    }
    notifyListeners();
    // }
    return true;
  }

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
    _frontImageUrl = "null";
    notifyListeners();
  }

  void removeBackImage() {
    _backImage = null;
    _backImageUrl = "null";
    notifyListeners();
  }

  void removeLicenseImage() {
    _licenseImage = null;
    notifyListeners();
  }

  void unfocusf(context) {
    focusNode.unfocus();
   // FocusScope.of(context).unfocus();
    notifyListeners();
  }

 setFrontImageUrl(PartnerModel partner) {
    _frontImageUrl = partner.panFront != null ?partner.panFront.toString() :partner.aadharFront != null ?partner.aadharFront.toString()  : "null";
 // notifyListeners();
 //  return _frontImageUrl;
  }

setBackImageUrl(PartnerModel partner) {
    _backImageUrl = partner.panBack != null ?partner.panBack.toString() :partner.aadharBack != null ?partner.aadharBack.toString()  : "null";
    // notifyListeners();
    // return _backImageUrl;
  }
} 