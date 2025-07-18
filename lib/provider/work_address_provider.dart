import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/models/profile_model.dart';
import 'package:bharat_worker/services/api_paths.dart';
import 'package:bharat_worker/services/api_service.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WorkAddressProvider extends ChangeNotifier {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController(text: "India");
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  final double _maxDistance = 40.0;
  double _distance;
  double? latitude;
  double? longitude;

  WorkAddressProvider() : _distance = 00.0;

  double get distance => _distance.clamp(0, 40.0);

  void setDistance(double value) {
    _distance = value.clamp(0, _maxDistance);
    notifyListeners();
  }

  // Error message variables
  String? addressError;
  String? countryError;
  String? stateError;
  String? cityError;
  String? pinCodeError;
  String? distanceError;

  bool get isValid =>
      addressError == null &&
      countryError == null &&
      stateError == null &&
      cityError == null &&
      pinCodeError == null &&
      distanceError == null;

  void validateFields() {
    addressError = addressController.text.trim().isEmpty ? 'Address is required' : null;
    countryError = countryController.text.trim().isEmpty ? 'Country is required' : null;
    stateError = stateController.text.trim().isEmpty ? 'State is required' : null;
    cityError = cityController.text.trim().isEmpty ? 'City is required' : null;
    pinCodeError = pinCodeController.text.trim().isEmpty
        ? 'Pin code is required'
        : (pinCodeController.text.trim().length != 6 ? 'Pin code must be 6 digits' : null);
    distanceError = distance == 0 ? 'Distance must be greater than 0' : null;
    // Optionally, validate lat/lng if required
    notifyListeners();
  }

  void setInitialAddressFromPartner(PartnerModel partner) {
    addressController.text = partner.address ?? '';
    countryController.text = partner.country ?? 'India';
    stateController.text = partner.state ?? '';
    cityController.text = partner.city ?? '';
    pinCodeController.text = partner.pincode?.toString() ?? '';
    latitude = partner.latitude;
    longitude = partner.longitude;
    setDistance((partner.serviceAreaDistance ?? 0).toDouble());
    notifyListeners();
  }

  // API call logic
  bool isLoading = false;
  String? apiError;
  Future<bool> workLocationUpdate(BuildContext context) async {
    ProfileResponse profileResponse = ProfileResponse();
    validateFields();
    if (!isValid) return false;
    isLoading = true;
    apiError = null;
    notifyListeners();
    try {
      final payload = {
        'address': addressController.text.trim(),
        'country': countryController.text.trim(),
        'state': stateController.text.trim(),
        'city': cityController.text.trim(),
        'pincode': pinCodeController.text.trim(),
        'serviceAreaDistance': distance.round(),
        'latitude': latitude,
        'longitude': longitude,
      };
      progressLoadingDialog(context, true);
      final response = await ApiService().post(
        ApiPaths.workLocationUpdate,
        body: payload,
      );

      progressLoadingDialog(context, false);
      if(response != null){
        // print("vrjhjj ...$response");

        if (response['success'] == true) {
          print("response ...${response['success']}");
          profileResponse = ProfileResponse.fromJson(response);
          print("profileResponse ...${profileResponse.success}");
          PreferencesServices.setPreferencesData(PreferencesServices.profilePendingScreens, profileResponse.data!.partner!.profilePendingScreens);
          await PreferencesServices.saveProfileData(profileResponse);
          if(profileResponse.data!.partner!.profilePendingScreens == 6){
            context.go(AppRouter.documentUploadSection);
          }
          customToast(context, response['message'].toString());
        }
        else {
          customToast(context, response['message'].toString());
        }
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isLoading = false;
      apiError = e.toString();
      notifyListeners();
      return false;
    }
  }
} 