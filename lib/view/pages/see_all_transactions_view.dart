import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../provider/payment_provider.dart';
import '../../widgets/transaction_history_card.dart';

class SeeAllTransactionsView extends StatelessWidget {
  const SeeAllTransactionsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final transactions = paymentProvider.transactions;
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar:commonAppBar((){
        Navigator.pop(context);
      },languageProvider.translate('my_payments'),
          actions: [
            InkWell(
              child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: MyColors.borderColor),
                      borderRadius: BorderRadius.circular(12)
                  ),
                  padding: EdgeInsets.all(10),
                  child:  SvgPicture.asset(MyAssetsPaths.filter,color: Colors.black,)),
              onTap: () {
                // context.push(AppRouter.notifications);
              },
            )
          ]),
      backgroundColor: MyColors.whiteColor,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return TransactionHistoryCard(transaction: transaction);
        },
      ),
    );
  }
} 