import 'package:flutter/material.dart';

class JobProvider extends ChangeNotifier {
  String? budget;
  String? timeSlot;
  String? message;

  // Extra Work Controllers
  final TextEditingController extraWorkTitleController = TextEditingController();
  final TextEditingController extraWorkDescriptionController = TextEditingController();
  final TextEditingController extraWorkChargesController = TextEditingController();
  final TextEditingController extraWorkTimeTakenController = TextEditingController();

  void setBudget(String value) {
    budget = value;
    notifyListeners();
  }

  void setTimeSlot(String value) {
    timeSlot = value;
    notifyListeners();
  }

  void setMessage(String value) {
    message = value;
    notifyListeners();
  }

  void setExtraWorkTitle(String value) {
    extraWorkTitleController.text = value;
    notifyListeners();
  }

  void setExtraWorkDescription(String value) {
    extraWorkDescriptionController.text = value;
    notifyListeners();
  }

  void setExtraWorkCharges(String value) {
    extraWorkChargesController.text = value;
    notifyListeners();
  }

  void setExtraWorkTimeTaken(String value) {
    extraWorkTimeTakenController.text = value;
    notifyListeners();
  }

  void updateJobDetails({String? budget, String? timeSlot, String? message}) {
    if (budget != null) this.budget = budget;
    if (timeSlot != null) this.timeSlot = timeSlot;
    if (message != null) this.message = message;
    notifyListeners();
  }

  void clear() {
    budget = null;
    timeSlot = null;
    message = null;
    notifyListeners();
  }

  void clearExtraWorkFields() {
    extraWorkTitleController.clear();
    extraWorkDescriptionController.clear();
    extraWorkChargesController.clear();
    extraWorkTimeTakenController.clear();
    notifyListeners();
  }
} 