import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:flutter/material.dart';

class UiUtils {
  ///================== CachedNetwork Image =================
  /*static cachedNetworkImage(double width, double height, String img) {
    return CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: img,
      fit: BoxFit.cover,
      placeholder: (context, url) => UiUtils.allPlaceHolderImage(height, width),
      errorWidget: (context, url, error) =>
          UiUtils.allPlaceHolderImage(height, width),
    );
  }

  static errorText(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 3),
      child: Text(
        error,
        style: MyFontStyle.errorTextStyle16,
      ),
    );
  }

  ///================== CachedNetwork Image =================
  static cachedNetworkFullImage(double width, String img) {
    return CachedNetworkImage(
      width: width,
      height: width,
      imageUrl: img,
      placeholder: (context, url) => UiUtils.allPlaceHolderImage(300, width),
      errorWidget: (context, url, error) =>
          UiUtils.allPlaceHolderImage(300, width),
    );
  }

  ///================== CachedNetwork Image =================
  static cachedNetworkFullImage2(double width, String img) {
    return CachedNetworkImage(
      width: width,
      height: 400,
      imageUrl: img,
      placeholder: (context, url) => UiUtils.allPlaceHolderImage(300, width),
      errorWidget: (context, url, error) =>
          UiUtils.allPlaceHolderImage(300, width),
    );
  }*/

  ///============= Pick Image BottomSheet Ui =================

  static uploadImageBottomUi(BuildContext context,
      GestureTapCallback cameraOnTap, GestureTapCallback galleryOnTap,LanguageProvider languageProvider, GestureTapCallback locationOnTap) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            height: 390,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: MyColors.bg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                hsized15,
                Container(
                  height: 5,
                  width: 150,
                  decoration: BoxDecoration(
                      color: MyColors.lightText,
                      borderRadius: BorderRadius.circular(20)),
                ),
                hsized40,

                itemUi(
                    Icons.add, "Add_photo", galleryOnTap, 23, 24,languageProvider),
                hsized20,
                itemUi(Icons.camera_enhance_outlined, "Take_new_photos",
                    cameraOnTap, 23, 24,languageProvider),
                hsized20,
                itemUi(
                    Icons.location_on, "Location", locationOnTap, 23, 24,languageProvider),
                /*   GestureDetector(
                  onTap: () {
                    locationOnTap();
                  },
                  child: Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MyColors.appTheme.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.location_on, color: MyColors.appTheme, size: 28),
                  ),
                ),*/
                hsized40,
                InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                        height: 55,
                        width: double.infinity,
                        margin: const EdgeInsets.only(right: 20, left: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: MyColors.appTheme,
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                            "cancel",
                            style: semiBoldTextStyle(fontSize:16.0, color:MyColors.whiteColor)
                        ))),
                hsized20,
              ],
            ),
          ),

        ],
      ),
    );
  }

  ///================Item card ui=====================
  static itemUi(IconData icon, String title, GestureTapCallback onTap,
      double height, double width,LanguageProvider languageProvider) {
    return InkWell(
      radius: 80,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        decoration: BoxDecoration(
          color: MyColors.whiteColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD4D4D4),
          ),
          // boxShadow: const [
          //   BoxShadow(color: MyColors.lightAppTheme, blurRadius: 3)
          // ]
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ignore: deprecated_member_use
            Icon(icon),
            // SvgPicture.asset(
            //   icon,
            //   height: height,
            //   width: width,
            //   color: MyColors.blackColor,
            // ),

            const SizedBox(
              width: 20,
            ),

            Text(
              languageProvider.translate(title),
              style: const TextStyle(
                  fontSize: 13,
                  // fontFamily: MyFonts.poppinsMedium,
                  color: MyColors.blackColor),
            )
          ],
        ),
      ),
    );
  }

}
