import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/category_selection_widget.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AllCategoryView extends StatefulWidget {
  final bool isEdit;
  const AllCategoryView({Key? key, required this.isEdit}) : super(key: key);

  @override
  State<AllCategoryView> createState() => _AllCategoryViewState();
}

class _AllCategoryViewState extends State<AllCategoryView> {
  @override
  void initState() {
    super.initState();
    // Clear selections if not in edit mode
    if (!widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);
        categoryProvider.clearSelections();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        Navigator.of(context).pop();
      }, isLeading: widget.isEdit, ""),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hsized10,
              Text(
                languageProvider.translate('what_services_offer'),
                style:
                    boldTextStyle(fontSize: 32.0, color: MyColors.blackColor),
              ),
              hsized10,
              Text(
                languageProvider.translate('choose_categories_skilled'),
                style:
                    regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
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
      bottomNavigationBar: Wrap(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 10, left: 20, right: 20, top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonButton(
                  text: languageProvider.translate('next'),
                  onTap: categoryProvider.selectedCategoryIds.isEmpty
                      ? () {
                          customToast(context, "Please select category");
                        }
                      : () {
                          context.push(
                            AppRouter.subCategory,
                            extra: {
                              "selectedCategoryIds":
                                  categoryProvider.selectedCategoryIds,
                              'isEdit': widget.isEdit,
                            },
                          );
                          // extra: categoryProvider.selectedCategoryIds,
                          // context.push(AppRouter.workAddress);
                        },
                  backgroundColor: MyColors.appTheme,
                  textColor: Colors.white,
                  width: double.infinity,
                  margin: const EdgeInsets.all(0),
                  isDisabled: categoryProvider.selectedCategoryIds.isEmpty &&
                      categoryProvider.otherController.text.trim().isEmpty,
                ),
                // if(!isEdit)
                //   hsized20,
                // if(!isEdit)
                //   Center(
                //     child: InkWell(
                //             onTap:  (){
                //       context.go(AppRouter.workAddress);
                //     },
                //         child: Text(languageProvider.translate('skip'),style: semiBoldTextStyle(color:MyColors.greyColor,fontSize: 14.0),)),
                //   )
                // CommonButton(
                //   text: languageProvider.translate('skip'),
                //   onTap:  (){
                //     context.go(AppRouter.workAddress);
                //   },
                //   backgroundColor: MyColors.lightGreyColor,
                //   textColor: Colors.black,
                //   width: double.infinity,
                //   margin: EdgeInsets.all(0),
                // ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
