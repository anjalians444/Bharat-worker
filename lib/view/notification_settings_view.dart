import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:flutter/material.dart';

class NotificationSettingsView extends StatefulWidget {
  const NotificationSettingsView({super.key});

  @override
  State<NotificationSettingsView> createState() => _NotificationSettingsViewState();
}

class _NotificationSettingsViewState extends State<NotificationSettingsView> {
  final List<NotificationSettingItem> _settings = [
    NotificationSettingItem(
      title: 'Job Notifications',
      subtitle: 'Get notified for new, accepted, or cancelled jobs.',
      value: false,
    ),
    NotificationSettingItem(
      title: 'Payment Updates',
      subtitle: 'Receive alerts for successful or pending payments.',
      value: true,
    ),
    NotificationSettingItem(
      title: 'Service Tips',
      subtitle: 'Helpful reminders and work improvement tips.',
      value: true,
    ),
    NotificationSettingItem(
      title: 'Badges & Rewards',
      subtitle: 'Get updates when you earn new badges or bonuses.',
      value: true,
    ),
    NotificationSettingItem(
      title: 'Missed Jobs',
      subtitle: 'Be informed when a job is missed or auto-cancelled.',
      value: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: commonAppBar(
        () => Navigator.pop(context),
        'Notification Settings',
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 24.0),
        itemCount: _settings.length,
        separatorBuilder: (context, index) => hsized20,
        itemBuilder: (context, index) {
          final setting = _settings[index];
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(setting.title, style: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor))),
                  SizedBox(
                    height: 28,
                    child: Transform.scale(
                      scale: 0.8, // 0.8 means 80% size, adjust as needed
                      child: Switch(
                        value: setting.value,
                        onChanged: (bool value) {
                          setState(() {
                            setting.value = value;
                          });
                        },
                        trackOutlineWidth: WidgetStatePropertyAll(0),
                        activeColor: MyColors.whiteColor,
                        activeTrackColor: MyColors.appTheme,
                        inactiveThumbColor: MyColors.whiteColor,
                        inactiveTrackColor: MyColors.borderColor, // remove this if you want default grey
                      ),
                    ),
                  )

                ],
              ),
              Container(
                  width: MediaQuery.of(context).size.width *0.75,
                  child: Text(setting.subtitle, style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText))),
            ],
          );

        },
      ),
    );
  }
}

class NotificationSettingItem {
  final String title;
  final String subtitle;
  bool value;

  NotificationSettingItem({
    required this.title,
    required this.subtitle,
    required this.value,
  });
} 