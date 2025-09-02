import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../provider/payment_provider.dart';
import '../../widgets/transaction_history_card.dart';

class SeeAllTransactionsView extends StatefulWidget {
  const SeeAllTransactionsView({Key? key}) : super(key: key);

  @override
  State<SeeAllTransactionsView> createState() => _SeeAllTransactionsViewState();
}

class _SeeAllTransactionsViewState extends State<SeeAllTransactionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final paymentProvider = Provider.of<PaymentProvider>(context, listen: false);
      paymentProvider.fetchTransactionHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final transactions = paymentProvider.transactionHistory;
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
      body: paymentProvider.isTransactionLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('No transactions found'))
              : ListView.builder(
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