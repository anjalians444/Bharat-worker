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
import 'package:bharat_worker/view/widgets/document_upload_section.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/common_loader.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/widgets/common_address_form.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';

class UploadFileView extends StatefulWidget {
  const UploadFileView({super.key});

  @override
  State<UploadFileView> createState() => _UploadFileViewState();
}

class _UploadFileViewState extends State<UploadFileView> {
  // Remove local state for selectedIdType and idController

  // Validation method
/*  bool validateDocumentUpload(ProfileProvider profileProvider, BuildContext context) {
    if (profileProvider.selectedIdType == null || profileProvider.selectedIdType!.isEmpty) {
      customToast(context, "Please select ID type.");
      return false;
    }
   else if (profileProvider.idController.text.trim().isEmpty) {
      customToast(context, "Please enter ID number.");
      return false;
    }
    //if (profileProvider.selectedIdType == "Aadhar Card" || profileProvider.selectedIdType == "PAN Card") {
    else  if (profileProvider.frontImage == null) {
        customToast(context, "Please select the front image of your ${profileProvider.selectedIdType}.");
        return false;
      }
     else if (profileProvider.backImage == null) {
        customToast(context, "Please select the back image of your ${profileProvider.selectedIdType}.");
        return false;
      }
    else if (profileProvider.experienceCertificates.isEmpty ) {
      customToast(context, "Please select the back image of your ${profileProvider.selectedIdType}.");
      return false;
    }
   // }
    return true;
  }*/

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    // Show/hide loader dialog based on isLoading
    // (Remove loader logic for workAddressProvider)

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        Navigator.of(context).pop();
      }, ""),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height:10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:20.0),
                child: DocumentUploadSection(),
              ),
              hsized60,
            ],
          ),
        ),
      ),
      bottomSheet: Wrap(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom:0.0),
            child: CommonButton(
              text: languageProvider.translate('save_and_continue'),
              onTap: profileProvider.isLoading ? (){} : () async {
                profileProvider.unfocusf(context);
                if (!profileProvider.validateDocumentUpload( context)) {
                  return;
                }
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const CommonLoaderDialog(),
                );
                final success = await profileProvider.uploadPartnerDocuments(
                  context: context,
                  selectedIdType: profileProvider.selectedIdType,
                  idNumber: profileProvider.idController.text.trim(),
                );
                // Navigator.of(context).pop();
                if (success) {
                  // Optionally show success dialog or navigate
                }
              },
              margin: const EdgeInsets.only(bottom: 16,left: 20,right: 20,top: 5),
            ),
          ),
        ],
      ),
    );
  }
}
