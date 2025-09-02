class TransactionHistoryModel {
  final bool success;
  final TransactionHistoryData? data;
  final String message;

  TransactionHistoryModel({
    required this.success,
    this.data,
    required this.message,
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? TransactionHistoryData.fromJson(json['data']) : null,
      message: json['message'] ?? '',
    );
  }
}

class TransactionHistoryData {
  final List<TransactionHistoryItem> transactionHistory;

  TransactionHistoryData({
    required this.transactionHistory,
  });

  factory TransactionHistoryData.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryData(
      transactionHistory: (json['transactionHistory'] as List?)
          ?.map((item) => TransactionHistoryItem.fromJson(item))
          .toList() ?? [],
    );
  }
}

class TransactionHistoryItem {
  final String? transactionId;
  final String? id;
  final String? adminId;
  final String? partnerId;
  final String? customerId;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentBy;
  final String? paymentFor;
  final String? paymentforSubscription;
  final String? invoiceNo;
  final String? merchantOrderId;
  final String? particular;
  final int? amount;
  final String? transactionType;
  final String? transactionDate;
  final String? createdAt;
  final String? updatedAt;
  final int? version;

  TransactionHistoryItem({
    this.transactionId,
    this.id,
    this.adminId,
    this.partnerId,
    this.customerId,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentBy,
    this.paymentFor,
    this.paymentforSubscription,
    this.invoiceNo,
    this.merchantOrderId,
    this.particular,
    this.amount,
    this.transactionType,
    this.transactionDate,
    this.createdAt,
    this.updatedAt,
    this.version,
  });

  factory TransactionHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryItem(
      transactionId: json['transactionId'],
      id: json['_id'],
      adminId: json['adminId'],
      partnerId: json['partnerId'],
      customerId: json['customerId'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      paymentBy: json['paymentBy'],
      paymentFor: json['paymentFor'],
      paymentforSubscription: json['paymentforSubscription'],
      invoiceNo: json['invoiceNo'],
      merchantOrderId: json['merchantOrderId'],
      particular: json['particular'],
      amount: json['amount'],
      transactionType: json['transactionType'],
      transactionDate: json['transactionDate'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      version: json['__v'],
    );
  }

  // Helper method to get formatted date
  String get formattedDate {
    if (transactionDate == null) return '';
    try {
      final date = DateTime.parse(transactionDate!);
      return '${date.day} ${_getMonthName(date.month)}, ${date.year}';
    } catch (e) {
      return '';
    }
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Helper method to get formatted amount
  String get formattedAmount {
    if (amount == null) return '₹0';
    return '₹${amount.toString()}';
  }

  // Helper method to get transaction icon based on payment method
  String get transactionIcon {
    switch (paymentMethod?.toLowerCase()) {
      case 'net_banking':
        return 'bank';
      case 'upi':
        return 'transfer';
      case 'card':
        return 'bag';
      default:
        return 'transfer';
    }
  }

  // Helper method to get transaction status color
  bool get isCompleted {
    return paymentStatus?.toLowerCase() == 'completed';
  }

  // Helper method to get transaction type display
  String get transactionTypeDisplay {
    switch (transactionType?.toLowerCase()) {
      case 'debited':
        return 'Debited';
      case 'credited':
        return 'Credited';
      default:
        return transactionType ?? '';
    }
  }
} 