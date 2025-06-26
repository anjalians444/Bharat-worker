import 'package:bharat_worker/constants/sized_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../provider/payment_provider.dart';
import '../constants/font_style.dart';
import '../constants/my_colors.dart';

class TransactionHistoryCard extends StatelessWidget {
  final TransactionItem transaction;
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
        margin: const EdgeInsets.symmetric(vertical:5),
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
                  borderRadius: BorderRadius.circular(10)
                ),
                child: SvgPicture.asset(transaction.iconPath, width:24, height:24)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.title, style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                  const SizedBox(height: 4),
                  Text(transaction.subtitle, style: regularTextStyle(fontSize: 13.0, color: MyColors.color7A849C)),
                  if (transaction.isFailed && transaction.statusLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Text(transaction.statusLabel!, style: regularTextStyle(fontSize: 12.0, color: Colors.red)),
                          if (transaction.onRetry != null) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: transaction.onRetry,
                              child: Text('Retry', style: regularTextStyle(fontSize: 12.0, color: MyColors.appTheme, decoration: TextDecoration.underline)),
                            ),
                          ]
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(transaction.amount, style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
               hsized4,
                Text(transaction.date, style: regularTextStyle(fontSize: 13.0, color: MyColors.color7A849C)),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 