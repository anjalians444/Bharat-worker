import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:flutter/material.dart';

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
      iconPath:MyAssetsPaths.bank,
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

  // Add more logic for filtering, loading, etc. as needed
} 