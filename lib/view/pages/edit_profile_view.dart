import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/work_address_provider.dart';
import 'package:bharat_worker/view/widgets/document_upload_section.dart';
import 'package:bharat_worker/widgets/category_selection_widget.dart';
import 'package:bharat_worker/widgets/common_address_form.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/profile_form_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditProfileView extends StatefulWidget {
  const EditProfileView({Key? key}) : super(key: key);

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:commonAppBar((){
        Navigator.of(context).pop();
      },  languageProvider.translate('edit_profile'),
       ),
      body: Column(
        children: [
          hsized25,
          TabBar(
            controller: _tabController,
           // isScrollable: true,
            labelPadding: EdgeInsets.symmetric(horizontal:4.0), // Gap kam karne ke liye
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
            labelStyle: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor),
            unselectedLabelStyle: mediumTextStyle(fontSize: 16.0, color: MyColors.color838383),
            tabs: [
              Tab(text: languageProvider.translate('general')),
              Tab(text: languageProvider.translate('service')),
              Tab(text: languageProvider.translate('location')),
              Tab(text: languageProvider.translate('document')),
            ],
          ),

          hsized25,
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // General Tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: ProfileFormSection(
                    profileProvider: profileProvider,
                    languageProvider: languageProvider,
                  ),
                ),

                // Service Tab
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const CategorySelectionWidget(),
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
                    child: DocumentUploadSection(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomSheet: Wrap(
        children: [
          Container(
              color: Colors.white,
              padding: EdgeInsets.only(bottom: 10),
              child: CommonButton(
                text: languageProvider.translate('save_and_continue'),
                onTap: () {
                  if (!profileProvider.isProfileComplete) {
                    profileProvider.profileCompletionPercent = 1.0;
                  }
                  Navigator.pop(context);
                },
              ),
          ),
        ],
      ),
    );
  }
} 