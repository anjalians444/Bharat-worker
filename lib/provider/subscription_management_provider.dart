import 'package:flutter/material.dart';
import 'package:bharat_worker/models/subscription_details_model.dart';
import 'package:bharat_worker/services/api_service.dart';
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:bharat_worker/helper/router.dart';

class SubscriptionManagementProvider extends ChangeNotifier {
  SubscriptionDetailsResponse? subscriptionDetails;
  bool isLoading = false;
  String? error;

  SubscriptionManagementProvider() {
    fetchSubscriptionData();
  }

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<void> fetchSubscriptionData([BuildContext? context]) async {
    isLoading = true;
    error = null;
    notifyListeners();
    
    try {
      final response = await ApiService().get('partner/fetch-subscription-details');
      print("Subscription details response: $response");
      
      if (response['success'] == true && response['data'] != null) {
        subscriptionDetails = SubscriptionDetailsResponse.fromJson(response);
        error = null;
        
        // Check and show expired dialog if context is provided
        if (context != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            checkAndShowExpiredDialog(context);
          });
        }
      } else {
        error = response['message'] ?? 'Failed to fetch subscription details';
      }
    } catch (e) {
      error = e.toString();
      print("Error fetching subscription data: $e");
    }
    
    isLoading = false;
    notifyListeners();
  }

  Future<void> retryFetch([BuildContext? context]) async {
    if (!isLoading) {
      await fetchSubscriptionData(context);
    }
  }

  // Method to handle plan renewal
  Future<void> renewPlan(String planId) async {
    try {
      // In a real app, this would make an API call to renew the plan
      print("Renewing plan: $planId");
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Refresh subscription data after renewal
      await fetchSubscriptionData();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // Method to handle plan change
  Future<void> changePlan(String newPlanId) async {
    try {
      // In a real app, this would make an API call to change the plan
      print("Changing to plan: $newPlanId");
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Refresh subscription data after change
      await fetchSubscriptionData();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  // Getter for current plan
  ActivePlan? get currentPlan => subscriptionDetails?.data.activePlane;

  // Getter for upcoming plans
  List<UpcomingPlan> get upcomingPlans => subscriptionDetails?.data.upcomingPlans ?? [];

  // Check if subscription is expired or inactive
  bool get isSubscriptionExpired {
    if (subscriptionDetails?.data.activePlane == null) return true;
    
    final activePlan = subscriptionDetails!.data.activePlane!;
    return activePlan.status != 'active' || activePlan.remainingDays <= 0;
  }

  // Show subscription expired dialog
  void showSubscriptionExpiredDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image: SvgPicture.asset(
          MyAssetsPaths.expirePlan,
          height: 120,
          width: 120,
        ),
        title: 'Subscription Expired',
        subtitle: 'Your subscription has expired. Please renew to access new jobs.',
        buttonText: 'Buy Plan',
        onButtonTap: () {
          Navigator.of(context).pop();
          context.push(AppRouter.subscriptionPlanView);
        },
      ),
    );
  }

  // Check and show expired dialog if needed
  void checkAndShowExpiredDialog(BuildContext context) {
    if (isSubscriptionExpired) {
      showSubscriptionExpiredDialog(context);
    }
  }

  // Method to manually trigger expired dialog for testing
  void showExpiredDialogForTesting(BuildContext context) {
    showSubscriptionExpiredDialog(context);
  }
}
