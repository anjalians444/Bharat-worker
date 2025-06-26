import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid/responsive_grid.dart';

class CategorySelectionWidget extends StatelessWidget {
  const CategorySelectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final categoryProvider = Provider.of<CategoryProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: MyColors.borderColor),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: Icon(Icons.search, color: MyColors.lightText),
              ),
              Expanded(
                child: TextField(
                  controller: categoryProvider.searchController,
                  style:
                      regularTextStyle(fontSize: 14.0, color: MyColors.blackColor),
                  decoration: InputDecoration(
                    hintText: languageProvider.translate('search_service_hint'),
                    hintStyle:
                        regularTextStyle(fontSize: 12.0, color: MyColors.lightText),
                    border: InputBorder.none,
                  ),
                  onChanged: categoryProvider.setSearch,
                ),
              ),
            ],
          ),
        ),
        hsized25,
        ResponsiveGridRow(
            children:
                List.generate(categoryProvider.categories.length, (int index) {
          final cat = categoryProvider.categories[index];
          final isSelected = categoryProvider.selectedIndexes.contains(index);
          return ResponsiveGridCol(
            xs: 4,
            md: 3,
            child: GestureDetector(
              onTap: () => categoryProvider.toggleCategory(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: MyColors.appTheme.withOpacity(0.10),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? MyColors.appTheme
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(cat["icon"].toString(),
                          color: MyColors.appTheme, width: 32, height: 32),
                    ),
                    hsized16,
                    Text(
                      languageProvider.translate(cat["key"]),
                      style: semiBoldTextStyle(
                          fontSize: 16.0, color: MyColors.darkText),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        })),
        hsized8,
        Text(
          languageProvider.translate('others'),
          style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
        ),
        hsized8,
        CommonTextField(
            controller: categoryProvider.otherController,
            hintText: languageProvider.translate('enter_other_service'),
            onChanged: categoryProvider.setOther),
        hsized40,

      ],
    );
  }
} 