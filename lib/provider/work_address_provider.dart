import 'package:flutter/material.dart';

class WorkAddressProvider extends ChangeNotifier {
  final TextEditingController addressController = TextEditingController();
  final TextEditingController countryController = TextEditingController(text: "India");
  final TextEditingController stateController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  final double _maxDistance = 40.0;
  double _distance;

  WorkAddressProvider() : _distance = 40.0;

  double get distance => _distance.clamp(0, 40.0);

  void setDistance(double value) {
    _distance = value.clamp(0, _maxDistance);
    notifyListeners();
  }
} 