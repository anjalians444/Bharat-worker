import 'package:flutter/material.dart';
import 'package:bharat_worker/models/subscription_plan_model.dart';
import 'package:bharat_worker/services/api_service.dart';

class SubscriptionProvider extends ChangeNotifier {
  List<SubscriptionPlanModel> plans = [];
  bool isLoading = false;
  String? error;

  SubscriptionProvider(){
    fetchSubscriptionPlans();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<void> fetchSubscriptionPlans() async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final response = await ApiService().get('partner/get-subscription-plans');
      print("response...$response");
      if (response['success'] == true && response['data'] != null) {
        plans = (response['data'] as List)
            .map((e) => SubscriptionPlanModel.fromJson(e))
            .toList();
        error = null; // Clear any previous errors
      } else {
        error = response['message'] ?? 'Unknown error';
      }
    } catch (e) {
      error = e.toString();
      print("Error fetching subscription plans: $e");
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> retryFetch() async {
    if (!isLoading) {
      await fetchSubscriptionPlans();
    }
  }
} 