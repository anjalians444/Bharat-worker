import 'package:bharat_worker/constants/sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../provider/payment_provider.dart';
import '../models/transaction_history_model.dart';
import '../constants/font_style.dart';
import '../constants/my_colors.dart';
import '../constants/assets_paths.dart';
import 'package:provider/provider.dart';

class TransactionHistoryCard extends StatelessWidget {
  final TransactionHistoryItem transaction;
  final VoidCallback? onTap;

  const TransactionHistoryCard({
    Key? key,
    required this.transaction,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: MyColors.whiteColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MyColors.colorEBEBEB),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                padding: EdgeInsets.all(9.5),
                decoration: BoxDecoration(
                    color: MyColors.colorF3F3F3,
                    borderRadius: BorderRadius.circular(10)),
                child: SvgPicture.asset(_getIconPath(), width: 24, height: 24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_getTitle(),
                      style: semiBoldTextStyle(
                          fontSize: 14.0, color: MyColors.blackColor)),
                  const SizedBox(height: 4),
                  Text(_getSubtitle(),
                      style: regularTextStyle(
                          fontSize: 13.0, color: MyColors.color7A849C)),
                  //if (!transaction.isCompleted)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(
                      children: [
                        Text(transaction.paymentStatus ?? 'Pending',
                            style: regularTextStyle(
                                fontSize: 12.0, color: _getColor())),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(transaction.formattedAmount,
                    style: mediumTextStyle(
                        fontSize: 14.0, color: MyColors.blackColor)),
                hsized4,
                Text(transaction.formattedDate,
                    style: regularTextStyle(
                        fontSize: 13.0, color: MyColors.color7A849C)),
                // Add refresh button for pending transactions
                if (_isPendingTransaction())
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: InkWell(
                      onTap: () => _handleRefresh(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: MyColors.appTheme.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.refresh,
                          size: 16,
                          color: MyColors.appTheme,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _isPendingTransaction() {
    return transaction.paymentStatus?.toLowerCase() == 'pending' &&
        transaction.paymentFor?.toLowerCase() == 'subscription';
  }

  void _handleRefresh(BuildContext context) async {
    if (transaction.transactionId != null) {
      final paymentProvider =
          Provider.of<PaymentProvider>(context, listen: false);

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Refreshing payment status...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      final success = await paymentProvider
          .refreshSubscriptionPaymentStatus(transaction.merchantOrderId!);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment status updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update payment status. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getIconPath() {
    switch (transaction.paymentMethod?.toLowerCase()) {
      case 'net_banking':
        return MyAssetsPaths.bank;
      case 'upi':
        return MyAssetsPaths.transfer;
      case 'card':
        return MyAssetsPaths.bag;
      default:
        return MyAssetsPaths.transfer;
    }
  }

  String _getTitle() {
    switch (transaction.paymentFor?.toString()) {
      case 'subscription':
        return 'Subscription Payment';
      case 'job':
        return 'Job Payment';
      case 'withdrawal':
        return 'Withdrawal';
      default:
        return transaction.particular ?? 'Transaction';
    }
  }

  Color _getColor() {
    switch (transaction.paymentStatus.toString()) {
      case 'COMPLETED':
        return MyColors.greenColor;
      case 'FAILED':
        return MyColors.redColor;
      case 'PENDING':
        return MyColors.yellowColor;
      default:
        return MyColors.greenColor;
    }
  }

  String _getSubtitle() {
    if (transaction.invoiceNo != null) {
      return 'Invoice: ${transaction.invoiceNo}';
    } else if (transaction.merchantOrderId != null) {
      return 'Order: ${transaction.merchantOrderId}';
    } else {
      return transaction.particular ?? 'Transaction';
    }
  }
}
