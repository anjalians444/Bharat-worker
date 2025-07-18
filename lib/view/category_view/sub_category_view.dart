import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/models/sub_category_model.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';

class SubCategoryView extends StatefulWidget {
  final List<String> selectedCategoryIds;
  final bool isEdit;

  const SubCategoryView({Key? key, required this.selectedCategoryIds, required this.isEdit}) : super(key: key);

  @override
  State<SubCategoryView> createState() => _SubCategoryViewState();
}

class _SubCategoryViewState extends State<SubCategoryView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero,(){
      Provider.of<CategoryProvider>(context, listen: false)
          .fetchSubCategories(context,widget.selectedCategoryIds);
    });

  }



  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final provider = Provider.of<CategoryProvider>(context);
    List<String> types = List.from(provider.categoryTypes)..sort();

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        leading: const BackButton(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body:  SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hsized10,
              Text(
                'Select Your Service Type',
                style: boldTextStyle(fontSize: 28.0, color: MyColors.blackColor),
              ),
              hsized8,
              Text(
                'Choose the type of service you specialize in. This helps us connect you with the right requests.',
                style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
              ),
              hsized20,
              Expanded(
                child: provider.subCategoryModel.data == null ?SizedBox.shrink():ListView.builder(
                  itemCount: provider.subCategoryModel.data!.servicesTypes!.length,
                  itemBuilder: (context, index) {
                    final category = provider.subCategoryModel.data!.servicesTypes![index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: MyColors.borderColor),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 23,
                                backgroundColor: MyColors.appTheme.withOpacity(0.04),
                                
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(5),
                                      child: Image.network(category.image.toString())),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  category.name.toString(),
                                  style: semiBoldTextStyle(
                                    fontSize:16.0,
                                    color: MyColors.darkText,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          Visibility(
                            visible: types.isNotEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(top:20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(types.length, (int i) {
                                  final String type = types[i];

                                  // ✅ Get subcategories for current category & type
                                  final List<dynamic> subList = category.toJson()[type] ?? [];

                                  if (subList.isEmpty) return const SizedBox.shrink();

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type[0].toUpperCase() + type.substring(1),
                                        style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.darkText),
                                      ),
                                      hsized8,
                                      Wrap(
                                        spacing:7,
                                        runSpacing:5,
                                        children: subList.map<Widget>((subJson) {
                                          final sub = Commercial.fromJson(subJson);
                                          final bool isSelected = provider.selectedSubCategoryIds.contains(sub.sId);
                                          return ChoiceChip(
                                            showCheckmark: false, // ✅ this removes the default check icon
                                            padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                                            label: Text(sub.name.toString(),style: regularTextStyle(fontSize:14.0, color:isSelected ? Colors.white : MyColors.color7A849C),),
                                            selected: isSelected,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8)
                                            ),
                                            selectedColor: MyColors.appTheme,
                                            backgroundColor: Colors.white,
                                            labelPadding: EdgeInsets.zero,
                                            labelStyle: regularTextStyle(
                                              fontSize: 14.0,
                                              color: isSelected ? Colors.white : MyColors.color7A849C,
                                            ),
                                            onSelected: (_) {
                                              provider.toggleSubCategorySelection(sub.sId.toString());
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      hsized16,
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              CommonButton(
                text:languageProvider.translate( widget.isEdit? "save_and_continue":'Next'),
                onTap: provider.selectedSubCategoryIds.isNotEmpty
                    ? () {
                  // 👇 Navigate or handle selected subcategories
                //  print('Selected subcategory IDs: ${provider.selectedSubCategoryIds}');
                  context.push(
                    AppRouter.experience,
                    extra: {
                      'selectedCategoryIds': provider.selectedCategoryIds,
                      'selectedSubCategoryIds': provider.selectedSubCategoryIds,
                      "isEdit":widget.isEdit
                    },
                  );
                }
                    : () {},
                backgroundColor: MyColors.appTheme,
                textColor: Colors.white,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(vertical: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
