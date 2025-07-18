import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/category_selection_widget.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AllCategoryView extends StatelessWidget {
  final bool isEdit;
  const AllCategoryView({super.key,required this.isEdit});




  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        Navigator.of(context).pop();
      }, ""),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hsized10,
              Text(
                languageProvider.translate('what_services_offer'),
                style: boldTextStyle(fontSize: 32.0, color: MyColors.blackColor),
              ),
              hsized10,
              Text(
                languageProvider.translate('choose_categories_skilled'),
                style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
              ),
              hsized25,
              if (categoryProvider.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (categoryProvider.errorMessage != null)
                Center(child: Text(categoryProvider.errorMessage!))
              else
              const CategorySelectionWidget(),


              hsized20,
            ],
          ),
        ),

      ),
      bottomNavigationBar:  Wrap(
    children: [
    Padding(padding: EdgeInsets.only(bottom:16,left: 20,right: 20,top: 10),
    child:   CommonButton(
    text: languageProvider.translate('next'),
    onTap: categoryProvider.selectedCategoryIds.isEmpty && categoryProvider.otherController.text.trim().isEmpty?(){}:() {
    context.push(AppRouter.subCategory,
      extra: {
      "selectedCategoryIds":  categoryProvider.selectedCategoryIds,
        'isEdit': isEdit,
      },);
    // extra: categoryProvider.selectedCategoryIds,
    // context.push(AppRouter.workAddress);
    },
    backgroundColor: MyColors.appTheme,
    textColor: Colors.white,
    width: double.infinity,
    margin: const EdgeInsets.all(0),
    isDisabled: categoryProvider.selectedCategoryIds.isEmpty && categoryProvider.otherController.text.trim().isEmpty,
    ),)
    ],
    ),
    );
  }
}