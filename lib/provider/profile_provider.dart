import 'dart:io';
import 'package:bharat_worker/constants/all_key.dart';
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/provider/category_provider.dart';
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
import 'package:bharat_worker/models/referral_history_model.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

// CertificateFileModel to manage both local files and URLs for certificates
class CertificateFileModel {
  final String? url; // Uploaded file ka URL
  final File? file; // Local file
  final bool isPdf; // PDF hai ya nahi
  final bool isLocal; // Local file hai ya uploaded URL

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
  final TextEditingController dob2Controller = TextEditingController();
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

  bool? _waitingForApproval;
  bool? get waitingForApproval => _waitingForApproval;

  String? _kycRejectionReason;
  String? get kycRejectionReason => _kycRejectionReason;

  String? _kycStatus;
  String? get kycStatus => _kycStatus;
  //
  // bool? _isOnline;
  // bool? get isOnline => _isOnline;

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
  double? _profileCompletionPercent;
  bool? _isLoader;
  bool? get isLoader => _isLoader;
  double? get profileCompletionPercent {
    if (_partner != null && _partner!.profileCompletion != null) {
      return (_partner!.profileCompletion! / 100.0).clamp(0.0, 1.0);
    }
    return _profileCompletionPercent;
  }
  // Remove the setter for profileCompletionPercent (now backend-driven)
  // set profileCompletionPercent(double value) {
  //   _profileCompletionPercent = value;
  //   notifyListeners();
  // }

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
  List<File> get filesToUpload => _certificateFiles
      .where((c) => c.isLocal && c.file != null)
      .map((c) => c.file!)
      .toList();

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

  void clearAllControllers() {
    dobController.clear();
    dob2Controller.clear();
    mobileController.clear();
    nameController.clear();
    emailController.clear();
    selectedIdType = null;
    _waitingForApproval = false;
    _kycRejectionReason = null;
    _kycStatus = null;
    _certificateFiles.clear();
    licenseFiles.clear();
    licenseFilesUrl.clear();
    // clearCertificateFiles();
    _experienceCertificates.clear();
    licenseFilesUrl.clear();
    licenseFiles.clear();
    _experienceCertificates.clear();
    _certificateFiles.clear();

    _backImage = null;
    _backImageUrl = "null";
    _frontImage = null;
    _frontImageUrl = "null";
    idController.clear();
    profileImage = null;
    _frontImage = null;
    _backImage = null;
    _licenseImage = null;
    _frontImageUrl = null;
    _backImageUrl = null;
    _licenseImageUrl = null;
    // removeCertificateFile(null);
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
      certificateFiles.add(CertificateFileModel(
          isPdf: file.path.toLowerCase().endsWith('.pdf'),
          isLocal: true,
          file: file,
          url: ""));
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

  ProfileProvider() {
    getProfileData();
    getProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    dobController.dispose();
    dob2Controller.dispose();
    mobileController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> pickImage(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        profileImage = File(pickedFile.path);
        imageError = null;
        notifyListeners();
      }
    }
  }

  Future<void> pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1800),
      lastDate: DateTime(2018),
    );
    if (picked != null) {
      dobController.text = DateFormat('d MMMM yyyy').format(picked);
      //  dobController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      dob2Controller.text =
          "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      dobError = null;
      notifyListeners();
    }
  }

  bool validate() {
    nameError = nameController.text.isEmpty ? 'Name is required' : null;
    dobError = dobController.text.isEmpty ? 'Date of birth is required' : null;
    mobileError =
        mobileController.text.isEmpty ? 'Mobile number is required' : null;
    emailError = emailController.text.isEmpty ? 'Email is required' : null;
    imageError = profileImage == null ? 'Profile image is required' : null;
    notifyListeners();
    return nameError == null &&
        dobError == null &&
        mobileError == null &&
        emailError == null &&
        imageError == null;
  }

  void clearErrors() {
    nameError = null;
    dobError = null;
    mobileError = null;
    emailError = null;
    imageError = null;
    notifyListeners();
  }

  setData(PartnerModel? partnerModel) {
    licenseFilesUrl.clear();
    licenseFiles.clear();
    certificateFiles.clear();
    final partner = partnerModel;
    if (partner != null) {
      idController.text = partnerModel!.panFront == null
          ? partner.aadharNo ?? ""
          : partner.panNo ?? "";
      _selectedIdType =
          partnerModel.panFront == null ? "Aadhar Card" : "PAN Card";
      setFrontImageUrl(partnerModel);
      setBackImageUrl(partnerModel);
      licenseFilesUrl = partnerModel.experienceCertificates!;
      print("licenseFilesUrl...$licenseFilesUrl");
      for (var url in licenseFilesUrl) {
        certificateFiles.add(CertificateFileModel(
            isPdf: url.toLowerCase().endsWith('.pdf'),
            isLocal: false,
            file: null,
            url: url));
      }
      // Set profile completion percent from backend
      if (partnerModel.profileCompletion != null) {
        _profileCompletionPercent =
            (partnerModel.profileCompletion! / 100.0).clamp(0.0, 1.0);
      }
      print("licenseFilesUrl...${licenseFilesUrl.length}");
      print(idController.text);
      print(idController.text);
    }
  }

  getProfileData() async {
    _profileResponse = await PreferencesServices.getProfileData();
    if (_profileResponse != null) {
      if (_profileResponse!.data != null) {
        if (_profileResponse!.data!.user != null) {
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
        if (_profileResponse!.data!.partner != null) {
          _partner = _profileResponse!.data!.partner;
          var partner = _partner;
          print("partner...${partner!.aadharFront}");
          if (partner != null) {
            _kycStatus = partner.kycStatus;
            _isOnline = partner.isOnline!;
            _kycRejectionReason = partner.kycRejectionReason;
            _waitingForApproval = partner.waitingForApproval;
            if (partner.dob != null && partner.dob!.isNotEmpty) {
              DateTime? parsedDob;
              try {
                parsedDob = DateFormat('dd MMMM yyyy').parse(partner.dob!);
              } catch (e) {
                // fallback: try ISO
                parsedDob = DateTime.tryParse(partner.dob!);
              }
              if (parsedDob != null) {
                // Format to: 24 December 1995
                String formattedDob =
                    DateFormat('d MMMM yyyy').format(parsedDob);
                dobController.text = partner.dob.toString();
                // Format to: 10/04/2000 (dd/MM/yyyy)
                dob2Controller.text =
                    DateFormat('dd/MM/yyyy').format(parsedDob);
                print(
                    "Formatted DOB: ${dobController.text}, dob2: ${dob2Controller.text}");
              } else {
                dobController.text = partner.dob!;
                dob2Controller.text = partner.dob!;
              }
            }

            // setCategorySubcategory(_partner!);
            if (partner.profile != null) {
              if (_partner!.isOnline != null) {
                _isOnline = _partner!.isOnline!;
              }
              _userProfileImage = partner.profile;
              notifyListeners();
            }
            // Set profile completion percent from backend
            if (partner.profileCompletion != null) {
              _profileCompletionPercent =
                  (partner.profileCompletion! / 100.0).clamp(0.0, 1.0);
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
  String get profileName =>
      _user?.name ?? _profileResponse?.data?.user?.name ?? '';
  String get profilePhone => _user?.phone != null && _user!.phone!.isNotEmpty
      ? _user!.phone!
      : (_profileResponse?.data?.user?.phone ?? '');
  String get profileImageUrl {
    if (_partner?.profile != null && _partner!.profile!.isNotEmpty) {
      return _partner!.profile!;
    }
    return '';
  }

  String get profileCompletionText {
    if (_partner!.profileCompletion == 100) {
      return 'Profile 100% Complete!';
    } else if (_partner!.profileCompletion != 100) {
      return 'Only ${_partner!.profileCompletion}% Left to Go!';
    } else {
      return 'Complete your profile to unlock more features!';
    }
  }

  String get profileCompletionSubtext {
    final percent = profileCompletionPercent ?? 0.0;
    if (percent >= 1.0) {
      return 'You are ready to get jobs and earn!';
    } else {
      return 'Unlock jobs, earn faster, and get certified today.';
    }
  }

  List<CategoryItem> get serviceCategories => _partner?.category ?? [];
  String get availabilityDays => 'Monday to Saturday';
  String get availabilityTime => '9:00 AM – 7:00 PM';
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

  bool get isProfileComplete => (profileCompletionPercent ?? 0.0) >= 1.0;

  // Referral code getters
  String get referralCode => _partner?.referralCode ?? 'N/A';
  String get referredBy => _partner?.referredBy.toString() ?? 'N/A';
  String? get referralPoints => _partner?.referralPoints.toString() ?? '0';

  // Add these getters for use in TellUsAboutView
  String get name => nameController.text;
  String get dob => dobController.text;
  String get phone => mobileController.text;
  String get email => emailController.text;
  String? get userProfileImage => _userProfileImage;
  String? _userProfileImage;

  // Profile update API call
  Future<ProfileResponse> updateProfile(
      BuildContext context, bool isEdit) async {
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
        AllKey.dob: dob2Controller.text,
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
        //await getProfile(context);
        customToast(context, profileResponse.message.toString());
        PreferencesServices.setPreferencesData(
            PreferencesServices.profilePendingScreens,
            profileResponse.data!.partner!.profilePendingScreens);
        await PreferencesServices.saveProfileData(profileResponse);
        print(
            "profileResponse.data!.partner!.profilePendingScreens...${profileResponse.data!.partner!.profilePendingScreens}");
        if (profileResponse.data!.partner!.profilePendingScreens == 2) {
          if (isEdit) {
            context.push(
              AppRouter.allCategory,
              extra: {
                'isEdit': true,
              },
            );
          } else {
            context.go(
              AppRouter.allCategory,
              extra: {
                'isEdit': false,
              },
            );
          }
        }
        return profileResponse;
      } else {
        customToast(context, profileResponse.message.toString());
        return profileResponse;
      }
    } catch (e) {
      Navigator.of(context).pop(); // Remove
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
    required bool isEdit,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String cleanIdNumber = selectedIdType == "Aadhar Card"
          ? idNumber.replaceAll(' ', '')
          : idNumber;
      progressLoadingDialog(context, true);
      Map<String, String> fields = {};
      List<http.MultipartFile> files = [];
      // Flags and fields based on selected ID type
      if (selectedIdType == "Aadhar Card") {
        fields['isAadharCard'] = 'true';
        fields['aadharNo'] = cleanIdNumber;
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

      if (licenseFiles.isNotEmpty) {
        for (int i = 0; i < licenseFiles.length; i++) {
          final mimeType = lookupMimeType(licenseFiles[i].path);
          files.add(await http.MultipartFile.fromPath(
            'experienceCertificates',
            licenseFiles[i].path,
            contentType: mimeType != null ? MediaType.parse(mimeType) : null,
          ));
          // }
        }
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
        // await getProfile(context);
        print(
            "_profileResponse...${_profileResponse!.data!.partner!.profileCompletion}");
        print("response...$response");
        PreferencesServices.setPreferencesData(
            PreferencesServices.profilePendingScreens,
            profileResponse!.data!.partner!.profilePendingScreens);
        await PreferencesServices.saveProfileData(_profileResponse!);
        notifyListeners();
        if (isEdit) {
          customToast(context, response['message'].toString());
        } else {
          context.push(AppRouter.subscriptionPlanView);
          // showDialog(
          //   context: context,
          //   barrierDismissible: false,
          //   builder: (context) => CommonSuccessDialog(
          //     image:SvgPicture.asset(MyAssetsPaths.certified,height: 132,width: 132,),
          //     title: "You're Now a Certified Partner!",
          //     subtitle: "You can now access more job requests and earn trust faster.",
          //     buttonText: "Go to Dashboard",
          //     onButtonTap: () {
          //       Navigator.of(context).pop();
          //       context.go(AppRouter.dashboard);
          //     },
          //   ),
          // );
        }

        // }
        return true;
      } else {
        customToast(context, response['message']);
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
  bool validateDocumentUpload(BuildContext context, bool isEdit) {
    if (selectedIdType == null || selectedIdType!.isEmpty) {
      customToast(context, "Please select ID type.");
      return false;
    } else if (idController.text.trim().isEmpty) {
      customToast(context, "Please enter ID number.");
      return false;
    }
    //if (profileProvider.selectedIdType == "Aadhar Card" || profileProvider.selectedIdType == "PAN Card") {
    else if (frontImage == null) {
      customToast(
          context, "Please select the front image of your ${selectedIdType}.");
      return false;
    } else if (backImage == null) {
      customToast(
          context, "Please select the back image of your ${selectedIdType}.");
      return false;
    } else if (!isEdit) {
      if (licenseFiles.isEmpty || licenseFiles == null) {
        customToast(context,
            "Please select the experienceCertificates image of your ${selectedIdType}.");
        return false;
      }
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

  setLoader(bool load) {
    print("load...$load");
    _isLoader = load;
    notifyListeners();
  }

  Future<void> getProfile() async {
    try {
      final response = await ApiService().get(ApiPaths.getProfile);
      setLoader(false);
      if (response['success'] == true) {
        _profileResponse = ProfileResponse.fromJson(response);
        await PreferencesServices.saveProfileData(_profileResponse!);
        getProfileData();
        notifyListeners();
      }
    } catch (e) {
      // customToast(context, e.toString());
    }
  }

  setFrontImageUrl(PartnerModel partner) {
    _frontImageUrl = partner.panFront != null
        ? partner.panFront.toString()
        : partner.aadharFront != null
            ? partner.aadharFront.toString()
            : "null";
    // notifyListeners();
    //  return _frontImageUrl;
  }

  setBackImageUrl(PartnerModel partner) {
    _backImageUrl = partner.panBack != null
        ? partner.panBack.toString()
        : partner.aadharBack != null
            ? partner.aadharBack.toString()
            : "null";
    // notifyListeners();
    // return _backImageUrl;
  }

  checkValue(
    PartnerModel? partnerModel,
  ) {
    print("_selectedIdType...$_selectedIdType");
    licenseFilesUrl.clear();
    licenseFiles.clear();
    // certificateFiles.clear();
    final partner = partnerModel;
    if (partner != null) {
      if (_selectedIdType == "Aadhar Card") {
        idController.text =
            partner.aadharNo != null ? partner.aadharNo ?? "" : "";
        _selectedIdType = "Aadhar Card";
        _frontImageUrl = partner.aadharFront != null
            ? partner.aadharFront.toString()
            : "null";
        _backImageUrl =
            partner.aadharBack != null ? partner.aadharBack.toString() : "null";
        // licenseFilesUrl = partner.experienceCertificates!;
      } else {
        idController.text = partner.panNo != null ? partner.panNo ?? "" : "";
        _selectedIdType = "PAN Card";
        _frontImageUrl =
            partner.panFront != null ? partner.panFront.toString() : "null";
        _backImageUrl =
            partner.panBack != null ? partner.panBack.toString() : "null";
        // licenseFilesUrl = partner.experienceCertificates!;
      }
      // idController.text = partnerModel!.panFront == null? partner.aadharNo??"": partner.panNo??"";
      // _selectedIdType = partnerModel.panFront == null?   "Aadhar Card":"PAN Card";
      // setFrontImageUrl(partnerModel);
      // setBackImageUrl(partnerModel);
      licenseFilesUrl = partner.experienceCertificates!;
      print("licenseFilesUrl...$licenseFilesUrl");
      for (var url in licenseFilesUrl) {
        certificateFiles.add(CertificateFileModel(
            isPdf: url.toLowerCase().endsWith('.pdf'),
            isLocal: false,
            file: null,
            url: url));
      }
      // Set profile completion percent from backend
      if (partner.profileCompletion != null) {
        _profileCompletionPercent =
            (partner.profileCompletion! / 100.0).clamp(0.0, 1.0);
      }
      print("licenseFilesUrl...${licenseFilesUrl.length}");
      print(idController.text);
      print(idController.text);
    }
  }

  void onChangeDropDown(String value, PartnerModel? partner) {
    print("tett" + value);

    selectedIdType = value;
    idController.clear();
    removeBackImage();
    removeFrontImage();
    // certificateFiles.clear();
    if (partner!.id != null) {
      print(partner.kycStatus);
      checkValue(partner);
    }

    notifyListeners();
  }

  // Submit for Approval API call
  Future<bool> submitForApproval(BuildContext context) async {
    try {
      progressLoadingDialog(context, true);

      // Call the API (POST, no body needed)
      final response = await ApiService().get(
        ApiPaths.waitingForApproval,
      );
      progressLoadingDialog(context, false);
      if (response['success'] == true) {
        _profileResponse = ProfileResponse.fromJson(response);
        // Save profilePendingScreens and profile data as everywhere else
        PreferencesServices.setPreferencesData(
          PreferencesServices.profilePendingScreens,
          _profileResponse!.data!.partner!.profilePendingScreens,
        );
        await PreferencesServices.saveProfileData(_profileResponse!);
        // Update local state
        _partner = _profileResponse!.data!.partner;
        _waitingForApproval = _partner?.waitingForApproval;
        _kycStatus = _partner?.kycStatus;
        notifyListeners();
        customToast(context, response['message'] ?? 'Submitted for approval!');
        return true;
      } else {
        customToast(
            context, response['message'] ?? 'Failed to submit for approval.');
        return false;
      }
    } catch (e) {
      progressLoadingDialog(context, false);
      customToast(context, e.toString());
      return false;
    }
  }

  // Online status for profile (for dropdown)
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  // Referral History
  ReferralHistoryResponse? _referralHistoryResponse;
  ReferralHistoryResponse? get referralHistoryResponse =>
      _referralHistoryResponse;
  bool _isReferralHistoryLoading = false;
  bool get isReferralHistoryLoading => _isReferralHistoryLoading;
  void setOnlineStatus(bool value, BuildContext context) {
    print("_isOnline.e4..${_isOnline}");
    _isOnline = !value;
    print("_isOnline...${_isOnline}");
    notifyListeners();
  }

  // Fetch Referral History
  Future<ReferralHistoryResponse?> getReferralHistory(
      BuildContext context) async {
    try {
      _isReferralHistoryLoading = true;
      notifyListeners();

      final response = await ApiService().get(ApiPaths.getReferralHistory);

      if (response['success'] == true) {
        _referralHistoryResponse = ReferralHistoryResponse.fromJson(response);
        notifyListeners();
        return _referralHistoryResponse;
      } else {
        customToast(
            context, response['message'] ?? 'Failed to fetch referral history');
        return null;
      }
    } catch (e) {
      customToast(context, e.toString());
      return null;
    } finally {
      _isReferralHistoryLoading = false;
      notifyListeners();
    }
  }

  // Update online/offline status and call API with current location
  Future<void> setOnlineStatusWithApi(bool value, BuildContext context) async {
    _isOnline = value;
    notifyListeners();
    try {
      // Get current location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      progressLoadingDialog(context, true);
      final payload = {
        "isOnline": value,
        "latitude": position.latitude.toString(),
        "longitude": position.longitude.toString(),
      };

      final response = await ApiService()
          .post(ApiPaths.updateTodayWorkingStatus, body: payload);
      progressLoadingDialog(context, false);
      if (response != null && response['success'] == true) {
        _profileResponse = ProfileResponse.fromJson(response);
        // Save profilePendingScreens and profile data as everywhere else
        PreferencesServices.setPreferencesData(
          PreferencesServices.profilePendingScreens,
          _profileResponse!.data!.partner!.profilePendingScreens,
        );
        await PreferencesServices.saveProfileData(_profileResponse!);
        // Update local state
        _partner = _profileResponse!.data!.partner;
        _waitingForApproval = _partner?.waitingForApproval;
        _kycStatus = _partner?.kycStatus;
        notifyListeners();
      }
      customToast(context, response['message'].toString());
      print("message..${response['message'].toString()}");
    } catch (e) {
      progressLoadingDialog(context, false);
      // Optionally show error
      print("Error updating online status: $e");
    }
  }
}
