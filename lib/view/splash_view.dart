import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/string_file.dart';
import '../view/languages_selection_view.dart';
import 'package:bharat_worker/provider/auth_provider.dart';
import 'package:bharat_worker/widgets/common_loader.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  bool _checkingLogin = true;

  @override
  void initState() {
    super.initState();
    _checkLoginAndNavigate();
  }

  Future<void> _checkLoginAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = await authProvider.checkLoginStatus();
    final token = await PreferencesServices.getPreferencesData(PreferencesServices.userToken)??null;
    final profilePendingScreens = await PreferencesServices.getPreferencesData(PreferencesServices.profilePendingScreens)??null;
   print("token...$token");
   print("profileCompletion...$profilePendingScreens");
    await Future.delayed(const Duration(seconds: 2)); // for splash effect
    if (isLoggedIn) {
     // if(profilePendingScreens == 0){
        context.go(AppRouter.dashboard);
     // }
      // else if(profilePendingScreens == 1){
      //   context.go(AppRouter.tellUsAbout);
      // }
      // else if(profilePendingScreens == 2){
      //
      //   context.go(AppRouter.allCategory,extra: {
      //     'isEdit': false,
      //   },);
      // }
      // else if(profilePendingScreens == 5){
      //   context.go(AppRouter.workAddress);
      // }
      // else if(profilePendingScreens == 6){
      //   context.go(AppRouter.documentUploadSection);
      // }

      // else{
      //   context.go(AppRouter.loginSignUp);
      // }

    } else {
      context.go(AppRouter.onBoarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(MyAssetsPaths.logo,height: 80,width: 80,),
                Text(languageProvider.translate('app_name'),style: boldTextStyle(fontSize: 40.0, color:MyColors.appTheme),)
              ],
            ),
          ),
          // Optionally show loader overlay
          // const CommonLoader(),
        ],
      ),
    );
  }
}
