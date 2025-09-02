import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/transaction_history_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/my_colors.dart';
import '../constants/font_style.dart';
import '../constants/assets_paths.dart';
import '../provider/payment_provider.dart';

class MyPaymentView extends StatefulWidget {
  const MyPaymentView({Key? key}) : super(key: key);

  @override
  State<MyPaymentView> createState() => _MyPaymentViewState();
}

class _MyPaymentViewState extends State<MyPaymentView> {
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
                  child:  SvgPicture.asset(MyAssetsPaths.newJobRequestIcon,color: Colors.black,)),
              onTap: () {
                context.push(AppRouter.addMoney);
              },
            )
          ]),
      backgroundColor: MyColors.whiteColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Wallet Balance Card
              Container(
                width: double.infinity,

                decoration: BoxDecoration(
                  color: MyColors.yellowColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(17),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Wallet Balance', style: regularTextStyle(fontSize: 13.0, color: MyColors.darkText,)),
                          hsized5,
                          Text('₹2,350', style: semiBoldTextStyle(fontSize: 24.0, color: MyColors.blackColor,)),
                          hsized16,
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: MyColors.appTheme,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              padding: const EdgeInsets.symmetric(vertical:11, horizontal: 16),
                              elevation: 0,
                            ),
                            icon: SvgPicture.asset(MyAssetsPaths.withdraw, width: 22, height: 22, color: MyColors.appTheme),
                            label: Text('Withdraw Money', style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.appTheme, height: 1.2, overflow: TextOverflow.ellipsis)),
                            onPressed: () {
                              context.push(AppRouter.addMoney, extra: {'isWithdraw': true});
                            },
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                        right: 0,
                        bottom: 0,
                        child: Image.asset(MyAssetsPaths.bottomCardBg)),

                    Positioned(
                        left: 0,
                        top: 0,
                        child: Image.asset(MyAssetsPaths.topCardBg))
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Income & Withdrawn
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: MyColors.appTheme,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8.45),
                              decoration: BoxDecoration(
                                color: MyColors.whiteColor,
                                shape: BoxShape.circle
                              ),
                              child: SvgPicture.asset(MyAssetsPaths.wallet, width: 24, height: 24)),
                          hsized10,
                          Text('\$2410,567', style: semiBoldTextStyle(fontSize: 15.0, color: Colors.white, )),
                          hsized5,
                          Text('Total Income', style: regularTextStyle(fontSize: 13.0, color: Colors.white,)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: MyColors.colorF3F3F3,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              padding: const EdgeInsets.all(8.45),
                              decoration: BoxDecoration(
                                  color: MyColors.whiteColor,
                                  shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(color: MyColors.borderColor,blurRadius: 2)
                                ]
                              ),
                              child: SvgPicture.asset(MyAssetsPaths.moneyFilled, width: 24, height: 24)),
                          hsized10,
                          Text('\$4,987', style: semiBoldTextStyle(fontSize: 15.0, color: Colors.black, )),
                          hsized5,
                          Text('Total Withdrawn', style: regularTextStyle(fontSize: 13.0, color:MyColors.color838383,)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Payout Method
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  heading('Payout Method'),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh, size: 18, color: MyColors.appTheme),
                    label: Padding(
                      padding: const EdgeInsets.only(left:0.0),
                      child: Text('Edit Method', style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.appTheme,)),
                    ),
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 6, bottom: 18),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MyColors.colorEBEBEB),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text('Bank Account: XXXX5678', style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor, height: 1.2, overflow: TextOverflow.ellipsis)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: MyColors.appTheme.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check,size: 13,color: MyColors.appTheme,),

                            SizedBox(width:5),
                              Text('DEFAULT', style: mediumTextStyle(fontSize: 10.0, color: MyColors.appTheme, height: 1.2, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                        ),
                      ],
                    ),
                   hsized16,

                    Divider(color: MyColors.colorEBEBEB,),

                    hsized16,
                    Text('UPI ID: example@upi', style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                  ],
                ),
              ),
              // Recent Transactions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  heading('Recent Transactions'),
                  TextButton(
                    onPressed: () {
                      context.push(AppRouter.seeAllTransaction);
                     // Navigator.pushNamed(context, '/seeAllTransactions');
                    },
                    child: Text('See All', style: mediumTextStyle(fontSize: 12.0, color: MyColors.color7D7D7D, height: 1.2, overflow: TextOverflow.ellipsis)),
                  ),
                ],
              ),
              paymentProvider.isTransactionLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? const Center(child: Text('No transactions found'))
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: transactions.length > 4 ? 4 : transactions.length,
                          itemBuilder: (context, index) {
                            final transaction = transactions[index];
                            return TransactionHistoryCard(transaction: transaction);
                          },
                        ),
            ],
          ),
        ),
      ),
    );
  }

  heading(String s) {
    return  Text(s, style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor, height: 1.2, overflow: TextOverflow.ellipsis));
  }
} 