import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/models/referral_history_model.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/widgets/common_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../constants/assets_paths.dart';

class ReferralHistoryPopup extends StatefulWidget {
  const ReferralHistoryPopup({Key? key}) : super(key: key);

  @override
  State<ReferralHistoryPopup> createState() => _ReferralHistoryPopupState();
}

class _ReferralHistoryPopupState extends State<ReferralHistoryPopup> {
  @override
  void initState() {
    super.initState();
    // Fetch referral history when popup opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      profileProvider.getReferralHistory(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        width: MediaQuery.of(context).size.width * 0.9,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Referral History',
                  style: boldTextStyle(
                    fontSize: 18.0,
                    color: MyColors.blackColor,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MyColors.bg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: MyColors.darkText,
                    ),
                  ),
                ),
              ],
            ),
            hsized20,
            
            // Content
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, child) {
                if (profileProvider.isReferralHistoryLoading) {
                  return Container(
                    height: 200,
                    color: Colors.white ,
                    child: Center(
                      child: CommonLoader(),
                    ),
                  );
                }

                final referralHistory = profileProvider.referralHistoryResponse?.data?.referralHistory;
                
                if (referralHistory == null || referralHistory.isEmpty) {
                  return Container(
                    height: 200,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          MyAssetsPaths.user,
                          height: 60,
                          width: 60,
                          color: MyColors.color7A849C,
                        ),
                        hsized12,
                        Text(
                          'No Referral History',
                          style: mediumTextStyle(
                            fontSize: 16.0,
                            color: MyColors.darkText,
                          ),
                        ),
                        hsized8,
                        Text(
                          'You haven\'t referred anyone yet',
                          style: regularTextStyle(
                            fontSize: 14.0,
                            color: MyColors.color7A849C,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: RefreshIndicator(
                    onRefresh: () async {
                      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
                      await profileProvider.getReferralHistory(context);
                    },
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: referralHistory.length,
                      itemBuilder: (context, index) {
                      final item = referralHistory[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 12),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: MyColors.whiteColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: MyColors.borderColor,
                            width: 0.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: MyColors.appTheme.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: SvgPicture.asset(
                                MyAssetsPaths.user,
                                height: 24,
                                width: 24,
                                color: MyColors.appTheme,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name ?? 'Unknown User',
                                    style: mediumTextStyle(
                                      fontSize: 16.0,
                                      color: MyColors.blackColor,
                                    ),
                                  ),
                                  hsized4,
                                  Text(
                                    'Referred User',
                                    style: regularTextStyle(
                                      fontSize: 14.0,
                                      color: MyColors.color7A849C,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: MyColors.appTheme,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '+${item.referralFromPoint ?? 0}',
                                style: mediumTextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                                                 ));
                       },
                     ),
                   ),
                 );
              },
            ),
            hsized20,
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyColors.appTheme,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
                child: Text(
                  'Close',
                  style: mediumTextStyle(
                    fontSize: 16.0,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 