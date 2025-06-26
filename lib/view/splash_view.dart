import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/string_file.dart';
import '../view/languages_selection_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      context.go(AppRouter.onBoarding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
  //  final langCode = context.watch<LanguageProvider>().selectedLanguage;
    // Map language code to translation key (e.g., en -> en_US)
  //  String translationKey = langCode == 'en' ? 'en_US' : langCode == 'zh' ? 'zh_CN' : '${langCode}_IN';
   // final appName = context.watch<LanguageProvider>().translate('app_name');
    return  Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(MyAssetsPaths.logo,height: 80,width: 80,),
            Text(languageProvider.translate('app_name'),style: boldTextStyle(fontSize: 40.0, color:MyColors.appTheme),)
          ],
        ),
      ),
    );
  }
}
