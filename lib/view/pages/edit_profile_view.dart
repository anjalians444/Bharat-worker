import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/work_address_provider.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/view/widgets/document_upload_section.dart';
import 'package:bharat_worker/widgets/category_selection_widget.dart';
import 'package:bharat_worker/widgets/common_address_form.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/profile_form_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    // Set selected categories from profile after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
      final workAddressProvider = Provider.of<WorkAddressProvider>(context, listen: false);
      categoryProvider.fetchCategories();
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.getProfileData();
      Future.delayed(Duration.zero,(){
        profileProvider.getProfile();
      });


      final partner = profileProvider.partner;
      if (partner != null) {
        workAddressProvider.setInitialAddressFromPartner(partner);
      }
      final partnerCategories = profileProvider.partner?.category;
      final partnerSubCategories = profileProvider.partner?.services;
      // print("partnerCategories....${partnerCategories}");
      if (partnerCategories != null && partnerCategories.isNotEmpty) {
        categoryProvider.selectedCategoryIds.clear();
        // Only set if not already set (to avoid overwriting user changes)
        if (categoryProvider.selectedCategoryIds.isEmpty) {
          for(var c in partnerCategories){
            print("c.id...${c.id}");
            if (!categoryProvider.selectedCategoryIds.contains(c.id)) {
              categoryProvider.selectedCategoryIds.add(c.id.toString());
            }
          }
        }
        if(partnerSubCategories != null && partnerSubCategories.isNotEmpty){
          for(var s in partnerSubCategories!){
            print("s.id...${s.id}");
            if (!categoryProvider.selectedSubCategoryIds.contains(s.id)) {
              categoryProvider.selectedSubCategoryIds.add(s.id.toString());
            }
          }
        }
      }

    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final workAddressProvider = Provider.of<WorkAddressProvider>(context);
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(
        () {
          Navigator.of(context).pop();
        },
        languageProvider.translate('edit_profile'),
      ),
      body: Column(
        children: [
          hsized25,
          Padding(
            padding: const EdgeInsets.only(right: 20.0, left: 0),
            child: TabBar(
              controller: _tabController,
            //   isScrollable: true,
              labelPadding: EdgeInsets.symmetric(horizontal: 2.0),
              // Gap kam karne ke liye
              labelColor: MyColors.appTheme,
              unselectedLabelColor: MyColors.color7D7D7D,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  width: 2.5,
                  color: MyColors.appTheme,
                ),
                insets: EdgeInsets.symmetric(horizontal: -12.0),
              ),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle:
                  mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor),
              unselectedLabelStyle:
                  mediumTextStyle(fontSize: 16.0, color: MyColors.color838383),
              tabs: [
                Tab(text: languageProvider.translate('general')),
                Tab(text: languageProvider.translate('service')),
                Tab(text: languageProvider.translate('location')),
                Tab(text: languageProvider.translate('document')),
              ],
            ),
          ),
          hsized25,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // General Tab
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        ProfileFormSection(
                          profileProvider: profileProvider,
                          languageProvider: languageProvider,
                        ),
                        hsized100,
                      ],
                    ),
                  ),
                ),

                // Service Tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        CategorySelectionWidget(),
                        hsized60,
                      ],
                    ),
                  ),
                ),

                // Location Tab
                CommonAddressForm(
                  workAddressProvider: workAddressProvider,
                  languageProvider: languageProvider,
                  padding: EdgeInsets.symmetric(horizontal: 20),
                ),

                // Document Tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        DocumentUploadSection(
                          partner: profileProvider.partner,
                        ),
                        hsized100,
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Wrap(
        children: [
          // Padding(
          //   padding: EdgeInsets.only(
          //     bottom: MediaQuery.of(context).viewInsets.bottom + 10,
          //   ),
          CommonButton(
            text: languageProvider.translate('save_and_continue'),
            onTap: () async {
              FocusScope.of(context).unfocus(); // <-- Add this line
              if (_tabController.index == 0) {

                final success = await profileProvider.updateProfile(context,true);
                if (success.success == true) {
                  profileProvider.getProfileData();
                }
              } else if (_tabController.index == 1) {
                if(categoryProvider.selectedCategoryIds.isEmpty){
                  customToast(context, "Please select category");
                }else{
                  context.push(
                    AppRouter.subCategory,
                    extra: {
                      "selectedCategoryIds": categoryProvider.selectedCategoryIds,
                      'isEdit': true,
                    },
                    //  extra: categoryProvider.selectedCategoryIds
                  );
                }

              } else if (_tabController.index == 2) {
                    await workAddressProvider.workLocationUpdate(context,true).then((onValue){
                      profileProvider.getProfileData();
                    });
               }
              else if (_tabController.index == 3) {
                profileProvider.unfocusf(context);
                // if (!profileProvider.validateDocumentUpload( context,true)) {
                //   return;
                // }

                final success = await profileProvider.uploadPartnerDocuments(
                  context: context,
                  selectedIdType: profileProvider.selectedIdType,
                  idNumber: profileProvider.idController.text.trim(),
                   isEdit:  true
                );
                if(success){
                  profileProvider.getProfileData();
                }

              }
            },
          ),
        ],
      ),
    );
  }
}
