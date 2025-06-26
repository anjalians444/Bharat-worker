import 'package:bharat_worker/constants/sized_box.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';

class ProfileFormSection extends StatelessWidget {
  final ProfileProvider profileProvider;
  final LanguageProvider languageProvider;

  const ProfileFormSection({
    Key? key,
    required this.profileProvider,
    required this.languageProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonProfileImageSection(
          imageFile: profileProvider.profileImage,
          onPickImage: profileProvider.pickImage,
          errorText: profileProvider.imageError,
        ),
        hsized30,
        commonSectionHeading(languageProvider.translate('full_name')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            controller: profileProvider.nameController,
            hintText: 'Enter name',
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
          ),
          errorText: profileProvider.nameError,
        ),
        hsized18,
        commonSectionHeading(languageProvider.translate('date_of_birth')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            controller: profileProvider.dobController,
            hintText: 'DD-MM-YYYY',
            readOnly: true,
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => profileProvider.pickDate(context),
            ),
            onTap: () => profileProvider.pickDate(context),
          ),
          errorText: profileProvider.dobError,
        ),
        hsized18,
        commonSectionHeading(languageProvider.translate('mobile_number')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            controller: profileProvider.mobileController,
            hintText: '+91 000 000 0000',
            keyboardType: TextInputType.phone,
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
          ),
          errorText: profileProvider.mobileError,
        ),
        hsized18,
        commonSectionHeading(languageProvider.translate('email')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            controller: profileProvider.emailController,
            hintText: 'Enter email',
            keyboardType: TextInputType.emailAddress,
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
          ),
          errorText: profileProvider.emailError,
        ),
      ],
    );
  }
} 