import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/provider/auth_provider.dart';
import 'package:bharat_worker/helper/common.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/widgets/profile_form_section.dart';

class TellUsAboutView extends StatefulWidget {
  const TellUsAboutView({Key? key}) : super(key: key);

  @override
  State<TellUsAboutView> createState() => _TellUsAboutViewState();
}

class _TellUsAboutViewState extends State<TellUsAboutView> {
  @override
  void dispose() {
    Provider.of<ProfileProvider>(context, listen: false).dispose();
    super.dispose();
  }

  void _onNext(ProfileProvider profileProvider) {
    if (!profileProvider.validate()) {
      return;
    }
    context.push(AppRouter.allCategory);
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        Navigator.of(context).pop();
      }, ""),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hsized5,
              Text(
                languageProvider.translate('tell_us_about_you'),
                style: boldTextStyle(fontSize: 32.0, color: MyColors.blackColor),
              ),
              hsized10,
              Text(
                languageProvider.translate('help_customers_know'),
                style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
              ),
              hsized30,
              ProfileFormSection(
                profileProvider: profileProvider,
                languageProvider: languageProvider,
              ),
              hsized40,
              CommonButton(
                text: languageProvider.translate('next'),
                onTap: () => _onNext(profileProvider),
                backgroundColor: MyColors.appTheme,
                textColor: Colors.white,
                width: double.infinity,
                margin: EdgeInsets.all(0),
              ),
              hsized20,
            ],
          ),
        ),
      ),
    );
  }
} 