import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/services/api_service.dart';
import 'package:bharat_worker/services/api_paths.dart';
import 'package:bharat_worker/models/coupon_response_model.dart';
import 'package:bharat_worker/models/transaction_history_model.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

class TransactionItem {
  final String iconPath;
  final String title;
  final String subtitle;
  final String date;
  final String amount;
  final bool isFailed;
  final bool isBonus;
  final bool isWithdraw;
  final String? statusLabel;
  final VoidCallback? onRetry;

  TransactionItem({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    this.isFailed = false,
    this.isBonus = false,
    this.isWithdraw = false,
    this.statusLabel,
    this.onRetry,
  });
}

class PaymentProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isPayLoading = false;
  bool _couponApplied = false;
  String _couponCode = '';
  double _discountAmount = 0.0;
  String _couponMessage = '';
  bool _isCouponValid = false;
  int _referralPoints = 0;
  String _codeType = '';
  double _planPrice = 0.0;
  double _totalPayable = 0.0;
  String _discountType = '';
  String _merchantOrderId = '';
  double _phonepeAmount = 0.0;
  String _phonepeToken = '';
  String _redirectLink = '';
  List<TransactionHistoryItem> _transactionHistory = [];
  bool _isTransactionLoading = false;

  // Getters
  bool get isLoading => _isLoading;
  bool get isPayLoading => _isPayLoading;
  bool get couponApplied => _couponApplied;
  String get couponCode => _couponCode;
  double get discountAmount => _discountAmount;
  String get couponMessage => _couponMessage;
  bool get isCouponValid => _isCouponValid;
  int get referralPoints => _referralPoints;
  String get codeType => _codeType;
  double get planPrice => _planPrice;
  double get totalPayable => _totalPayable;
  String get discountType => _discountType;
  String get merchantOrderId => _merchantOrderId;
  double get phonepeAmount => _phonepeAmount;
  String get phonepeToken => _phonepeToken;
  String get redirectLink => _redirectLink;
  List<TransactionHistoryItem> get transactionHistory => _transactionHistory;
  bool get isTransactionLoading => _isTransactionLoading;

  // Setters
  void setPlanPrice(double price) {
    print("price...$price");
    _planPrice = price;
    notifyListeners();
  }

  PaymentProvider() {
    _planPrice = 0;
    notifyListeners();
  }

  // Example data, replace with real data fetching logic
  final List<TransactionItem> _transactions = [
    TransactionItem(
      iconPath: MyAssetsPaths.transfer,
      title: 'UPI Transfer',
      subtitle: 'example@upi',
      date: '17 June, 2025',
      amount: '₹1250',
    ),
    TransactionItem(
      iconPath: MyAssetsPaths.bag,
      title: 'Job Payment (AC Service)',
      subtitle: 'Job ID: #BW20345',
      date: '12 June, 2025',
      amount: '₹1000',
    ),
    TransactionItem(
      iconPath: MyAssetsPaths.bank,
      title: 'Bank Transfer',
      subtitle: 'HDFC ****5678',
      date: '10 June, 2025',
      amount: '₹1200',
      isFailed: true,
      statusLabel: 'Failed',
    ),
    TransactionItem(
      iconPath: MyAssetsPaths.award,
      title: 'Bonus for 10 Jobs',
      subtitle: 'Performance Reward',
      date: '8 June, 2025',
      amount: '₹500',
      isBonus: true,
    ),
  ];

  List<TransactionItem> get transactions => _transactions;

  // Helper method to parse string to double
  double _parseStringToDouble(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  // Helper method to parse string to int
  int _parseStringToInt(String? value) {
    if (value == null || value.isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  }

  // Coupon/Referral API call
  Future<bool> checkCouponReferral(String couponCode, String planId) async {
    _isLoading = true;
    _couponApplied = false;
    _isCouponValid = false;
    _couponMessage = '';
    _discountAmount = 0.0;
    _referralPoints = 0;
    _codeType = '';
    _planPrice = 0.0;
    _totalPayable = 0.0;
    _discountType = '';
    notifyListeners();

    try {
      final payload = {
        "referralOrCoupon": couponCode,
        "subscriptionplans": planId,
      };

      final response = await ApiService().post(
        ApiPaths.checkCouponReferral,
        body: payload,
      );

      if (response != null) {
        final couponResponse = CouponResponseModel.fromJson(response);

        if (couponResponse.success) {
          _couponApplied = true;
          _couponCode = couponCode;
          _couponMessage = couponResponse.message;
          _isCouponValid = true;

          if (couponResponse.data != null) {
            final data = couponResponse.data!;
            _discountAmount = _parseStringToDouble(data.discountAmount);
            _referralPoints = _parseStringToInt(data.referalPoints.toString());
            _codeType = data.codeType ?? '';
            _planPrice = _parseStringToDouble(data.planPrice);
            _totalPayable = _parseStringToDouble(data.totalPayable);
            _discountType = data.discountType ?? '';
          }

          notifyListeners();
          return true;
        } else {
          _couponMessage = couponResponse.message;
          _isCouponValid = false;
          notifyListeners();
          return false;
        }
      } else {
        _couponMessage = 'Invalid response from server';
        _isCouponValid = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _couponMessage = e.toString().contains('Exception:')
          ? e.toString().split('Exception:')[1].trim()
          : 'Something went wrong. Please try again.';
      _isCouponValid = false;
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset coupon state
  void resetCouponState() {
    _couponApplied = false;
    _couponCode = '';
    _discountAmount = 0.0;
    _couponMessage = '';
    _isCouponValid = false;
    _referralPoints = 0;
    _codeType = '';
    _planPrice = 0.0;
    _totalPayable = 0.0;
    _discountType = '';
    _merchantOrderId = '';
    _phonepeAmount = 0.0;
    _phonepeToken = '';
    _redirectLink = '';
    notifyListeners();
  }

  // Validate coupon code format
  bool isValidCouponFormat(String couponCode) {
    if (couponCode.trim().isEmpty) return false;
    // Add any specific validation rules here if needed
    // For now, just check if it's not empty and has reasonable length
    return couponCode.trim().length >= 3 && couponCode.trim().length <= 20;
  }

  // Get display text for code type
  String getCodeTypeDisplayText() {
    switch (_codeType.toLowerCase()) {
      // case 'referral code':
      //   return 'Referral Code';
      case 'coupon code':
        return 'Discount';
      case 'discount code':
        return 'Discount';
      default:
        return _codeType.isNotEmpty ? _codeType : 'Discount';
    }
  }

  // Get discount display text
  String getDiscountDisplayText() {
    if (_discountType.toLowerCase() == '%') {
      return '${_discountAmount.toStringAsFixed(0)}% OFF';
    } else {
      return '₹${_discountAmount.toStringAsFixed(0)} OFF';
    }
  }

  // Add subscription plan with coupon/referral code
  Future<bool> addSubscriptionPlan(String planId) async {
    _isPayLoading = true;
    notifyListeners();

    try {
      Map<String, dynamic> payload = {
        "subscriptionplans": planId,
      };

      // Add referralOrCoupon if coupon is applied
      if (_couponApplied && _couponCode.isNotEmpty) {
        payload["referralOrCoupon"] = _couponCode;
      }

      // Add referalPoints if available
      if (_referralPoints > 0) {
        payload["referalPoints"] = _referralPoints.toString();
      }

      // Add other fields if available
      if (_planPrice > 0) {
        payload["planPrice"] = _planPrice.toStringAsFixed(2);
      }
      if (_discountAmount > 0) {
        payload["discount"] = _discountAmount.toStringAsFixed(2);
        payload["discountAmount"] = _discountAmount.toStringAsFixed(2);
      }
      if (_totalPayable > 0) {
        payload["totalPayable"] = _totalPayable.toStringAsFixed(2);
      }
      if (_discountType.isNotEmpty) {
        payload["discountType"] = _discountType;
      }
      if (_codeType.isNotEmpty) {
        payload["codeType"] = _codeType;
      }

      final response = await ApiService().post(
        ApiPaths.addSubscriptionPlan,
        body: payload,
      );

      if (response != null) {
        // Handle success response
        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          _merchantOrderId = data['merchantOrderId'].toString() ?? '';
          _phonepeAmount = _parseStringToDouble(data['amount']?.toString());
          _phonepeToken = data['phonepeToken'].toString() ?? '';
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error in addSubscriptionPlan: $e');
      return false;
    } finally {
      _isPayLoading = false;
      notifyListeners();
    }
  }

  // Add subscription plan without code
  Future<bool> subscriptionWithoutCode(String planId) async {
    _isPayLoading = true;
    notifyListeners();

    try {
      final payload = {
        "subscriptionplans": planId,
      };

      final response = await ApiService().post(
        ApiPaths.subscriptionWithoutCode,
        body: payload,
      );
      print(
          "ApiPaths.subscriptionWithoutCode,.${ApiPaths.subscriptionWithoutCode}");
      print(" response['data']...${response['data']}");

      if (response != null) {
        // Handle success response
        if (response['success'] == true && response['data'] != null) {
          final data = response['data'];
          _merchantOrderId = data['merchantOrderId'].toString() ?? '';
          _phonepeAmount = _parseStringToDouble(data['amount']?.toString());
          _phonepeToken = data['phonepeToken'].toString() ?? '';
          return true;
        }
        return false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error in subscriptionWithoutCode: $e');
      return false;
    } finally {
      _isPayLoading = false;
      notifyListeners();
    }
  }

  // Subscription Pay Now API call
  Future<Map<String, dynamic>> subscriptionPayNow() async {
    _isLoading = true;
    notifyListeners();

    try {
      final payload = {
        "merchantOrderId": _merchantOrderId,
        "amount": _phonepeAmount.toInt(),
        "phonepeToken": _phonepeToken,
      };

      final response = await ApiService().post(
        ApiPaths.subscriptionPayNow,
        body: payload,
      );

      if (response != null) {
        // Handle success response
        if (response['success'] == true) {
          // Extract redirect link from response
          if (response['data'] != null &&
              response['data']['redirectLink'] != null) {
            _redirectLink = response['data']['redirectLink'];
            notifyListeners();
          }
          return {
            'success': true,
            'redirectLink': _redirectLink,
            'message':
                response['message'] ?? 'Payment link generated successfully!'
          };
        }
        return {
          'success': false,
          'message': response['message'] ?? 'Payment failed'
        };
      } else {
        return {'success': false, 'message': 'No response from server'};
      }
    } catch (e) {
      print('Error in subscriptionPayNow: $e');
      return {
        'success': false,
        'message': 'Something went wrong. Please try again.'
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Subscription Payment Status API call
  Future<bool> subscriptionPaymentStatus(BuildContext context) async {
    try {
      final payload = {
        "merchantOrderId": _merchantOrderId,
        "phonepeToken": _phonepeToken,
      };

      progressLoadingDialog(context, true);
      final response = await ApiService().post(
        ApiPaths.subscriptionPaymentStatus,
        body: payload,
      );
      progressLoadingDialog(context, false);
      print("response...${response}");

      if (response != null) {
        return response['success'] == true;
      }
      return false;
    } catch (e) {
      print('Error in subscriptionPaymentStatus: $e');
      return false;
    }
  }

  void handlePaymentStatusUrl(BuildContext context) async {
    // Prevent multiple API calls for the same URL
    // if (_hasProcessedPaymentStatus) return;
    //
    // _hasProcessedPaymentStatus = true;
    print('Payment status URL detected, calling API...');

    try {
      // final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      final statusSuccess = await subscriptionPaymentStatus(context);

      if (statusSuccess) {
        handlePaymentSuccess(context);
      } else {
        handlePaymentFailure("Payment Status Failed", context);
      }
    } catch (e) {
      print('Error calling subscriptionPaymentStatus: $e');

      // handlePaymentFailure("API Error",context);
    }
  }

  void handlePaymentSuccess(BuildContext context) async {
    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image: SvgPicture.asset(
          MyAssetsPaths.paymentSuccess,
          height: 120,
          width: 120,
        ),
        title: 'Payment Successful',
        subtitle:
            'Your payment was successful! You can now continue using application.',
        buttonText: 'Go to Dashboard',
        onButtonTap: () async {
          context.go(AppRouter.dashboard);
        },
      ),
    );
  }

  void handlePaymentFailure(String s, BuildContext context) {
    print("Payment failure: $s");
    showFailureDialog(context);
  }

  void showFailureDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image: SvgPicture.asset(
          MyAssetsPaths.paymentFailled,
          height: 120,
          width: 120,
        ),
        title: 'Oops.. Payment Failed!',
        subtitle: 'Your payment was not successful. Please try again.',
        buttonText: 'Go Back',
        onButtonTap: () {
          Navigator.of(context).pop(); // Close dialog
          Navigator.of(context).pop(); // Go back to previous screen
        },
      ),
    );
  }

  // Fetch Transaction History API call
  Future<bool> fetchTransactionHistory() async {
    _isTransactionLoading = true;
    notifyListeners();

    try {
      final response = await ApiService().get(
        ApiPaths.fetchTransactionHistory,
      );

      if (response != null) {
        final transactionResponse = TransactionHistoryModel.fromJson(response);

        if (transactionResponse.success && transactionResponse.data != null) {
          _transactionHistory = transactionResponse.data!.transactionHistory;
          notifyListeners();
          return true;
        } else {
          print(
              'Transaction history fetch failed: ${transactionResponse.message}');
          return false;
        }
      } else {
        print('No response from server');
        return false;
      }
    } catch (e) {
      print('Error in fetchTransactionHistory: $e');
      return false;
    } finally {
      _isTransactionLoading = false;
      notifyListeners();
    }
  }

  // Refresh Subscription Payment Status API call
  Future<bool> refreshSubscriptionPaymentStatus(String transactionId) async {
    try {
      final response = await ApiService().get(
        '${ApiPaths.refreshSubscriptionPaymentStatus}$transactionId',
      );

      if (response != null) {
        if (response['success'] == true) {
          // Refresh the transaction history after successful status update
          //  await fetchTransactionHistory();
          return true;
        } else {
          print('Refresh payment status failed: ${response['message']}');
          return false;
        }
      } else {
        print('No response from server');
        return false;
      }
    } catch (e) {
      print('Error in refreshSubscriptionPaymentStatus: $e');
      return false;
    }
  }

  // Add more logic for filtering, loading, etc. as needed
}
