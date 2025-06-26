import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginSignUpView extends StatelessWidget {
  const LoginSignUpView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
          //  mainAxisAlignment: MainAxisAlignment.center,
            children: [
              hsized50,
              hsized50,


              SvgPicture.asset(
                MyAssetsPaths.logo,
                width: 100,
                height: 100,
              ),
             hsized8,
              Text(
                languageProvider.translate('lets_you_in'),
                style: boldTextStyle(fontSize:40.0, color: MyColors.blackColor),
              ),
              const SizedBox(height: 32),
              _SocialButton(
                icon: MyAssetsPaths.google,
                text: languageProvider.translate('continue_with_google'),
                onTap: () => authProvider.loginWithGoogle(context),
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              _SocialButton(
                icon: MyAssetsPaths.facebook,
                text: languageProvider.translate('continue_with_facebook'),
                onTap: () => authProvider.loginWithFacebook(context),
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              _SocialButton(
                icon: MyAssetsPaths.phone,
                text: languageProvider.translate('continue_with_number'),
                onTap: () => context.push(AppRouter.login),
                color: MyColors.appTheme,
                textColor: Colors.white,
              ),
              const SizedBox(height: 32),

            ],
          ),
        ),
      ),
      bottomSheet:    Container(
        padding: EdgeInsets.only(bottom: 20),
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              languageProvider.translate('already_have_account'),
              style: regularTextStyle(fontSize: 14.0, color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: () {
                authProvider.setLogin(true);
                 context.push(AppRouter.login);
              },
              child: Text(
                languageProvider.translate('log_in'),
                style: boldTextStyle(fontSize: 14.0, color: MyColors.appTheme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final dynamic icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _SocialButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onTap,
    required this.color,
     this.textColor = Colors.black
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        width: double.infinity,
        //height: 56,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon is String)
              SvgPicture.asset(
                icon,
                width: 24,
                height: 24,
              )
            else if (icon is IconData)
              Icon(
                icon,
                size: 24,
                color: MyColors.blackColor,
              ),
            const SizedBox(width: 8),
            Text(
              text,
              style: semiBoldTextStyle(fontSize: 16.0, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
} 