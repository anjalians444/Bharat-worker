import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/enums/register_enum.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';

class ProfileFormSection extends StatefulWidget {
  final ProfileProvider profileProvider;
  final LanguageProvider languageProvider;

  const ProfileFormSection({
    Key? key,
    required this.profileProvider,
    required this.languageProvider,
  }) : super(key: key);

  @override
  State<ProfileFormSection> createState() => _ProfileFormSectionState();
}

class _ProfileFormSectionState extends State<ProfileFormSection> {
  String LoginTypee = LoginType.typePhone.value;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.profileProvider.getProfileData();
    getLoginType();
  }
  getLoginType()async{
    LoginTypee = await  PreferencesServices.getPreferencesData(PreferencesServices.loginType);
    setState(() {});
    print("LoginTypee....$LoginTypee");
  }

  @override
  Widget build(BuildContext context) {
   // profileProvider.getProfileData();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        commonProfileImageSection(
          imageFile: widget.profileProvider.profileImage,
          onPickImage: () => widget.profileProvider.pickImage(context),
          errorText: widget.profileProvider.imageError,
          profileProvider: widget.profileProvider
        ),
        hsized30,
        commonSectionHeading(widget.languageProvider.translate('full_name')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            controller: widget.profileProvider.nameController,
            hintText: 'Enter name',
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
          ),
          errorText: widget.profileProvider.nameError,
        ),
        hsized18,
        commonSectionHeading(widget.languageProvider.translate('date_of_birth')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            controller: widget.profileProvider.dobController,
            hintText: 'MM-DD-YYYY',
            readOnly: true,
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
            suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () => widget.profileProvider.pickDate(context),
            ),
            onTap: () => widget.profileProvider.pickDate(context),
          ),
          errorText: widget.profileProvider.dobError,
        ),
        hsized18,
        commonSectionHeading(widget.languageProvider.translate('mobile_number')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            isEnable:LoginTypee == LoginType.loginTypeGoogle.value ?true:  false,
            controller: widget.profileProvider.mobileController,
            hintText: '+91 000 000 0000',
            keyboardType: TextInputType.phone,
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
          ),
          errorText: widget.profileProvider.mobileError,
        ),
        hsized18,
        commonSectionHeading(widget.languageProvider.translate('email')),
        hsized8,
        commonTextFieldSection(
          textField: CommonTextField(
            controller: widget.profileProvider.emailController,
            hintText: 'Enter email',
            isEnable:LoginTypee == LoginType.loginTypeGoogle.value ?false:  true,
            keyboardType: TextInputType.emailAddress,
            borderColor: MyColors.borderColor,
            focusedBorderColor: MyColors.appTheme,
          ),
          errorText: widget.profileProvider.emailError,
        ),
      ],
    );
  }
}