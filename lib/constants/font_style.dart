import 'package:bharat_worker/constants/my_font_family.dart';
import 'package:flutter/material.dart';

segoeScriptTextStyle({required fontSize, required color, latterSpace,height,overflow}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       overflow: overflow,
       fontWeight: FontWeight.w300,
       fontFamily:MyFonts.segoeScript );
}

lightTextStyle({required fontSize, required color, latterSpace,height,overflow}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       letterSpacing: 0.2,
       height: 1.5,
       overflow: overflow,
       fontWeight: FontWeight.w300,
       fontFamily:MyFonts.manropeLight );
}

regularNormalTextStyle({required fontSize, required color, latterSpace,height,overflow}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       overflow: overflow,
       letterSpacing: 0.4,
       height: 1.5,
       fontWeight: FontWeight.w300,
       fontFamily:MyFonts.manropeRegular );
}
regularNormalTextStyleWithoutHeight({required fontSize, required color, latterSpace,height,overflow}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       overflow: overflow,
       letterSpacing: 0.2,
       fontWeight: FontWeight.w300,
       fontFamily:MyFonts.manropeLight );
}

regularTextStyle({required fontSize, required color, height,overflow,TextDecoration? decoration}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       overflow: overflow,
       fontWeight: FontWeight.w400,
       decoration: decoration,
       fontFamily:MyFonts.manropeRegular );
}

mediumTextStyle({required fontSize, required color, height,overflow}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       overflow: overflow,
       fontWeight: FontWeight.w500,
       // height: height,
       letterSpacing: 0.2,
       height: 1.5,
       fontFamily: MyFonts.manropeMedium );
}

semiBoldTextStyle({required fontSize, required color, height,overflow}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       overflow: overflow,
       fontWeight: FontWeight.w600,
       letterSpacing: 0.2,
       height: 1.5,
       fontFamily: MyFonts.manropeSemiBold );
}

boldTextStyle({required fontSize, required color, height, latterSpace,overflow}) {
   return TextStyle(
      fontSize: fontSize,
      color: color,
      overflow: overflow,
      fontWeight: FontWeight.w700,
      fontFamily: MyFonts.manropeBold ,
      letterSpacing: 0.2,
      height: 1.5,
      //   letterSpacing: latterSpace,
   );
}
extraBoldTextStyle({required fontSize, required color, height, latterSpace,overflow}) {
   return TextStyle(
      fontSize: fontSize,
      color: color,
      overflow: overflow,
      fontWeight: FontWeight.w800,
      fontFamily: MyFonts.manropeExtraBold ,
      //   letterSpacing: latterSpace,
   );
}

boldMaxLiseTextStyle({required fontSize, required color, height, latterSpace,var overflow}) {
   return TextStyle(
      fontSize: fontSize,
      color: color,
      overflow: overflow,
      fontWeight: FontWeight.w700,
      fontFamily: MyFonts.manropeBold ,
      letterSpacing: 0.2,
      height: 1.5,
      // letterSpacing: latterSpace
   );
}

appBarTextStyle({fontSize, required color, height}) {
   return TextStyle(
       fontSize: fontSize,
       color: color,
       fontWeight: FontWeight.w500,
       height: height,
       fontFamily: MyFonts.manropeMedium);
}
