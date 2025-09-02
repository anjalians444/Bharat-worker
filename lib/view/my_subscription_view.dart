import 'package:bharat_worker/provider/subscription_management_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/models/subscription_details_model.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:go_router/go_router.dart';

class MySubscriptionView extends StatefulWidget {
  const MySubscriptionView({Key? key}) : super(key: key);

  @override
  State<MySubscriptionView> createState() => _MySubscriptionViewState();
}

class _MySubscriptionViewState extends State<MySubscriptionView> {
  @override
  void initState() {
    super.initState();
    // Refresh data when screen is focused
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subProvider = Provider.of<SubscriptionManagementProvider>(context, listen: false);
      // if (subProvider.subscriptionDetails == null) {
        subProvider.fetchSubscriptionData(context);
      // } else {
        // Check for expired subscription even if data exists
        // subProvider.checkAndShowExpiredDialog(context);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final subProvider = Provider.of<SubscriptionManagementProvider>(context);
    
    // Check if we have data
    if (subProvider.isLoading) {
      return Scaffold(
        backgroundColor: MyColors.whiteColor,
        appBar: commonAppBar(
          () => Navigator.of(context).pop(),
          languageProvider.translate('my_subscription'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    if (subProvider.error != null) {
      return Scaffold(
        backgroundColor: MyColors.whiteColor,
        appBar: commonAppBar(
          () => Navigator.of(context).pop(),
          languageProvider.translate('my_subscription'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                subProvider.error!,
                style: regularTextStyle(fontSize: 14.0, color: Colors.red),
                textAlign: TextAlign.center,
              ),
              hsized16,
              CommonButton(
                text: 'Retry',
                onTap: () => subProvider.fetchSubscriptionData(context),
                backgroundColor: Colors.red,
                textColor: MyColors.whiteColor,
                fontSize: 14.0,
                borderRadius: 8,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              ),
            ],
          ),
        ),
      );
    }
    
    if (subProvider.currentPlan == null) {
      return Scaffold(
        backgroundColor: MyColors.whiteColor,
        appBar: commonAppBar(
          () => Navigator.of(context).pop(),
          languageProvider.translate('my_subscription'),
        ),
        body: Center(
          child: Text(
            'No subscription data available',
            style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
          ),
        ),
      );
    }
    
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar(
        () => Navigator.of(context).pop(),
        languageProvider.translate('my_subscription'),
        actions: [
          InkWell(
            onTap: () {
             context.push(AppRouter.seeAllTransaction);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: MyColors.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(10),
              child: SvgPicture.asset(MyAssetsPaths.transactionHistory)
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                         // Current Plan Section
             _buildCurrentPlanCard(languageProvider, subProvider),
             hsized25,
             
             // Upcoming Plans Section
             _buildUpcomingPlansSection(languageProvider, subProvider),
             hsized10,
            
            // Note Section
            _buildNoteSection(languageProvider),
            hsized25,
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(LanguageProvider languageProvider, SubscriptionManagementProvider subProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: MyColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MyColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: MyColors.borderColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                MyAssetsPaths.diamond2,
                height: 70,width: 70,
              ),
              SizedBox(width: 12,),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            subProvider.currentPlan!.subscriptionPlans.name,
                            style: semiBoldTextStyle(fontSize: 18.0, color: MyColors.blackColor),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            languageProvider.translate('active'),
                            style: mediumTextStyle(fontSize: 14.0, color: MyColors.whiteColor),
                          ),
                        ),
                      ],
                    ),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${languageProvider.translate('expiry_date')}: ',
                              style: regularTextStyle(fontSize: 12.0, color: MyColors.darkText),
                            ),
                            Text(
                              subProvider.currentPlan!.endDate,
                              style: regularTextStyle(fontSize: 12.0, color: MyColors.color7A849C),
                            ),
                          ],
                        ),
                        hsized5,
                        Container(
                          padding: EdgeInsets.symmetric(horizontal:10,vertical: 4),
                          decoration: BoxDecoration(
                            color: MyColors.borderColor,
                            borderRadius: BorderRadius.circular(6)
                          ),
                          child: Text(
                            '${languageProvider.translate('remaining_days')}: ${subProvider.currentPlan!.remainingDays} ${languageProvider.translate('days')}',
                            style: regularTextStyle(fontSize: 10.0, color: MyColors.color7A849C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
             
            ],
          ),
          hsized16,
          

          
          // Benefits Section
          Text(
            languageProvider.translate('benefits'),
            style: boldTextStyle(fontSize: 14.0, color: MyColors.appTheme),
          ),
          hsized8,
          ...subProvider.currentPlan!.subscriptionPlans.features.map((benefit) => _buildBenefitItem(benefit)),
          hsized16,
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: CommonButton(
                  text: languageProvider.translate('change_plan'),
                  onTap: () {
                    subProvider.changePlan('new_plan_id');
                    context.push(AppRouter.subscriptionPlanView);
                  },
                  backgroundColor: MyColors.appTheme,
                  textColor: MyColors.whiteColor,
                  borderColor: MyColors.appTheme,
                  fontSize: 14.0,
                  borderRadius: 60,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              SizedBox(width: 12,),
              Expanded(
                child: CommonButton(
                  text: languageProvider.translate('renew_plan'),
                  onTap: () {
                    subProvider.renewPlan(subProvider.currentPlan!.id);
                  },
                  backgroundColor: MyColors.yellowColor,
                  textColor: MyColors.blackColor,
                  borderColor: MyColors.yellowColor,
                  fontSize: 14.0,
                  borderRadius: 60,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
          hsized10
        ],
      ),
    );
  }

  Widget _buildUpcomingPlansSection(LanguageProvider languageProvider, SubscriptionManagementProvider subProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          languageProvider.translate('upcoming_plan'),
          style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.darkText),
        ),
        hsized8,
        if (subProvider.upcomingPlans.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: MyColors.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MyColors.borderColor),
            ),
            child: Text(
              languageProvider.translate('no_upcoming_plans'),
              style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText),
              textAlign: TextAlign.center,
            ),
          )
        else
          ...subProvider.upcomingPlans.map((plan) => _buildUpcomingPlanCard(plan, languageProvider)),
      ],
    );
  }

  Widget _buildUpcomingPlanCard(UpcomingPlan plan, LanguageProvider languageProvider) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: MyColors.whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: MyColors.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(
            MyAssetsPaths.elite,
            width:76,
            height: 76,
          ),
          SizedBox(width: 12,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        plan.subscriptionPlans.name,
                        style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: MyColors.yellowColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        languageProvider.translate('scheduled'),
                        style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor),
                      ),
                    ),
                  ],
                ),
                hsized4,
                rowText('${languageProvider.translate('start_date')}: ',  plan.startDate,),
                hsized5,
                rowText('${languageProvider.translate('expiry_date')}: ',  plan.endDate,),

                // hsized4,
                // Text(
                //   '₹${plan.payableAmount}',
                //   style: mediumTextStyle(fontSize: 14.0, color: MyColors.appTheme),
                // ),
              ],
            ),
          ),
         
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String benefit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check,
            color: MyColors.darkText,
            size: 16,
          ),
          SizedBox(width:8,),
          Expanded(
            child: Text(
              benefit,
              style: regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection(LanguageProvider languageProvider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 4),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Text(
        languageProvider.translate('upcoming_plan_note'),
        style: regularTextStyle(fontSize: 11.0, color:MyColors.redColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  rowText(String title,String value) {
    return Row(
      children: [
        Text(
          title,
          style: regularTextStyle(fontSize: 12.0, color: MyColors.darkText),
        ),
        Text(
        value,
          style: regularTextStyle(fontSize: 12.0, color: MyColors.color7A849C),
        ),
      ],
    );
  }


} 