
 import 'package:bharat_worker/constants/my_colors.dart';
import 'package:flutter/material.dart';

 ///--------------  Loader  -----------------------
  progressLoadingDialog(BuildContext context, bool status) {
   if (status) {
     showDialog(
       context: context,
       barrierDismissible: false,
       builder: (BuildContext context) {
         return  Center(
             child:CircularProgressIndicator(color: MyColors.appTheme,)
           // //LoaderView()
           // Image.asset(MyAssetsPaths.loader2,height: 100,width: 100,color: MyColors.appTheme,)

         );
       },
     );
   } else {
     Navigator.pop(context);
   }
 }

void customToast(BuildContext context, String msg) {
final overlay = Overlay.of(context);
final overlayEntry = OverlayEntry(
  builder: (context) => Positioned(
    top: MediaQuery.of(context).size.height * 0.81, // Customize this value to adjust the position
    left: MediaQuery.of(context).size.width * 0.1, // Centering the toast
    right: MediaQuery.of(context).size.width * 0.1, // Centering the toast
    child: Material(
      color: Colors.transparent,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: MyColors.appTheme,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 16.0),
        ),
      ),
    ),
  ),
);

overlay.insert(overlayEntry);

Future.delayed(const Duration(seconds: 2), () {
overlayEntry.remove();
});
}