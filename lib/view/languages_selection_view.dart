import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/string_file.dart';
import '../widgets/common_button.dart';

class LanguagesSelectionView extends StatelessWidget {
  const LanguagesSelectionView({Key? key}) : super(key: key);

  String _getCountryCode(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'US';
      case 'zh':
        return 'CN';
      default:
        return 'IN'; // Default country code for Indian languages
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final selectedLanguage = languageProvider.locale.languageCode;
    return Scaffold(
      appBar: commonAppBar((){ Navigator.of(context).pop();},languageProvider.translate('language')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              itemCount: supportedLanguages.length,
              itemBuilder: (context, index) {
                final lang = supportedLanguages[index];
                final langCode = lang['code']!;
                return InkWell(
                  radius: 30,
                  splashColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(80),

                  onTap: () {
                    final countryCode = _getCountryCode(langCode);
                    context.read<LanguageProvider>().setLocale(Locale(langCode, countryCode));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: MyColors.borderColor,width: 1)
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.symmetric(horizontal: 16,vertical: 15),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(lang['name'] ?? '',style: regularTextStyle(fontSize:14.0, color:MyColors.blackColor),),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: langCode == selectedLanguage ? Colors.transparent : Colors.grey,
                              width: 1,
                            ),
                            color:langCode == selectedLanguage ? Colors.transparent: Colors.white,
                          ),
                          child: langCode == selectedLanguage
                              ? Center(
                                  child: Icon(Icons.check_circle,color:MyColors.appTheme,),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          CommonButton(
            text: 'Continue',
            onTap: () => context.go(AppRouter.onBoarding),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
