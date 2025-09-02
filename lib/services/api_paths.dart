class ApiPaths {
  // static const String baseUrl = "http://161.97.107.255:3000/api/";
  static const String baseUrl = "https://api.bharatworker.com/api/";

  static const String login = "partner/login";
  static const String register = "partner/partnerSignup";
  static const String partnerGoogleAuth = "partner/partner-google-auth";
  static const String profileUpdate = "partner/profileUpdate";
  static const String getUser = "user";
  static const String getServices = "partner/getServices";
  static const String getServicesByCategory = "partner/getServicesByCategory";
  static const String partnerSkills = "partner/partnerSkills";
  static const String getYearExperience = "partner/get-years-experience";
  static const String workLocationUpdate = "partner/workLocationUpdate";
  static const String uploadPartnerDocuments = "partner/uploadPartnerDocuments";
  static const String getProfile = "partner/get-profile";
  static const String waitingForApproval = "partner/waiting-for-approval";
  static const String updateTodayWorkingStatus =
      "partner/update-today-working-Status";
  static const String checkCouponReferral = "coupon-code/check-coupon-referral";
  static const String getReferralHistory = "partner/get-referral-history";
  static const String userList = "partner/booked-customers";
  static const String addSubscriptionPlan = "partner/add-subscription-plan";
  static const String subscriptionWithoutCode =
      "partner/subscription-without-code";
  static const String subscriptionPayNow =
      "phonepe/partner-subscription-pay-now";
  static const String subscriptionPaymentStatus =
      "partner/partner-subscription-payment-status";
  static const String refreshSubscriptionPaymentStatus =
      "partner/refresh-subscription-payment-status/";
  static const String fetchTransactionHistory =
      "partner/fetch-transaction-history";
  static const String getActiveJobs = "partner/get-active-jobs";
  static const String getJobDetail = "partner/get-job-details/";
  static const String addJobBid = "partner/add-job-bid";
  static const String bidCancel = "partner/bid-cancel";
// Add more endpoints here...
}
