import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
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
    Future.delayed(Duration.zero, () async {
      await Provider.of<CategoryProvider>(context, listen: false)
          .fetchSubCategories(context, widget.selectedCategoryIds,widget.isEdit);


    });
  }



  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final provider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        // leadingWidth:widget.isEdit? t,
        automaticallyImplyLeading: widget.isEdit,
        leading: widget.isEdit? const BackButton(color: Colors.black):null,
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
                child: provider.subCategoryModel.data == null || provider.subCategoryModel.data!.services == null || provider.subCategoryModel.data!.services!.isEmpty
                    ? Center(
                  child: Text("No services type",style: mediumTextStyle(fontSize:14.0, color:MyColors.color838383),),
                )
                    : ListView.builder(
                        itemCount: provider.subCategoryModel.data!.services!.length,
                        itemBuilder: (context, index) {
                          final service = provider.subCategoryModel.data!.services![index];

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
                                            child: Image.network(service.image.toString())),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        service.categoryName.toString(),
                                        style: semiBoldTextStyle(
                                          fontSize:16.0,
                                          color: MyColors.darkText,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                Visibility(
                                  visible: service.categorytypes != null && service.categorytypes!.isNotEmpty,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top:20.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: service.categorytypes!.map<Widget>((categoryType) {
                                        if (categoryType.services == null || categoryType.services!.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              categoryType.categoryTypeName.toString(),
                                              style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.darkText),
                                            ),
                                            hsized8,
                                            Wrap(
                                              spacing:7,
                                              runSpacing:5,
                                              children: categoryType.services!.map<Widget>((serviceItem) {
                                                final bool isSelected = provider.selectedSubCategoryIds.contains(serviceItem.sId);
                                                return ChoiceChip(
                                                  showCheckmark: false,
                                                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                                                  label: Text(serviceItem.name.toString(),style: regularTextStyle(fontSize:14.0, color:isSelected ? Colors.white : MyColors.color7A849C),),
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
                                                    print("serviceItem.sId.toString()...${serviceItem.sId.toString()}");
                                                    provider.toggleSubCategorySelection(serviceItem.sId.toString());
                                                  },
                                                );
                                              }).toList(),
                                            ),
                                            hsized16,
                                          ],
                                        );
                                      }).toList(),
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
                onTap:  () {
                  // 👇 Navigate or handle selected subcategories
                //  print('Selected subcategory IDs: ${provider.selectedSubCategoryIds}');
                  if(provider.selectedSubCategoryIds.isEmpty){
                    customToast(context, "Please select service");
                  }else{
                    context.push(
                      AppRouter.experience,
                      extra: {
                        'selectedCategoryIds': provider.selectedCategoryIds,
                        'selectedSubCategoryIds': provider.selectedSubCategoryIds,
                        "isEdit":widget.isEdit
                      },
                    );
                  }

                }
                   ,
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
