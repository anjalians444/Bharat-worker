import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/provider/payment_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/view/phonepe_webview_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class PhonePeView extends StatefulWidget {
  const PhonePeView({super.key});

  @override
  State<PhonePeView> createState() => _PhonePeViewState();
}

class _PhonePeViewState extends State<PhonePeView> {
  bool _isPaymentProcessing = false;


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation during payment processing
        return !_isPaymentProcessing;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Consumer<PaymentProvider>(
            builder: (context, paymentProvider, child) {
            return Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 20),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _isPaymentProcessing ? null : () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: MyColors.borderColor),
                                borderRadius: BorderRadius.circular(12)
                            ),
                            padding: EdgeInsets.all(7),
                            child: Icon(
                              Icons.arrow_back,
                              size: 24,
                              color: _isPaymentProcessing ? Colors.grey : Colors.black,
                            )),
                      ),
                      SizedBox(width: 50,),
                      SvgPicture.asset(MyAssetsPaths.phonePe)
                    ],
                  ),
                ),
                // PhonePe Header
               /* Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      // PhonePe Logo

                    ],
                  ),
                ),*/

                hsized25,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal:20),
                    child: Column(
                      children: [
                        // Order Details Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:MyColors.borderColor,
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // Bharat Worker Icon
                              SvgPicture.asset(MyAssetsPaths.logo,height:50,width: 50,),

                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bharat Worker',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '1 item',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₹${paymentProvider.planPrice.toStringAsFixed(0)}.00',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Payment Options Card
                        Visibility(
                          visible: false,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Payment Options',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // UPI ID Option
                                _buildPaymentOption(
                                  icon: Icons.account_balance_wallet,
                                  iconColor: Colors.orange,
                                  title: 'UPI ID',
                                  subtitle: 'Use UPI for quick payments',
                                  onTap: () {},
                                ),

                                const SizedBox(height: 12),

                                // Net Banking Option
                                _buildPaymentOption(
                                  icon: Icons.account_balance,
                                  iconColor: const Color(0xFF5F259F),
                                  title: 'Net Banking',
                                  subtitle: 'Select from a list of banks',
                                  onTap: () {},
                                ),

                                const SizedBox(height: 12),

                                // Credit & Debit Cards Option
                                _buildPaymentOption(
                                  icon: Icons.credit_card,
                                  iconColor: const Color(0xFF5F259F),
                                  title: 'Credit & Debit Cards',
                                  subtitle: 'Save & pay via cards',
                                  onTap: () {},
                                ),

                                const SizedBox(height: 12),

                                // See more link
                                Center(
                                  child: TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'See more',
                                      style: TextStyle(
                                        color: Color(0xFF5F259F),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(),

                        // Total and Pay Button
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topRight: Radius.circular(20),topLeft: Radius.circular(20)),
                            boxShadow: [
                              BoxShadow(
                                color:MyColors.borderColor,
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'To Pay',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    '₹${paymentProvider.phonepeAmount.toStringAsFixed(0)}.00',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: CommonButton(
                                  text: (paymentProvider.isLoading || _isPaymentProcessing) ? 'Processing...' : 'Pay now',
                                  onTap: (paymentProvider.isLoading || _isPaymentProcessing) ? (){} : () async {
                                    setState(() {
                                      _isPaymentProcessing = true;
                                    });
                                    
                                    try {
                                      // Handle payment logic here
                                      final result = await paymentProvider.subscriptionPayNow();
                                      if (result['success']) {
                                        // Navigate to WebView for PhonePe payment
                                        if(result['redirectLink'].toString() != "connect ETIMEDOUT 2606:4700::6811:4bc3:443"){
                                          await Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PhonePeWebView(
                                                redirectLink: result['redirectLink'],
                                                title: 'PhonePe Payment',
                                                onPaymentStatusDetected: () {
                                                  // Call the payment provider's handlePaymentStatusUrl method
                                                  paymentProvider.handlePaymentStatusUrl(context);
                                                },
                                              ),
                                            ),
                                          );
                                        }else{
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(result['redirectLink'].toString()),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }

                                        // WebView will handle success/failure internally
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(result['message'] ?? 'Payment failed. Please try again.'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Something went wrong. Please try again.'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    } finally {
                                      setState(() {
                                        _isPaymentProcessing = false;
                                      });
                                    }
                                  },
                                  backgroundColor: (paymentProvider.isLoading || _isPaymentProcessing) ? MyColors.borderColor:MyColors.appTheme,
                                  textColor: Colors.white,

                                  borderRadius: 25,
                                  fontSize: 16.0,
                                  margin: EdgeInsets.zero,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ));
  }

  Widget _buildPaymentOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}