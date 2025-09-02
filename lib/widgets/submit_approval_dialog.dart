import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';

class SubmitApprovalDialog extends StatelessWidget {
  final VoidCallback onSubmit;
  final VoidCallback onCancel;
  const SubmitApprovalDialog({Key? key, required this.onSubmit, required this.onCancel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      insetPadding: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical:20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             SvgPicture.asset(
                MyAssetsPaths.approveProfile, // Use your certificate SVG asset
                height:130,
                width: 130,
              ),

            const SizedBox(height: 25),
            Text(
              'Submit Profile for Approval',
              textAlign: TextAlign.center,
              style: semiBoldTextStyle(
                fontSize: 22.0,
                color: MyColors.blackColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "You're almost there! Your profile is 100% complete.\nSubmit now to get verified and start receiving job requests.",
              textAlign: TextAlign.center,
              style: regularTextStyle(
                fontSize: 14.0,
                color: MyColors.color838383,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Approval may take up to 24 hours. You’ll be notified once verified.',
              textAlign: TextAlign.center,
              style: mediumTextStyle(
                fontSize: 10.0,
                color: MyColors.color838383,
              ),
            ),
            const SizedBox(height: 30),
            CommonButton(text:  'Submit Now', onTap: onSubmit,backgroundColor: MyColors.appTheme,textColor: Colors.white,),

            CommonButton(text:  'Cancel', onTap: onCancel,backgroundColor: MyColors.bg,textColor: Colors.black,),



          ],
        ),
      ),
    );
  }
} 