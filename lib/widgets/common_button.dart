import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? width;
  final bool isDisabled;

  const CommonButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.fontSize,
    this.padding,
    this.margin,
    this.borderRadius,
    this.width,
    this.isDisabled = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.only(left: 16.0,right: 16,bottom: 16),
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(borderRadius ?? 100),
        child: Container(
          width: width ?? double.infinity,
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey[300]
                : backgroundColor ?? MyColors.appTheme,
            border: Border.all(color: borderColor??Colors.transparent),
            borderRadius: BorderRadius.circular(borderRadius ?? 100)
          ),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
          alignment: Alignment.center,
          child: Text(
            text,
            style: boldTextStyle(
              fontSize: fontSize ?? 16.0,
              color: isDisabled
                  ? Colors.grey[500]
                  : textColor ?? Colors.white
            ),
          ),
        ),
      ),
    );
  }
} 