import 'dart:io';
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/helper/utility.dart';
import 'package:bharat_worker/models/profile_model.dart';
import 'package:bharat_worker/models/sub_category_model.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/services/api_paths.dart';
import 'package:bharat_worker/services/api_service.dart';
import 'dart:io' as http;

class ExperienceView extends StatefulWidget {
  final List<String> selectedCategoryIds;
  final List<String> selectedSubCategoryIds;
  final bool isEdit;
  const ExperienceView({Key? key, required this.selectedCategoryIds, required this.selectedSubCategoryIds, required this.isEdit}) : super(key: key);

  @override
  State<ExperienceView> createState() => _ExperienceViewState();
}

class _ExperienceViewState extends State<ExperienceView> {
  // Map to hold experience and image for each subcategory
  // final Map<String, TextEditingController> _experienceControllers = {};
  final Map<String, int?> _selectedYearExperience = {}; // subId -> year value
  final Map<String, File?> _certificateImages = {}; // subId -> local file
  final Map<String, String?> _certificateImageUrls = {}; // subId -> network url
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prefillIfEdit();
  }

  Future<void> _prefillIfEdit() async {
    if (widget.isEdit) {
      final profile = await PreferencesServices.getProfileData();
      final partner = profile?.data?.partner;
      final skills = partner?.skills ?? [];
      final provider = Provider.of<CategoryProvider>(context, listen: false);
      final subCategoryModel = provider.subCategoryModel.data;
      final List<ServicesTypes> allServices = subCategoryModel?.servicesTypes ?? [];
      // All subcategories (flat list)
      final List<Commercial> allSubs = [
        for (final s in allServices)
          ...((s.commercial ?? []) + (s.industrial ?? []) + (s.residential ?? []))
      ];

      print('DEBUG: selectedSubCategoryIds: ' + widget.selectedSubCategoryIds.toString());
      print('DEBUG: skills: ' + skills.map((e) => 'skill: \'${e.skill}\', year: ${e.yearOfExprence}, cert: ${e.experienceCertificates}').toList().toString());

      for (final skill in skills) {
        // Find subcategory by name
        final match = allSubs.firstWhere(
          (sub) => sub.name == skill.skill,
          orElse: () => Commercial(),
        );
        final subId = match.sId;
        print('DEBUG: skill.skill=${skill.skill}, matched subId=$subId');
        if (subId != null && widget.selectedSubCategoryIds.contains(subId)) {
          _selectedYearExperience[subId] = skill.yearOfExprence;
          if (skill.experienceCertificates != null && skill.experienceCertificates!.isNotEmpty) {
            _certificateImageUrls[subId] = skill.experienceCertificates;
          }
        }
      }
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    // _experienceControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  Future<void> _pickImage(String subId) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _certificateImages[subId] = File(picked.path);
        _certificateImageUrls.remove(subId); // Remove network image if replaced
      });
    }
  }

  Future<void> _submitSkills() async {
    ProfileResponse profileResponse = ProfileResponse();
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });
    progressLoadingDialog(context,true);
    try {
      final List<String> skills = widget.selectedSubCategoryIds;
      final List<int> yearOfExprence = skills.map((id) {
        return _selectedYearExperience[id] ?? 0;
      }).toList();
      final provider = Provider.of<CategoryProvider>(context, listen: false);

      final response = await provider.submitPartnerSkills(
        context: context,
        skills: skills,
        yearOfExprence: yearOfExprence,
        certificateImages: _certificateImages,
      );
      if (mounted) {
        progressLoadingDialog(context,false);
        setState(() {
          _isLoading = false;
        });
        if(response != null){
          profileResponse = ProfileResponse.fromJson(response);
          if (response != null && response['success'] == true) {
            customToast(context, response['message'].toString());
            PreferencesServices.setPreferencesData(PreferencesServices.profilePendingScreens, profileResponse.data!.partner!.profilePendingScreens);
            await PreferencesServices.saveProfileData(profileResponse);
            if(!widget.isEdit){
              if(profileResponse.data!.partner!.profilePendingScreens == 5){
                context.go(AppRouter.workAddress);
              }
            }else{
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => CommonSuccessDialog(
                  image:SvgPicture.asset(MyAssetsPaths.certified,height: 132,width: 132,),
                  title: "You're Now a Certified Partner!",
                  subtitle: "You can now access more job requests and earn trust faster.",
                  buttonText: "Ok",
                  onButtonTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  //  context.go(AppRouter.dashboard);
                  },
                ),
              );
            }


          }
          else {
          customToast(context, response['message'].toString());
          }
        }


      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      progressLoadingDialog(context,false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ' + e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final provider = Provider.of<CategoryProvider>(context);
    final subCategoryModel = provider.subCategoryModel.data;
    final List<ServicesTypes> allServices = subCategoryModel?.servicesTypes ?? [];
    final yearExperiences = provider.yearExperiences;
    final isYearExperienceLoading = provider.isYearExperienceLoading;

    // Map: categoryId -> {category: ServicesTypes, subcategories: List<Commercial>}
    final Map<String, Map<String, dynamic>> grouped = {};
    for (final service in allServices) {
      final List<Commercial> selectedSubs = [];
      for (final typeList in [service.commercial, service.industrial, service.residential]) {
        if (typeList != null) {
          for (final sub in typeList) {
            if (widget.selectedSubCategoryIds.contains(sub.sId)) {
              selectedSubs.add(sub);
            }
          }
        }
      }
      if (selectedSubs.isNotEmpty) {
        grouped[service.sId ?? ''] = {
          'category': service,
          'subcategories': selectedSubs,
        };
      }
    }

    // Fetch year experience if not loaded
    if (yearExperiences.isEmpty && !isYearExperienceLoading) {
      Future.microtask(() => provider.fetchYearExperience());
    }

    return Scaffold(
      appBar: commonAppBar((){
        FocusScope.of(context).unfocus();
              Navigator.of(context).maybePop();
      }, ""),
      // AppBar(
      //   surfaceTintColor: Colors.transparent,
      //   leading: BackButton(
      //     color: Colors.black,
      //     onPressed: () {
      //       FocusScope.of(context).unfocus();
      //       Navigator.of(context).maybePop();
      //     },
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      // ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    hsized10,
                    Text(
                      'Select Your Experience',
                      style: boldTextStyle(fontSize: 28.0, color: MyColors.blackColor),
                    ),
                    hsized8,
                    Text(
                      'Choose the type of service you specialize in. This helps us connect you with the right requests.',
                      style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
                    ),
                    hsized20,
                    Expanded(
                      child: isYearExperienceLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ListView(
                              children: grouped.values.map((group) {
                                final ServicesTypes category = group['category'];
                                final List<Commercial> subList = group['subcategories'];
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
                                            radius: 24,
                                            backgroundColor: MyColors.appTheme.withOpacity(0.08),
                                            backgroundImage: category.image != null && category.image!.isNotEmpty
                                                ? NetworkImage(category.image!)
                                                : null,
                                            child: (category.image == null || category.image!.isEmpty)
                                                ? Icon(Icons.image, color: MyColors.appTheme)
                                                : null,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              category.name ?? '',
                                              style: semiBoldTextStyle(
                                                fontSize: 16.0,
                                                color: MyColors.darkText,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      hsized20,
                                      ...subList.map((sub) {
                                        final subId = sub.sId ?? '';
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              sub.name ?? '',
                                              style: semiBoldTextStyle(fontSize: 15.0, color: MyColors.darkText),
                                            ),
                                            hsized8,
                                            DropdownButtonFormField<int>(
                                              value: yearExperiences.any((exp) => exp.value == _selectedYearExperience[subId])
                                                  ? _selectedYearExperience[subId]
                                                  : null,
                                              isExpanded: true,
                                              dropdownColor: Colors.white,
                                              hint: Text('Select Experience', style: regularTextStyle(color: Colors.grey.shade400, fontSize: 14.0)),
                                              items: yearExperiences
                                                  .map((exp) => DropdownMenuItem<int>(
                                                        value: exp.value,
                                                        child: Text(
                                                          exp.name,
                                                          style: regularTextStyle(
                                                            color: _selectedYearExperience[subId] == exp.value ? MyColors.appTheme : MyColors.darkText,
                                                            fontSize:14.0,
                                                           // fontWeight: _selectedYearExperience[subId] == exp.value ? FontWeight.bold : FontWeight.normal,
                                                          ),
                                                        ),
                                                      ))
                                                  .toList(),
                                              selectedItemBuilder: (context) {
                                                return yearExperiences.map((exp) {
                                                  return Text(
                                                    exp.name,
                                                    style: regularTextStyle(
                                                      color: MyColors.darkText,
                                                      fontSize:14.0,
                                                    ),
                                                  );
                                                }).toList();
                                              },
                                              onChanged: (val) {
                                                setState(() {
                                                  _selectedYearExperience[subId] = val;
                                                });
                                              },
                                              decoration: InputDecoration(
                                                enabledBorder:OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: MyColors.borderColor),
                                        ),
                                                focusedBorder:OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: MyColors.color7A849C),
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: MyColors.borderColor),
                                                ),
                                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                              ),
                                            ),
                                            hsized8,
                                            Text(
                                              'Work License or Certificates',
                                              style: semiBoldTextStyle(fontSize: 15.0, color: MyColors.darkText),
                                            ),
                                            hsized8,
                                            DottedBorder(
                                              color: Colors.blueAccent.withOpacity(0.5),
                                              borderType: BorderType.RRect,
                                              radius: const Radius.circular(12),
                                              dashPattern: const [6, 4],
                                              strokeWidth: 1,
                                              child: GestureDetector(
                                                onTap: () => _pickImage(subId),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 100,
                                                  alignment: Alignment.center,
                                                  child: _certificateImages[subId] != null
                                                      ? Stack(
                                                          alignment: Alignment.center,
                                                          children: [
                                                            Image.file(
                                                              _certificateImages[subId]!,
                                                              width: 120,
                                                              height: 80,
                                                              fit: BoxFit.cover,
                                                            ),
                                                            Positioned(
                                                              top: 4,
                                                              right: 4,
                                                              child: GestureDetector(
                                                                onTap: () {
                                                                  setState(() {
                                                                    _certificateImages[subId] = null;
                                                                  });
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    shape: BoxShape.circle,
                                                                  ),
                                                                  child: Icon(Icons.close, color: Colors.red, size: 20),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : (_certificateImageUrls[subId] != null
                                                          ? Stack(
                                                              alignment: Alignment.center,
                                                              children: [
                                                                Image.network(
                                                                  _certificateImageUrls[subId]!,
                                                                  width: 120,
                                                                  height: 80,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                                Positioned(
                                                                  top: 4,
                                                                  right: 4,
                                                                  child: GestureDetector(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        _certificateImageUrls[subId] = null;
                                                                      });
                                                                    },
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: Colors.white,
                                                                        shape: BoxShape.circle,
                                                                      ),
                                                                      child: Icon(Icons.close, color: Colors.red, size: 20),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            )
                                                          : Text(
                                                              'upload Image',
                                                              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                                                            )),
                                                ),
                                              ),
                                            ),
                                            hsized16,
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                    CommonButton(
                      text: languageProvider.translate( widget.isEdit? "save_and_continue":'Next'),
                      onTap: _isLoading ? (){} : _submitSkills,
                      backgroundColor: MyColors.appTheme,
                      textColor: Colors.white,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ],
                ),
              ),
              // if (_isLoading)
              //   Container(
              //     color: Colors.black.withOpacity(0.2),
              //     child: const Center(child: CircularProgressIndicator()),
              //   ),
            ],
          ),
        ),
      ),
    );
  }
}
