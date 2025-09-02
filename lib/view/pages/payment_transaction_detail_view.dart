import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/models/subscription_plan_model.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:flutter_dash/flutter_dash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/provider/payment_provider.dart';

class PaymentTransactionDetailView extends StatefulWidget {
  final SubscriptionPlanModel planModel;
  const PaymentTransactionDetailView({Key? key,required this.planModel}) : super(key: key);

  @override
  State<PaymentTransactionDetailView> createState() => _PaymentTransactionDetailViewState();
}

class _PaymentTransactionDetailViewState extends State<PaymentTransactionDetailView> {
  final TextEditingController _promoController = TextEditingController();
  int planMrp = 0;
  int planPrice = 0;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _clearCouponInput() {
    _promoController.clear();
    context.read<PaymentProvider>().resetCouponState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar((){
        Navigator.pop(context);
      }, ""),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 0),
                decoration: BoxDecoration(
                  color: MyColors.whiteColor,
                  borderRadius: BorderRadius.circular(32),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Payment Transaction Details', style: boldTextStyle(fontSize: 20.0, color: MyColors.blackColor)),
                        hsized5,
                        Text(
                          'View full details of your payment including amount, status, method, and date of transaction.',
                          style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                        ),
                        hsized20,
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: MyColors.whiteColor,
                            border: Border.all(color: MyColors.borderColor),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                             SvgPicture.asset(MyAssetsPaths.diamond),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        if(widget.planModel.mrp != widget.planModel.price)
                                        Text('₹${widget.planModel.mrp}', style: regularTextStyle(fontSize: 16.0, color: MyColors.lightText,).copyWith(decoration: TextDecoration.lineThrough)),
                                        wsized10,
                                        Text('₹${widget.planModel.price}', style: boldTextStyle(fontSize: 22.0, color: MyColors.blackColor)),
                                        Text('/month', style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText)),
                                      ],
                                    ),
                                    hsized5,
                                    Text('${widget.planModel.name}', style: semiBoldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),
                                    Text('Unlimited job access, faster payouts, visibility boost, premium support', style: regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 2.0),
                                        child: Text('Edit Plan', style: mediumTextStyle(fontSize: 14.0, color: MyColors.appTheme)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        hsized20,
                        Text('Add promo code', style: boldTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        hsized10,
                        Consumer<PaymentProvider>(
                          builder: (context, paymentProvider, child) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CommonTextField(
                                        controller: _promoController,
                                        hintText: 'Example: SAVE50',
                                        borderRadius: 12,
                                        borderColor: MyColors.borderColor,
                                        readOnly: paymentProvider.isPayLoading ||  paymentProvider.isLoading? true:false,
                                        focusedBorderColor: MyColors.appTheme,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        suffixIcon: paymentProvider.couponApplied 
                                          ? IconButton(
                                              icon: Icon(Icons.clear, color: MyColors.appTheme),
                                              onPressed: _clearCouponInput,
                                            )
                                          : null,
                                      ),
                                    ),
                                    wsized10,
                                    SizedBox(
                                      height: 44,
                                      child: CommonButton(
                                        text:   paymentProvider.isLoading ? 'Proceed...' : 'Apply',
                                        onTap: paymentProvider.isPayLoading  || paymentProvider.isLoading ? (){} : () async {
                                          final couponCode = _promoController.text.trim();
                                          if (couponCode.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please enter a coupon code'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          if (!paymentProvider.isValidCouponFormat(couponCode)) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please enter a valid coupon code (3-20 characters)'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }

                                          final success = await paymentProvider.checkCouponReferral(
                                            couponCode.toString(),
                                            widget.planModel.id ?? '',
                                          );

                                          if (!success) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(paymentProvider.couponMessage),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        },
                                        backgroundColor: MyColors.appTheme,
                                        textColor: MyColors.whiteColor,
                                        borderRadius: 12,
                                          width: paymentProvider.isLoading ?120:80,
                                        fontSize: 14.0,
                                        margin: EdgeInsets.zero,
                                        padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 0),
                                      ),
                                    ),
                                  ],
                                ),
                                                                 if (paymentProvider.couponApplied)
                                   Padding(
                                     padding: const EdgeInsets.only(top: 12.0, bottom: 8),
                                     child: Container(
                                       width: double.infinity,
                                       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                       decoration: BoxDecoration(
                                         color: MyColors.yellowColor,
                                         borderRadius: BorderRadius.circular(8),
                                       ),
                                       child: Column(
                                         crossAxisAlignment: CrossAxisAlignment.start,
                                         children: [
                                           Text(
                                             paymentProvider.couponMessage,
                                             style: boldTextStyle(fontSize: 14.0, color: MyColors.blackColor)
                                           ),

                                         ],
                                       ),
                                     ),
                                   ),
                                if (paymentProvider.couponMessage.isNotEmpty && !paymentProvider.couponApplied)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12.0, bottom: 8),
                                    child: Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        paymentProvider.couponMessage,
                                        style: regularTextStyle(fontSize: 14.0, color: Colors.red)
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        hsized10,
                        Text('Price Summary', style: boldTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        hsized10,
                        Consumer<PaymentProvider>(
                          builder: (context, paymentProvider, child) {
                            // Use API response data if available, otherwise use local data
                            var currentPlanPrice = paymentProvider.couponApplied && paymentProvider.planPrice > 0
                                ? paymentProvider.planPrice 
                                : widget.planModel.price.toDouble();


                            //= currentPlanPrice;
                            final finalPrice = paymentProvider.couponApplied && paymentProvider.totalPayable > 0 
                                ? paymentProvider.totalPayable 
                                : (currentPlanPrice - paymentProvider.discountAmount);
                            
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 15),
                              decoration: BoxDecoration(
                                color: MyColors.bg.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: MyColors.borderColor)
                              ),
                              child: Column(
                                children: [
                                  _priceRow('Plan Price', '₹${currentPlanPrice.toStringAsFixed(0)}'),
                                  if (paymentProvider.couponApplied && paymentProvider.discountAmount > 0 && paymentProvider.codeType.toLowerCase() == 'coupon code')
                                    _priceRow('${paymentProvider.getCodeTypeDisplayText()} (${paymentProvider.couponCode}):', '- ${paymentProvider.getDiscountDisplayText()}'),
                                 // Divider(color: MyColors.borderColor, height: 24),


                                  hsized10,
                                  DottedBorder(
                                    dashPattern: [3, 3],
                                    strokeWidth: 1,
                                    color: MyColors.borderColor,
                                    customPath: (size) => Path()
                                      ..moveTo(0, 0)
                                      ..lineTo(size.width, 0), // only top line
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: 1, // 1 pixel dotted line
                                    ),
                                  ),

                                  hsized4,
                                  _priceRow('Total Payable', '₹${finalPrice.toStringAsFixed(0)}', highlight: true),
                                ],
                              ),
                            );
                          },
                        ),
                        hsized30,
                        Row(
                          children: [
                            Expanded(
                              child: CommonButton(
                                text: 'Cancel',
                                onTap: () => Navigator.of(context).pop(),
                                backgroundColor: MyColors.whiteColor,
                                textColor: MyColors.blackColor,
                                borderColor: MyColors.borderColor,
                                borderRadius: 32,
                                fontSize: 16.0,
                                margin: EdgeInsets.zero,
                              ),
                            ),
                            SizedBox(width: 20,),
                            Expanded(
                              child: Consumer<PaymentProvider>(
                                builder: (context, paymentProvider, child) {
                                  return CommonButton(
                                    text: paymentProvider.isPayLoading ? 'Processing...' : 'Proceed',
                                    onTap: paymentProvider.isPayLoading ? (){} : () async {
                                      final planId = widget.planModel.id ?? '';
                             // Set planPrice in provider if condition is met
                                     // if (!paymentProvider.couponApplied && paymentProvider.planPrice == 0) {
                                        paymentProvider.setPlanPrice(widget.planModel.price.toDouble());
                                     // }

                                      if (planId.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Invalid plan ID'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }

                                      bool success = false;
                                      
                                      // Check if coupon is applied or referral points are available
                                      if (paymentProvider.couponApplied || paymentProvider.referralPoints > 0) {
                                        success = await paymentProvider.addSubscriptionPlan(planId);
                                      } else {
                                        success = await paymentProvider.subscriptionWithoutCode(planId);
                                      }

                                      if (success) {
                                        // Navigate to PhonePe view
                                        if (context.mounted) {
                                          context.push(AppRouter.phonePe);
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Failed to process subscription. Please try again.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    backgroundColor: MyColors.appTheme,
                                    textColor: MyColors.whiteColor,
                                    borderRadius: 32,
                                    fontSize: 16.0,
                                    margin: EdgeInsets.zero,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        hsized10,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style:highlight ?semiBoldTextStyle(fontSize: 14.0, color:MyColors.blackColor ): regularTextStyle(fontSize: 14.0, color:   MyColors.color7A849C)),
          Text(value, style: highlight ?semiBoldTextStyle(fontSize: 14.0, color:MyColors.color03526E ): regularTextStyle(fontSize: 14.0, color:  MyColors.darkText)),
        ],
      ),
    );
  }
} 