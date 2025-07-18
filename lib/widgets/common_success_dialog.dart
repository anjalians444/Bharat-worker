import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';

class CommonSuccessDialog extends StatelessWidget {
  final Widget image;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonTap;
  final bool isCancel;
  final Widget? extraContent;
  final String? secondaryButtonText;
  final Color? secondaryColor;
  final Color? secondaryBorderColor;
  final double? secondaryHeight;
  final VoidCallback? onSecondaryButtonTap;

  const CommonSuccessDialog({
    Key? key,
    required this.image,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonTap,
    this.isCancel = false,
    this.extraContent,
    this.secondaryButtonText,
    this.secondaryColor,
    this.secondaryBorderColor,
    this.secondaryHeight,
    this.onSecondaryButtonTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Center(
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              image,
              const SizedBox(height: 24),
              Text(
                title,
                style: boldTextStyle(
                  fontSize: 24.0,
                  color: MyColors.blackColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
                textAlign: TextAlign.center,
              ),
              if (extraContent != null) ...[
                const SizedBox(height: 16),
                extraContent!,
              ],
              const SizedBox(height: 30),
              if (!isCancel) ...[
                CommonButton(
                  text: buttonText,
                  onTap: onButtonTap,
                  backgroundColor: MyColors.appTheme,
                ),
                if (secondaryButtonText != null) ...[
                   SizedBox(height: secondaryHeight??12.0),
                  CommonButton(
                    text: secondaryButtonText!,
                    onTap: onSecondaryButtonTap ?? () => Navigator.of(context).pop(),
                    backgroundColor: secondaryColor??Colors.white,
                    textColor: MyColors.blackColor,
                    borderColor:secondaryBorderColor?? MyColors.borderColor,
                  ),
                ],
              ]
            ],
          ),
        ),
      ),
    );
  }
} 