import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/language_provider.dart';

class NotificationDetailView extends StatelessWidget {
  const NotificationDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar(
        () => Navigator.pop(context),
        languageProvider.translate('notifications'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hsized20,
            Text(languageProvider.translate('job_accepted_successfully'), style: semiBoldTextStyle(fontSize: 20.0, color: MyColors.blackColor)),
            hsized16,
            Text(languageProvider.translate('job_details'), style: semiBoldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),
            hsized10,
            RichText(
              text: TextSpan(
                style: regularTextStyle(fontSize: 15.0, color: MyColors.blackColor),
                children: [
                  TextSpan(text: languageProvider.translate('job_id')+': ', style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                  TextSpan(text: '#1023\n',style: regularTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                  TextSpan(text: languageProvider.translate('category')+': ', style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                  TextSpan(text: languageProvider.translate('ac_service')+'\n',style: regularTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                  TextSpan(text: languageProvider.translate('date_time')+': ', style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                  TextSpan(text: '15 June 2025, 3:00 PM\n',style: regularTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                  TextSpan(text: languageProvider.translate('location')+': ', style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                  TextSpan(text: 'Sector 22, Chandigarh',style: regularTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                ],
              ),
            ),
            hsized16,
            Text(
              languageProvider.translate('job_accept_success_msg'),
              style: regularTextStyle(fontSize: 15.0, color: MyColors.darkText),
            ),
            hsized16,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BulletText(text: languageProvider.translate('ac_balcony')),
                BulletText(text: languageProvider.translate('bring_ladder_kit')),
                BulletText(text: languageProvider.translate('call_before_arriving')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;
  const BulletText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom:2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text('• ', style: regularTextStyle(fontSize: 14.0, color: MyColors.darkText)),
          Expanded(child: Text(text, style: regularTextStyle(fontSize: 14.0, color: MyColors.darkText))),
        ],
      ),
    );
  }
} 