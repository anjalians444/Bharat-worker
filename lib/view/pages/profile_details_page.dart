import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/quiz_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final quizProvider = Provider.of<QuizProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar((){
        Navigator.of(context).pop();
      }, languageProvider.translate('profile_settings'),
        actions: [
          InkWell(
            child:  Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: MyColors.borderColor),
                    borderRadius: BorderRadius.circular(12)
                ),
                padding: EdgeInsets.all(10),
                child: Icon(Icons.mode_edit_outlined, color: Colors.black,size:24,)),
            onTap: () {
              context.push(AppRouter.editProfile);
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hsized25,
              if (profileProvider.isProfileComplete && !quizProvider.submitted) ...[
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: MyColors.whiteColor,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: MyColors.borderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonSectionHeading(languageProvider.translate('youre_ready_enjoy')),
                      hsized2,
                      Text(
                        languageProvider.translate('profile_100_complete'),
                        style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                      ),
                    ],
                  ),
                ),
              ],
              // Profile completion bar1
        if (!profileProvider.isProfileComplete && !quizProvider.submitted) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColors.whiteColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: MyColors.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: profileProvider.profileCompletionPercent,
                            backgroundColor: MyColors.borderColor,
                            borderRadius: BorderRadius.circular(10),
                            valueColor: AlwaysStoppedAnimation<Color>(MyColors.appTheme),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                    hsized12,
                    Text(
                      profileProvider.profileCompletionText,
                      style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                    ),
                    hsized2,
                    Text(
                      profileProvider.profileCompletionSubtext,
                      style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                    ),
                  ],
                ),
              ),

          hsized25,
              ],


              // Profile section

              Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: NetworkImage(profileProvider.profileImageUrl),
                        backgroundColor: Colors.grey[200],
                      ),

                      quizProvider.submitted?
                      Align(
                        alignment: Alignment.bottomRight,
                        child: SvgPicture.asset(MyAssetsPaths.badge),
                      ):SizedBox.shrink()
                    ],
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profileProvider.profileName,
                        style: boldTextStyle(fontSize: 20.0, color: MyColors.blackColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profileProvider.profilePhone,
                        style: regularNormalTextStyle(fontSize: 13.0, color: MyColors.color7D7D7D),
                      ),
                      quizProvider.submitted == true?
                      Container(
                        margin: EdgeInsets.only(top: 6),
                        decoration: BoxDecoration(
                          color: MyColors.appTheme,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.thumb_up,color: Colors.white,size: 16,),
                            SizedBox(width: 4,),
                            Text(
                             "80%",
                              style: semiBoldTextStyle(fontSize: 12.0, color: MyColors.whiteColor),
                            ),

                            SizedBox(width: 4,),
                            Icon(Icons.arrow_forward_ios_outlined,color: Colors.white,size: 16,),
                          ],
                        ),
                      ):SizedBox.shrink()
                    ],
                  ),
                ],
              ),
              if (!profileProvider.isProfileComplete && !quizProvider.submitted) ...[
                hsized10,
                Text(
                    languageProvider.translate('please_review_details'),
                    style: regularTextStyle(fontSize: 14.0, color: MyColors.appTheme)
                ),
              ],

              hsized25,
              // Professional Info section
              if (profileProvider.isProfileComplete) ...[
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      commonSectionHeading(languageProvider.translate('professional_info')),
                      hsized10,
                      Row(
                        children: [
                          Expanded(
                            child: profileInfoCard(
                              value: '3 years', // Replace with provider value if needed
                              label: languageProvider.translate('experience'),
                              iconPath: MyAssetsPaths.briefcase,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: profileInfoCard(
                              value: '4.9', // Replace with provider value if needed
                              label: languageProvider.translate('rating'),
                              iconPath: MyAssetsPaths.star,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Professional Information
              commonSectionHeading(languageProvider.translate('professional_information')),
              hsized10,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColors.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MyColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(languageProvider.translate('service_categories'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                    hsized8,
                    Wrap(
                      spacing: 12,
                      children: profileProvider.serviceCategories.map((cat) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: MyColors.appTheme, size: 18),
                          const SizedBox(width: 4),
                          Text(cat, style:regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                        ],
                      )).toList(),
                    ),
                    hsized16,
                    Divider(color: MyColors.color7A849C,thickness:0.5,),

                    hsized16,
                    Text(languageProvider.translate('availability'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                    hsized8,
                    Text(profileProvider.availabilityDays, style: regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                    hsized8,
                    Text(profileProvider.availabilityTime, style: regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                  ],
                ),
              ),
              hsized25,
              // Service Area
              commonSectionHeading(languageProvider.translate('service_area')),
              hsized10,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColors.whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MyColors.borderColor, style: BorderStyle.solid, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageProvider.translate('location'), style:mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        hsized5,
                        Text(profileProvider.location, style: regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                      ],
                    ),
                    hsized16,
                    Divider(color: MyColors.color7A849C,thickness:0.5,),
                    hsized16,

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageProvider.translate('service_range'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        hsized5,
                        Text(profileProvider.serviceRange, style:regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C)),
                      ],
                    ),
                  ],
                ),
              ),
              hsized50,

            ],
          ),
        ),
      ),
      bottomSheet: Wrap(
        children: [
          Container(
            color: Colors.white,
              padding: EdgeInsets.only(bottom: 10),
              child: CommonButton(text: languageProvider.translate('submit_for_approval'), onTap: () {  },)),
        ],
      ),
    );
  }
} 