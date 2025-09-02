import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/assets_paths.dart';
import '../../helper/router.dart';
import 'profile_details_page.dart';
import 'package:bharat_worker/provider/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final profileProvider =
    Provider.of<ProfileProvider>(context, listen: false);
    profileProvider.getProfileData();
    Future.delayed(Duration.zero,(){
      profileProvider.getProfile();
    });
  }
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final isWaiting = profileProvider.waitingForApproval == true;
    final isKycPending = profileProvider.kycStatus == "pending";
    final isKycApproved = profileProvider.kycStatus == "approved";
    final isOnline = profileProvider.isOnline == true;
  //  profileProvider.getProfileData();
    final List<_SettingsItem> settingsItems = [
      _SettingsItem(
        icon:MyAssetsPaths.mySubscription,
        labelKey: 'Subscription plan',
        onTap: () {
          context.push(AppRouter.mySubscriptionView);
        },
      ),

      _SettingsItem(
        icon:MyAssetsPaths.money,
        labelKey: 'my_payments',
        onTap: () {
          context.push(AppRouter.myPayment);
        },
      ),
      _SettingsItem(
        icon:MyAssetsPaths.certificate,
        labelKey: 'training_certification',
        onTap: () {
          context.push(AppRouter.trainingCertification);
        },
      ),
      _SettingsItem(
        icon:MyAssetsPaths.notificationIcon,
        labelKey: 'notification',
        onTap: () {
          context.push(AppRouter.notifications);
        },
      ),
      _SettingsItem(
        icon:MyAssetsPaths.lockPassword,
        labelKey: 'privacy_security',
        onTap: () {},
      ),
      _SettingsItem(
        icon:MyAssetsPaths.headSet,
        labelKey: 'help_support',
        onTap: () {},
      ),
      _SettingsItem(
        icon:MyAssetsPaths.share,
        labelKey: 'share_app',
        onTap: () {},
      ),


      // _SettingsItem(
      //   icon:MyAssetsPaths.diamond,
      //   labelKey: 'my_subscription',
      //   onTap: () {
      //     context.push(AppRouter.mySubscription);
      //   },
      //),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar((){},
          languageProvider.translate('settings'),
          isLeading: false,
      actions: [
        InkWell(
          onTap: (){
            context.push(AppRouter.languageSelection);
          },
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: MyColors.borderColor),
                  borderRadius: BorderRadius.circular(12)
              ),
              padding: EdgeInsets.all(8),
              child: SvgPicture.asset(MyAssetsPaths.language)),
        )
      ]),
      body: SafeArea(
        child: Consumer<ProfileProvider>(builder: (context,profileProvider,_){
          return  RefreshIndicator(
            onRefresh: (){
             return  profileProvider.getProfileData();
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hsized10,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius:36,
                            backgroundColor:
                            isKycApproved?isOnline
                                ?  MyColors.greenColor
                                : MyColors.redColor
                                : MyColors.blackColor,
                            child: CircleAvatar(
                              radius: 34,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(500),
                                  child: Image.network(
                                    profileProvider.profileImageUrl.toString(),
                                    fit: BoxFit.cover,
                                    height: 62,
                                    width: 62,
                                    errorBuilder: (context, error, stackTrace) {
                                      return SvgPicture.asset(MyAssetsPaths.user); // Add size if needed
                                    },
                                  )),
                            ),
                          ),
                          profileProvider.partner == null
                              ? SizedBox.shrink()
                              :
                          // waitingForApproval == false && kycStatus=="pending"
                          isWaiting
                              ? Positioned(
                            right: 0,
                            bottom: 0,
                            child: SvgPicture.asset(MyAssetsPaths.kycPending),
                          )
                              : isKycApproved ?Positioned(
                              right:3,
                              bottom:5,
                              child:
                              Icon(Icons.circle,size: 15,color: isOnline?MyColors.greenColor:MyColors.redColor,)
                          ):
                          SizedBox.shrink(),
                        ],
                      ),
                      // CircleAvatar(
                      //   radius: 35,
                      //   child: Image.network(profileProvider.userProfileImage.toString()), // Replace with user image if available
                      //   backgroundColor: Colors.grey[200],
                      // ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profileProvider.name??"",
                              style: boldTextStyle(fontSize: 20.0, color: MyColors.blackColor),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              profileProvider.phone??"",
                              style: regularNormalTextStyle(fontSize: 13.0, color: MyColors.color7D7D7D),
                            ),
                            const SizedBox(height: 7),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal:8, vertical: 4),
                              decoration: BoxDecoration(
                                color: MyColors.appTheme,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: () {
                                  context.push('/profile-details');
                                },
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Consumer<ProfileProvider>(builder: (context,profileProvider,_){
                                      return Text(
                                        languageProvider.translate('profile_completion').replaceFirst('%s', '${  profileProvider.partner != null ?profileProvider.partner!.profileCompletion:0}%'),
                                        style: mediumTextStyle(fontSize: 12.0, color: Colors.white),
                                      );
                                    })
                                    ,
                                    SizedBox(width: 3,),
                                    Icon(Icons.arrow_forward_ios,color: Colors.white,size: 14,)
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 7),
                if(isKycApproved)
                ...[
                  hsized16,
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:20.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                languageProvider.translate('yourAvailabilityStatus'),
                                style: semiBoldTextStyle(fontSize: 16.0, color:MyColors.darkText),
                              ),
                              Text(
                                languageProvider.translate('letUsersKnowWhenYou'),
                                style: regularNormalTextStyle(fontSize: 12.0, color:MyColors.color7D7D7D),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 15,),
                        InkWell(
                            onTap: (){
                              profileProvider.setOnlineStatus(profileProvider.isOnline,context);

                              profileProvider.setOnlineStatusWithApi(profileProvider.isOnline, context);
                            },
                            child: SvgPicture.asset(profileProvider.isOnline? MyAssetsPaths.onToggleButton:MyAssetsPaths.offToggleButton,height: 24,width: 40,))
                      ],
                    ),
                  ),
                ],


                hsized20,
                Expanded(
                  child: ListView.separated(
                    itemCount: settingsItems.length,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) => hsized28,
                    itemBuilder: (context, index) {
                      final item = settingsItems[index];
                      return _SettingsListTile(
                        icon: item.icon,
                        label: languageProvider.translate(item.labelKey),
                        onTap: item.onTap,
                      );
                      // } else {
                      //   return const SizedBox.shrink();
                      // }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 24, top: 8),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CommonSuccessDialog(
                          image: SvgPicture.asset(
                            MyAssetsPaths.cancelSvg,
                            height: 120,
                            width: 120,
                          ),
                          title: 'Logout Confirmation',
                          subtitle: 'Are you sure you want to logout from your account?',
                          buttonText: 'Logout',
                          secondaryHeight:5.0,
                          onButtonTap: () async {
                            final authProvider = Provider.of<AuthProvider>(context, listen: false);
                            await authProvider.logout(context);
                            Navigator.of(context).pop();
                            context.go(AppRouter.loginSignUp);
                          },
                          secondaryButtonText: 'Cancel',
                          secondaryColor: MyColors.colorEBEBEB,
                          secondaryBorderColor: MyColors.colorEBEBEB,
                          onSecondaryButtonTap: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(MyAssetsPaths.logout, width: 24, height: 24),
                        const SizedBox(width: 8),
                        Text(
                          languageProvider.translate('logout'),
                          style: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        })

      ),
    );
  }
}

class _SettingsItem {
  final String icon;
  final String labelKey;
  final VoidCallback onTap;
  _SettingsItem({required this.icon, required this.labelKey, required this.onTap});
}

class _SettingsListTile extends StatelessWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _SettingsListTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal:20.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  SvgPicture.asset(icon, width: 24, height: 24),
                  SizedBox(width: 10,),
                  Text(label, style: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor)),
                ],
              ),
            ),
            SvgPicture.asset(MyAssetsPaths.right_arrow,height: 24,width: 24,)
          ],
        ),
      ),
    );
     
  }
} 