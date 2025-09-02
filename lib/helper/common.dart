import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class CurrentChat {
  static String? groupChatId;
}

commonAppBar(GestureTapCallback onTap, String title, {List<Widget>? actions,Color bg = Colors.white,bool isLeading = true}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(64),
    child: Container(
      padding: EdgeInsets.only(top:10,bottom: 10),
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: AppBar(
        surfaceTintColor: Colors.transparent,
        leadingWidth:isLeading? 43:0,
        leading: isLeading? InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: MyColors.borderColor),
                  borderRadius: BorderRadius.circular(12)
              ),
              padding: EdgeInsets.all(7),
              child: const Icon(Icons.arrow_back,size: 24,)),
          onTap: () {
            onTap();
          },
        ):null,
        title:  Text(title, style: semiBoldTextStyle(fontSize: 20.0,color: MyColors.blackColor)),
        actions: actions,
        centerTitle: isLeading?true:false,
        elevation: 0,
        backgroundColor: bg,
        foregroundColor: Colors.black,
      ),
    ),
  );
}

heading(String s) {
  return Text(
    s,
    style: semiBoldTextStyle(fontSize: 18.0, color: MyColors.blackColor),
  );
}

Widget commonSectionHeading(String label, {TextStyle? style}) {
  return Text(
    label,
    style: style ?? semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
  );
}

Widget commonTextFieldSection({
  required Widget textField,
  String? errorText,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      textField,
      if (errorText != null) ...[
        SizedBox(height: 4),
        Text(errorText, style: TextStyle(color: Colors.red, fontSize: 12)),
      ],
    ],
  );
}

Widget commonProfileImageSection({
  required File? imageFile,
  required VoidCallback onPickImage,
  String? errorText,
   required ProfileProvider profileProvider
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.grey[300],
              backgroundImage: imageFile != null ? FileImage(imageFile) : null,
              child: imageFile == null
                  ?
              profileProvider.profileImageUrl.isNotEmpty?
                  ClipRRect(
                      borderRadius: BorderRadius.circular(500),
                      child: Image.network(profileProvider.profileImageUrl,
                          height:100,
                          width:100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return  Icon(Icons.person, size: 35,color: Colors.white); // Add size if needed
                          })):
              Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: onPickImage,
                child: Container(
                  decoration: BoxDecoration(
                    color: MyColors.appTheme,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Center(child: Icon(Icons.camera_enhance_outlined, color: Colors.white, size: 18)),
                ),
              ),
            ),
          ],
        ),
      ),
      if (errorText != null) ...[
        SizedBox(height: 4),
        Text(errorText, style: TextStyle(color: Colors.red, fontSize: 12)),
      ],
    ],
  );
}

Widget profileInfoCard({
  required String value,
  required String label,
  required String iconPath,
  TextStyle? valueStyle,
  TextStyle? labelStyle,
  double iconSize = 24,
  EdgeInsetsGeometry? padding,
}) {
  return Container(
    padding: padding ?? const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: MyColors.whiteColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: MyColors.borderColor),
    ),
    child: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Text(
                value,
                style: valueStyle ?? boldTextStyle(fontSize: 20.0, color: MyColors.blackColor),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: labelStyle ?? regularTextStyle(fontSize: 14.0, color: MyColors.color7A849C),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.topRight,
          child: SvgPicture.asset(iconPath, width: iconSize, height: iconSize),
        ),
      ],
    ),
  );
}

onlineOfflineButton() {
  return  Builder(
    builder: (context) {
      final isOnline = context.watch<ProfileProvider>().isOnline;
      return GestureDetector(
        onTap: () {
          final RenderBox button = context.findRenderObject() as RenderBox;
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);

          showMenu<bool>(
            context: context,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
            ),
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy + button.size.height, // directly below
              position.dx + button.size.width,
              position.dy,
            ),
            items: [
              PopupMenuItem<bool>(
                height: 28,
                value: true,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: MyColors.greyColor),
                    SizedBox(width: 5),
                    Text(
                      "Online",
                      style: semiBoldTextStyle(fontSize: 12.0, color: MyColors.greyColor),
                    ),
                  ],
                ),
              ),
              PopupMenuItem<bool>(
                height: 28,
                value: false,
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: MyColors.greyColor),
                    SizedBox(width: 5),
                    Text(
                      "Offline",
                      style: semiBoldTextStyle(fontSize: 12.0, color: MyColors.greyColor),
                    ),
                  ],
                ),
              ),
            ],
          ).then((value) {
            if (value != null) {
              context.read<ProfileProvider>().setOnlineStatusWithApi(value, context);
            }
          });
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: MyColors.borderColor.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(5),
              color: isOnline ? MyColors.greenColor : MyColors.borderColor.withOpacity(0.4)
          ),
          padding: EdgeInsets.symmetric(horizontal:5,vertical: 2),
          child: Row(
            children: [
              Icon(Icons.circle, size: 8, color: isOnline ? MyColors.whiteColor : MyColors.greyColor),
              SizedBox(width: 5),
              Text(
                isOnline ? "Online" : "Offline",
                style: semiBoldTextStyle(
                  fontSize: 12.0,
                  color: isOnline ? MyColors.whiteColor : MyColors.greyColor,
                ),
              ),
              Icon(Icons.arrow_drop_down_outlined, size: 22, color: isOnline ? MyColors.whiteColor: MyColors.greyColor),
            ],
          ),
        ),
      );
    },
  );
}