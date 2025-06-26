import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../helper/router.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar(
        () => Navigator.pop(context),
        'Notifications',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: InkWell(
              onTap: () => context.push(AppRouter.notificationSettings),
              child: SvgPicture.asset(MyAssetsPaths.settingIcon),
            ),
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 24),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => hsized16,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return InkWell(
            onTap: () => context.push(AppRouter.notificationDetail),
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: MyColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: MyColors.borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top:2.0),
                    child: SvgPicture.asset(notification.iconPath),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(notification.title, style: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor)),
                        SizedBox(height: 8,),
                        Text(notification.subtitle, style: regularTextStyle(fontSize: 12.0, color: MyColors.color7A849C)),
                      ],
                    ),
                  ),
                  Text(notification.time, style: regularTextStyle(fontSize: 12.0, color: MyColors.color7A849C)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class NotificationItem {
  final String iconPath;
  final String title;
  final String subtitle;
  final String time;

  NotificationItem({
    required this.iconPath,
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

List<NotificationItem> notifications = [
  NotificationItem(
    iconPath: MyAssetsPaths.jobAcceptedIcon,
    title: 'Job Accepted Successfully',
    subtitle: 'You\'ve accepted Job #1023 - AC Service.',
    time: '2 mins',
  ),
  NotificationItem(
    iconPath: MyAssetsPaths.paymentReceivedIcon,
    title: 'Payment Received',
    subtitle: '₹650 received for Job #1007 - AC Gas Filling.',
    time: '30 min',
  ),
  NotificationItem(
    iconPath: MyAssetsPaths.jobCancelledIcon,
    title: 'Job Cancelled',
    subtitle: 'Job #1023 - AC Service has been cancelled by the customer.',
    time: '1 hour',
  ),
  NotificationItem(
    iconPath: MyAssetsPaths.newJobRequestIcon,
    title: 'New Job Request',
    subtitle: 'New plumbing job request available near you.',
    time: '1 hour',
  ),
  NotificationItem(
    iconPath: MyAssetsPaths.skillBadgeUnlockedIcon,
    title: 'Skill Badge Unlocked',
    subtitle: 'You\'ve earned the "Trusted Plumber" badge!',
    time: 'Yesterday',
  ),
  NotificationItem(
    iconPath: MyAssetsPaths.profileUpdateReminderIcon,
    title: 'Profile Update Reminder',
    subtitle: 'Complete your profile to get more job offers.',
    time: '2 days',
  ),
]; 