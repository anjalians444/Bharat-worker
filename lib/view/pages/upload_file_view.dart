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
  @override
  void initState() {
    super.initState();
    final profileProvider = Provider.of<ProfileProvider>(context,listen: false);
    profileProvider.clearAllControllers();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);

    // Show/hide loader dialog based on isLoading
    // (Remove loader logic for workAddressProvider)

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: commonAppBar(() {
          Navigator.of(context).pop();
        }, isLeading: false,""),
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
                  child: DocumentUploadSection(partner: profileProvider.partner,),
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
                  if (!profileProvider.validateDocumentUpload( context,false)) {
                    return;
                  }
                  // showDialog( _profileResponse...
                  //   context: context,
                  //   barrierDismissible: false,
                  //   builder: (context) => const CommonLoaderDialog(),
                  // );
                  final success = await profileProvider.uploadPartnerDocuments(
                    context: context,
                    selectedIdType: profileProvider.selectedIdType,
                    idNumber: profileProvider.idController.text.trim(),
                    isEdit: false
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
      ),
    );
  }
}
