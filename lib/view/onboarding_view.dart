import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/models/onboarding_model.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _currentPage = 0;



  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final screenSize = MediaQuery.of(context).size;
    
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Top category image
      
            Column(
              children: [
               SizedBox(height: screenSize.height * 0.05),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _OnboardingContent(
                      key: ValueKey(_currentPage),
                      model: pages[_currentPage],
                      currentPage: _currentPage,
                      languageProvider: languageProvider,
                    ),
                  ),
                ),
      
                _currentPage == pages.length - 1?
                CommonButton(
                  text: languageProvider.translate('get_started'),
                  onTap: () => context.go(AppRouter.loginSignUp),
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                ):
                InkWell(
                  onTap: (){
        setState(() {
                    _currentPage++;});
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 10),
                    height: 48,width: 48,
                    decoration: BoxDecoration(
                      color: MyColors.appTheme,
                      shape: BoxShape.circle
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.arrow_forward_ios,color: Colors.white,size: 24,),
                  ),
                ),
              ],
            ),
      
           /* Align(
              alignment: Alignment.center,
              child: Image.asset(
                MyAssetsPaths.topCategory,
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.9,
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final OnboardingModel model;
  final LanguageProvider languageProvider;
  final  int currentPage;

   _OnboardingContent({
    Key? key,
    required this.model,
    required this.languageProvider,
    required this.currentPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height:450,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                //  padding: EdgeInsets.only(top: 380),
                  child: Padding(
                    padding: const EdgeInsets.only(top:150.0),
                    child: Image.asset(
                      MyAssetsPaths.yellowCategory,
                      fit: BoxFit.contain,
                      width: MediaQuery.of(context).size.width ,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    model.imagePath,
                    width: MediaQuery.of(context).size.width,
                    height:500,
                    fit: BoxFit.cover,
                  ),
                ),
      
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(top:150.0),
                    child: Image.asset(
                      MyAssetsPaths.topCategory,
                      fit: BoxFit.contain,
                     // width: MediaQuery.of(context).size.width * 0.9,
                    ),
                  ),
                ),
      
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        pages.length,
                            (index) => Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentPage == index
                                ? MyColors.appTheme
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      
      
         // const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  languageProvider.translate(model.titleKey),
                  style: boldTextStyle(
                    fontSize: 24.0,
                    color: MyColors.blackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
               // const SizedBox(height: 16),
                Text(
                  languageProvider.translate(model.descriptionKey),
                  style: regularTextStyle(
                    fontSize: 16.0,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 