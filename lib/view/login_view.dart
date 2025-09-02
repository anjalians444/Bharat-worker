import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/auth_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'dart:core';
import 'package:country_picker/country_picker.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar((){
        Navigator.of(context).pop();
      },""),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
               languageProvider.translate(authProvider.isLoginView == true?'welcomeToBharatWorker':'createAnAccount'),
                style: boldTextStyle(fontSize: 32.0, color: MyColors.blackColor),
              ),
              hsized12,
              Text(
                languageProvider.translate( authProvider.isLoginView == true?'welcome_subtitle':'createAccountDes'),
                style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
              ),
            hsized40,
              Text(
                languageProvider.translate('phone_number'),
                style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Consumer<AuthProvider>(builder: (context, provider, _) {
                      return InkWell(
                        onTap: provider.isLoading
                            ? null
                            : () {
                                showCountryPicker(
                                  context: context,
                                  showPhoneCode: true,
                                  onSelect: (country) {
                                    provider.setSelectedCountry(country);
                                  },
                                );
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Text(provider.selectedCountry?.flagEmoji ?? '🇮🇳', style: TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Text(
                                '+${provider.selectedCountry?.phoneCode ?? '91'}',
                                style: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.keyboard_arrow_down, color: Colors.black),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Consumer<AuthProvider>(builder: (context, provider, _) {
                        return TextFormField(
                          controller: provider.phoneController,
                          enabled: !provider.isLoading,
                          decoration: InputDecoration(
                            hintText: provider.selectedCountry?.example ?? '0000000000',
                            hintStyle: regularTextStyle(fontSize: 16.0, color: Colors.grey[400]),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            errorText: provider.phoneError,
                          ),
                          keyboardType: TextInputType.phone,
                          style: regularTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                          onChanged: (_) {
                            provider.setPhoneError(null);
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Consumer<AuthProvider>(builder: (context,provider,_){
                if (provider.isLoading) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return  CommonButton(
                  text: languageProvider.translate('log_in'),
                  onTap: () async {
                    final error = provider.validatePhone(provider.phoneController.text.trim());
                    provider.setPhoneError(error);
                    if (error == null) {
                      await provider.loginWithPhone(context).then((onValue){
                      //   if (provider.verificationId != null ) {
                      //
                      //   } else if (provider.firebaseErrorMsg != null) {
                      //     ScaffoldMessenger.of(context).showSnackBar(
                      //       SnackBar(content: Text(provider.firebaseErrorMsg!)),
                      //     );
                      //   }
                       });

                    }
                  },
                  backgroundColor: MyColors.appTheme,
                  textColor: Colors.white,
                  width: double.infinity,
                  margin: EdgeInsets.all(0),
                  isDisabled: provider.isLoading,
                );
              }),
              hsized28,
              Row(
                children: [
                  Expanded(
                      flex: 1,
                      child: Container(height: 1,color: MyColors.borderColor,)),

                  SizedBox(width: 8,),
                  Center(
                    child: Text(
                      languageProvider.translate('or_continue_with'),
                      style: regularTextStyle(fontSize: 16.0, color: Colors.grey[600]),
                    ),
                  ),

                  SizedBox(width: 8,),
                  Expanded(
                      flex: 1,
                      child: Container(height: 1,color: MyColors.borderColor,)),
                ],
              ),
              hsized28,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child:   Consumer<AuthProvider>(builder: (context,provider,_){
                    return _SocialIconButton(
                      icon: MyAssetsPaths.google,
                      label: languageProvider.translate('google'),
                      onTap: () => provider.isLoading? null: authProvider.loginWithGoogle(context),
                    );
                  })),

                  SizedBox(width: 10,),

                  Expanded(
                    child:Consumer<AuthProvider>(builder: (context,provider,_) {
                      return _SocialIconButton(
                        icon: MyAssetsPaths.facebook,
                        label: languageProvider.translate('facebook'),
                        onTap: () => provider.isLoading? null: authProvider.loginWithFacebook(context),
                      );
                    })),
                ],
              ),

              hsized16,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageProvider.translate('dont_have_account'),
                    style: regularTextStyle(fontSize: 14.0, color: Colors.grey[600]),
                  ),
                  TextButton(
                    onPressed: () {
                      authProvider.setLogin(authProvider.isLoginView == true?false:true);
                    },
                    child: Text(
                      languageProvider.translate(authProvider.isLoginView == true?'sign_up':'log_in'),
                      style: boldTextStyle(fontSize: 14.0, color: MyColors.appTheme),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
     /* bottomSheet:  Container(
        padding: EdgeInsets.only(bottom: 20),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              languageProvider.translate('dont_have_account'),
              style: regularTextStyle(fontSize: 14.0, color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: () {
               authProvider.setLogin(authProvider.isLoginView == true?false:true);
              },
              child: Text(
             languageProvider.translate(authProvider.isLoginView == true?'sign_up':'log_in'),
                style: boldTextStyle(fontSize: 14.0, color: MyColors.appTheme),
              ),
            ),
          ],
        ),
      ),*/
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const _SocialIconButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        // width: 150,
        // height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(56),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor),
            ),
          ],
        ),
      ),
    );
  }
} 