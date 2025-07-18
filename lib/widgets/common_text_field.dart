import 'package:bharat_worker/constants/font_style.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/my_colors.dart';

class CommonTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool readOnly;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? contentPadding;
  final double borderRadius;
  final Color borderColor;
  final Color focusedBorderColor;
  final double borderWidth;
  final double focusedBorderWidth;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final TextStyle? style;
  final bool isEnable;
final  Function(String value)? onChanged;
  final String? errorText;
  const CommonTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.readOnly = false,
    this.suffixIcon,
    this.prefixIcon,
    this.onTap,
    this.contentPadding,
    this.borderRadius = 12,
    this.borderColor = MyColors.borderColor,
    this.focusedBorderColor = MyColors.appTheme,
    this.borderWidth = 1,
    this.focusedBorderWidth = 1.5,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.style,
    this.onChanged,
    this.isEnable = true,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: isEnable,
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: (String value){
        if(onChanged != null){
          onChanged!(value);
        }
      },
      obscureText: obscureText,
      maxLines: maxLines,
      minLines: minLines,
      style: regularTextStyle(fontSize: 14.0, color:MyColors.darkText),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: regularTextStyle(fontSize: 14.0, color:MyColors.lightText),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: borderColor, width: borderWidth),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: focusedBorderColor, width: focusedBorderWidth),
        ),
        contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffixIcon,
        prefixIcon: prefixIcon,
        errorText: errorText,
      ),
    );
  }
} 