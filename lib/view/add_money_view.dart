import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/my_colors.dart';
import '../constants/font_style.dart';
import '../constants/assets_paths.dart';

class AddMoneyView extends StatefulWidget {
  final bool isWithdraw;
  const AddMoneyView({Key? key, this.isWithdraw = false}) : super(key: key);

  factory AddMoneyView.withdraw() => const AddMoneyView(isWithdraw: true);

  @override
  State<AddMoneyView> createState() => _AddMoneyViewState();
}

class _AddMoneyViewState extends State<AddMoneyView> {
  String amount = '500';
  String selectedBank = 'HDFC Bank';
  final List<Map<String, String>> banks = [
    {'name': 'HDFC Bank', 'number': '**** **** 5678'},
    {'name': 'SBI Bank', 'number': '**** **** 1234'},
  ];

  void _onKeyTap(String value) {
    setState(() {
      if (value == '⌫') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else if (value == '.' && amount.contains('.')) {
        // Only one decimal point allowed
        return;
      } else {
        if (amount == '0') {
          amount = value;
        } else {
          amount += value;
        }
      }
      if (amount.isEmpty) amount = '0';
    });
  }

  void _showSuccessDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image: SvgPicture.asset(
          MyAssetsPaths.successSvg,
          height: 120,
          width: 120,
        ),
        title: widget.isWithdraw ? 'Withdrawal Requested' : 'Money Added\nSuccessfully',
        subtitle: widget.isWithdraw
            ? '₹$amount has been successfully requested to your UPI ID.'
            : '₹$amount has been added to your wallet.',
        buttonText: widget.isWithdraw ? 'Done' : 'OK, Got It',
        onButtonTap: () {
          widget.isWithdraw
              ?
          Navigator.of(context).pop():_showFailureDialog(context);
        },
      ),
    );
  }

  void _showFailureDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image: SvgPicture.asset(
          MyAssetsPaths.cancelSvg,
          height: 120,
          width: 120,
        ),
        title: 'Transaction Failed',
        subtitle: 'Something went wrong. Please try again or use another method.',
        buttonText: 'Retry',
        onButtonTap: () {
          Navigator.of(context).pop();
        },
        secondaryButtonText: 'Cancel',
        secondaryColor: MyColors.colorEBEBEB,
        secondaryBorderColor: MyColors.colorEBEBEB,
        secondaryHeight: 0.0,
        onSecondaryButtonTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: commonAppBar(() {
        Navigator.pop(context);
      }, widget.isWithdraw ? 'Withdraw Money' : languageProvider.translate('addMoney')),
      backgroundColor: MyColors.whiteColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hsized25,
            Text(widget.isWithdraw ? 'Available Balance' : 'Wallet Balance', style: regularTextStyle(fontSize: 14.0, color: MyColors.darkText)),
            const SizedBox(height: 5),
            Text(widget.isWithdraw ? '₹2,850' : '₹2,350', style: semiBoldTextStyle(fontSize: 20.0, color: MyColors.blackColor)),
            widget.isWithdraw ? const SizedBox(height: 60) : const SizedBox(height: 130),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '₹$amount',
                      style: boldTextStyle(fontSize: 40.0, color: MyColors.blackColor),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Container(
                width: 250,
                height: 1,
                color: MyColors.colorEBEBEB,
              ),
            ),
            widget.isWithdraw ? const SizedBox(height: 91) : const SizedBox(height: 110),
            if (widget.isWithdraw)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MyColors.colorEBEBEB),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedBank,
                    focusColor: Colors.white,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: banks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank['name'],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(bank['name']!, style: mediumTextStyle(fontSize: 15.0, color: MyColors.blackColor)),
                            const SizedBox(height: 2),
                            Text(bank['number']!, style: regularTextStyle(fontSize: 13.0, color: MyColors.color7A849C)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedBank = value!;
                      });
                    },
                  ),
                ),
              ),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.appTheme,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    _showSuccessDialog(context);
                  },
                  child: Text(widget.isWithdraw ? 'Withdraw Now' : 'Add Money', style: semiBoldTextStyle(fontSize: 16.0, color: Colors.white)),
                ),
              ),
            ),
            hsized25,
            Expanded(
              child: _CustomNumberPad(onKeyTap: _onKeyTap),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomNumberPad extends StatelessWidget {
  final void Function(String) onKeyTap;
  const _CustomNumberPad({required this.onKeyTap});

  @override
  Widget build(BuildContext context) {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: List.generate(keys.length * 2 - 1, (rowIdx) {
            if (rowIdx.isOdd) {
              // Horizontal divider
              return Container(
                height: 1,
                color: MyColors.colorEBEBEB,
              );
            } else {
              final row = keys[rowIdx ~/ 2];
              return Expanded(
                child: Row(
                  children: List.generate(row.length * 2 - 1, (colIdx) {
                    if (colIdx.isOdd) {
                      // Vertical divider with minimal flex
                      return Container(
                        width: 1,
                        color: MyColors.colorEBEBEB,
                        height: double.infinity,
                      );
                    } else {
                      final key = row[colIdx ~/ 2];
                      return Expanded(
                        flex: 10,
                        child: InkWell(
                          onTap: () => onKeyTap(key),
                          child: Center(
                            child: Text(
                              key,
                              style: TextStyle(fontSize: 28, color: MyColors.blackColor),
                            ),
                          ),
                        ),
                      );
                    }
                  }),
                ),
              );
            }
          }),
        );
      },
    );
  }
} 