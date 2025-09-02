import 'dart:async';
import 'package:bharat_worker/enums/register_enum.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/models/profile_model.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/work_address_provider.dart';
import 'package:bharat_worker/services/api_paths.dart';
import 'package:bharat_worker/services/google_sign_services.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:bharat_worker/services/api_service.dart';
import 'dart:convert';

import 'package:provider/provider.dart';

class AuthProvider extends ChangeNotifier {
  // Controllers
  final TextEditingController phoneController = TextEditingController();

  // Validation error
  String? phoneError;

  // Loading state
  bool isLoading = false;

  // Google Sign-In loading state
  bool _isGoogleSignInLoading = false;
  bool get isGoogleSignInLoading => _isGoogleSignInLoading;
  bool _isVerifyingOtp = false;
  bool get isVerifyingOtp => _isVerifyingOtp;
  ProfileResponse _profileResponse = ProfileResponse();
  ProfileResponse get profileResponse => _profileResponse;

  Country? _selectedCountry = Country(
    phoneCode: '91',
    countryCode: 'IN',
    e164Sc: 91,
    geographic: true,
    level: 1,
    name: 'India',
    example: '9876543210',
    displayName: 'India (IN) [+91]',
    displayNameNoCountryCode: 'India (IN)',
    e164Key: '91-IN-0',
  );
  String _title = "Welcome to Bharat Worker";
  bool _isLoginView = true;

  // Firebase phone auth state
  String? _verificationId;
  int? _resendToken;
  String? firebaseError;
  String _otp = "";
  String? _otpError;

  // Firebase token management
  StreamSubscription<User?>? _tokenSubscription;
  String? _idToken;
  String? get idToken => _idToken;

  ProfileResponse? _profile;
  ProfileResponse? get profile => _profile;

  Country? get selectedCountry => _selectedCountry;
  bool? get isLoginView => _isLoginView;
  String get title => _title;
  String get otp => _otp;
  String? get otpError => _otpError;
  String? get firebaseErrorMsg => firebaseError;

  void setSelectedCountry(Country country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }

  String? validatePhone(String phone) {
    if (_selectedCountry == null) return "Select country";
    if (_selectedCountry!.phoneCode == "91") {
      if (!RegExp(r'^[6-9]\d{9}�?$').hasMatch(phone)) {
        return "Enter valid Indian number";
      }
    } else if (_selectedCountry!.phoneCode == "1") {
      if (!RegExp(r'^\d{3}-\d{3}-\d{4}$').hasMatch(phone)) {
        return "Enter valid US number";
      }
    } else if (phone.isEmpty || phone.length < 6) {
      return "Enter valid phone number";
    }
    return null;
  }

  // 🔁 Start listening to token refresh
  void startTokenListener() {
    _tokenSubscription =
        FirebaseAuth.instance.idTokenChanges().listen((User? user) async {
      if (user != null) {
        _idToken = await user.getIdToken();
        PreferencesServices.setPreferencesData(
            PreferencesServices.idToken, _idToken);
        print("🟢 ID token refreshed: $_idToken");
      } else {
        _idToken = null;
        print("🔴 User signed out, token listener stopped");
      }
      notifyListeners();
    });
  }

  // 🛑 Stop listening
  void stopTokenListener() {
    _tokenSubscription?.cancel();
    _tokenSubscription = null;
    _idToken = null;
  }

  // 📱 Firebase Phone Login
  Future<void> loginWithPhone(BuildContext context) async {
    String? error = validatePhone(phoneController.text.trim());
    if (error != null) {
      setPhoneError(error);
      return;
    }
    isLoading = true;
    firebaseError = null;
    notifyListeners();
    final String phone =
        '+${_selectedCountry?.phoneCode ?? '91'}${phoneController.text.trim()}';
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          isLoading = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          firebaseError = e.message;
          isLoading = false;
          notifyListeners();
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(e.message!)));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          firebaseError = null;
          isLoading = false;
          notifyListeners();
          if (context.mounted) context.push(AppRouter.otpVerify);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Code sent")));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          isLoading = false;
          notifyListeners();
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      firebaseError = e.toString();
      isLoading = false;
      notifyListeners();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(firebaseError!)));
    }
  }

  // 🔑 Verify OTP
  Future<bool> verifyOtp(BuildContext context, String otp) async {
    if (_verificationId == null) {
      setOtpError('Verification ID missing. Please try again.');
      return false;
    }
    _isVerifyingOtp = true;
    firebaseError = null;
    notifyListeners();
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _idToken = await user.getIdToken();
        print("_idToken....$_idToken");
        PreferencesServices.setPreferencesData(
            PreferencesServices.idToken, _idToken);
        PreferencesServices.setPreferencesData(
            PreferencesServices.loginType, LoginType.typePhone.value);
        // Call login API
        bool loginResponse = await signUpApi(context, _idToken.toString());
        return loginResponse;
      }
      _isVerifyingOtp = false;
      notifyListeners();
      return true;
    } catch (e) {
      firebaseError = e.toString();
      setOtpError(e.toString());
      _isVerifyingOtp = false;
      notifyListeners();
      return false;
    }
  }

  // 🔁 Resend OTP
  Future<void> resendOtp() async {
    if (phoneController.text.trim().isEmpty) {
      setPhoneError('Enter phone number');
      return;
    }
    isLoading = true;
    firebaseError = null;
    notifyListeners();
    final String phone =
        '+${_selectedCountry?.phoneCode ?? '91'}${phoneController.text.trim()}';
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance.signInWithCredential(credential);
          isLoading = false;
          notifyListeners();
        },
        verificationFailed: (FirebaseAuthException e) {
          firebaseError = e.message;
          isLoading = false;
          notifyListeners();
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          isLoading = false;
          notifyListeners();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          isLoading = false;
          notifyListeners();
        },
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      firebaseError = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // 🔐 Google Login
  Future<void> loginWithGoogle(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      await GoogleSignInServices().googleSignup(context, this);
      //final user = FirebaseAuth.instance.currentUser;
      // if (user != null) {
      //   // Call the Google sign-up API with required payload
      //   await googleSignUpApi(context, user);
      // }
      //startTokenListener(); // ✅ Add this if Google login also used
      //   PreferencesServices.setPreferencesData(PreferencesServices.loginType, LoginType.typePhone.value);
    } catch (e) {
      print("Google Sign-In Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Call API after Google sign-in
  Future<void> googleSignUpApi(BuildContext context, User user) async {
    try {
      final payload = {
        "uid": user.uid ?? "",
        "name": user.displayName ?? "",
        "email": user.email ?? "",
        "phone": user.phoneNumber ?? "",
        "profile": user.photoURL ?? ""
      };
      final response = await ApiService().post1(
        ApiPaths.partnerGoogleAuth,
        body: payload,
        isToken: false, // No token needed for registration
      );
      print("response['success']...${response['success']}");
      // Handle response as needed (similar to signUpApi)
      if (response != null && response['success'] == true) {
        _profile = ProfileResponse(
            success: response['success'],
            message: response['message'],
            data: ProfileData.fromJson(response['data']));
        print("response['success']...${response}");
        PreferencesServices.setPreferencesData(
            PreferencesServices.isLogin, true);
        _profileResponse = _profile!;
        notifyListeners();
        await PreferencesServices.saveProfileData(_profile!);
        PreferencesServices.setPreferencesData(
            PreferencesServices.userToken, _profile!.data!.token.toString());
        PreferencesServices.setPreferencesData(
            PreferencesServices.profilePendingScreens,
            _profile!.data!.partner!.profilePendingScreens);

        print(
            " _profile!.data!.partner!.profilePendingScreens..${_profile!.data!.partner!.profilePendingScreens}");
        int? profilePendingScreens =
            _profile!.data!.partner!.profilePendingScreens;
        notifyListeners();
        if (profilePendingScreens == 1) {
          context.go(AppRouter.tellUsAbout);
        } else if (profilePendingScreens == 2) {
          context.go(
            AppRouter.allCategory,
            extra: {
              'isEdit': false,
            },
          );
        } else if (profilePendingScreens == 5) {
          context.go(AppRouter.workAddress);
        } else if (profilePendingScreens == 6) {
          context.go(AppRouter.documentUploadSection);
        } else if (profilePendingScreens == 0) {
          context.go(AppRouter.dashboard);
        }
      } else {
        firebaseError = response != null
            ? response['message']
            : 'Google Sign Up API failed';
        notifyListeners();
      }
    } catch (apiError) {
      firebaseError = 'Google Sign Up API failed: ' + apiError.toString();
      notifyListeners();
    }
  }

  // Facebook login logic
  Future<void> loginWithFacebook(BuildContext context) async {
    isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    PreferencesServices.setPreferencesData(
        PreferencesServices.loginType, LoginType.loginTypeFacebook.value);
    isLoading = false;
    notifyListeners();
    // TODO: Handle Facebook login
  }

  // 🚪 Logout
  Future<void> logout(BuildContext context) async {
    String loginType = await PreferencesServices.getPreferencesData(
        PreferencesServices.loginType);
    if (loginType == LoginType.loginTypeGoogle.value) {
      GoogleSignInServices().logoutFromGoogle();
    } else if (loginType == LoginType.typePhone) {
      await FirebaseAuth.instance.signOut();
    }
    stopTokenListener(); // ✅ Stop listener
    PreferencesServices.setPreferencesData(PreferencesServices.isLogin, false);
    PreferencesServices.setPreferencesData(PreferencesServices.userToken, null);
    PreferencesServices.setPreferencesData(PreferencesServices.userId, null);
    PreferencesServices.removeProfileData();
    isLoading = false;
    _isVerifyingOtp = false;
    phoneController.clear();
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final workProvider =
        Provider.of<WorkAddressProvider>(context, listen: false);
    categoryProvider.selectedCategoryIds.clear();
    categoryProvider.selectedSubCategoryIds.clear();
    profileProvider.clearAllControllers();
    categoryProvider.clear();
    // categoryProvider.clearSelections();
    workProvider.clearField();
    notifyListeners();

    notifyListeners();
  }

  // Other setters
  void setPhoneError(String? error) {
    phoneError = error;
    notifyListeners();
  }

  void setLogin(bool login) {
    _isLoginView = login;
    notifyListeners();
  }

  void setOtp(String value) {
    _otp = value;
    notifyListeners();
  }

  void setOtpError(String? error) {
    _otpError = error;
    notifyListeners();
  }

  void clearOtp() {
    _otp = '';
    _otpError = null;
    notifyListeners();
  }

  Future<bool> checkLoginStatus() async {
    final isLoggedIn = await PreferencesServices.getPreferencesData(
        PreferencesServices.isLogin);
    return isLoggedIn == true;
  }

  @override
  void dispose() {
    phoneController.dispose();
    stopTokenListener(); // Clean up listener
    super.dispose();
  }

  Future<bool> signUpApi(BuildContext context, String idToken) async {
    try {
      final loginResponse = await ApiService()
          .post1(ApiPaths.register, body: {"token": idToken}, isToken: false);
      // Parse and save profile
      if (loginResponse != null) {
        _profile = ProfileResponse(
            success: loginResponse['success'],
            message: loginResponse['message'],
            data: ProfileData.fromJson(loginResponse['data']));
        print("profile....${_profile!.data!.partner!.category!.length}");

        if (_profile!.success == true) {
          PreferencesServices.setPreferencesData(
              PreferencesServices.isLogin, true);
          _profileResponse = _profile!;
          notifyListeners();
          await PreferencesServices.saveProfileData(_profile!);
          PreferencesServices.setPreferencesData(
              PreferencesServices.userToken, _profile!.data!.token.toString());
          PreferencesServices.setPreferencesData(
              PreferencesServices.profilePendingScreens,
              _profile!.data!.partner!.profilePendingScreens);
          int? profilePendingScreens =
              _profile!.data!.partner!.profilePendingScreens;

          notifyListeners();
          if (profilePendingScreens == 1) {
            context.go(AppRouter.tellUsAbout);
          } else if (profilePendingScreens == 2) {
            context.go(
              AppRouter.allCategory,
              extra: {
                'isEdit': false,
              },
            );
          } else if (profilePendingScreens == 5) {
            context.go(AppRouter.workAddress);
          } else if (profilePendingScreens == 6) {
            context.go(AppRouter.documentUploadSection);
          } else if (profilePendingScreens == 0) {
            context.go(AppRouter.dashboard);
          }
        }
      }
      return _profile!.success == true ? true : false;
    } catch (apiError) {
      print("apiError....${apiError.toString()}");
      firebaseError = 'Login API failed: ' + apiError.toString();
      setOtpError(firebaseError);
      _isVerifyingOtp = false;
      notifyListeners();
      return false;
    }
  }
}
