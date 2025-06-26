import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/work_address_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/widgets/common_address_form.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';

class WorkAddressView extends StatelessWidget {
  const WorkAddressView({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final workAddressProvider = Provider.of<WorkAddressProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        Navigator.of(context).pop();
      }, ""),
      body: SingleChildScrollView(

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.translate('where_do_you_work'),
                    style: boldTextStyle(fontSize: 24.0, color: MyColors.blackColor),
                  ),

                  const SizedBox(height: 10),
                  Text(
                    languageProvider.translate('choose_areas_to_accept_jobs'),
                    style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
                  ),
                ],
              ),
            ),

            CommonAddressForm(
              workAddressProvider: workAddressProvider,
              languageProvider: languageProvider,
              padding: EdgeInsets.symmetric(horizontal: 20),
            ),
          ],
        ),
      ),
      bottomSheet: Wrap(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(bottom:20.0),
            child: CommonButton(
              text: languageProvider.translate('save_and_continue'),
              onTap: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => CommonSuccessDialog(
                    image:SvgPicture.asset(MyAssetsPaths.certified,height: 132,width: 132,),
                    title: "You're Now a Certified Partner!",
                    subtitle: "You can now access more job requests and earn trust faster.",
                    buttonText: "Go to Dashboard",
                    onButtonTap: () {
                      Navigator.of(context).pop();
                      context.go(AppRouter.dashboard);
                    },
                  ),
                );
              },
              margin: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
} 
