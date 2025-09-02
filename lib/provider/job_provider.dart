import 'package:flutter/material.dart';

class JobProvider extends ChangeNotifier {
  String? budget;
  String? timeSlot;
  String? message;

  // Controllers
  final TextEditingController budgetController = TextEditingController();
  final TextEditingController timeSlotController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  // Extra Work Controllers
  final TextEditingController extraWorkTitleController = TextEditingController();
  final TextEditingController extraWorkDescriptionController = TextEditingController();
  final TextEditingController extraWorkChargesController = TextEditingController();
  final TextEditingController extraWorkTimeTakenController = TextEditingController();

  JobProvider() {
    // Set default current time
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    timeSlotController.text = timeString;
    timeSlot = timeString;
  }

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
    budgetController.clear();
    timeSlotController.clear();
    messageController.clear();
    
    // Reset to default current time
    final now = DateTime.now();
    final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    timeSlotController.text = timeString;
    timeSlot = timeString;
    
    notifyListeners();
  }

  void clearExtraWorkFields() {
    extraWorkTitleController.clear();
    extraWorkDescriptionController.clear();
    extraWorkChargesController.clear();
    extraWorkTimeTakenController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    budgetController.dispose();
    timeSlotController.dispose();
    messageController.dispose();
    extraWorkTitleController.dispose();
    extraWorkDescriptionController.dispose();
    extraWorkChargesController.dispose();
    extraWorkTimeTakenController.dispose();
    super.dispose();
  }
} 