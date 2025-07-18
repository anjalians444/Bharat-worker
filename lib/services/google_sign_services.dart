import 'package:bharat_worker/enums/register_enum.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInServices{

  final FirebaseAuth auth = FirebaseAuth.instance;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> googleSignup(BuildContext context, var authProvider) async {
   // authProvider.setGoogleSignInLoading(true);

    try {
      final GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleAuth = await googleSignInAccount.authentication;

        final String? googleIdToken = googleAuth.idToken;
        final String? googleAccessToken = googleAuth.accessToken;

        // ✅ Use this for backend validation (if needed)
        debugPrint("🔵 Google ID Token: $googleIdToken");

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleIdToken,
          accessToken: googleAccessToken,
        );

        final UserCredential result = await auth.signInWithCredential(credential);
        final User? user = result.user;

        if (user != null) {
          // ✅ Firebase ID token (for authenticated API calls with Firebase backend)
          final String firebaseIdToken = (await user.getIdToken()) ?? "";
          debugPrint("🟢 Firebase ID Token: $firebaseIdToken");

          // Store tokens if needed
           PreferencesServices.setPreferencesData(PreferencesServices.userToken, firebaseIdToken);
           PreferencesServices.setPreferencesData(PreferencesServices.isLogin, true);

          // Optionally: Start token listener
        //  authProvider.startTokenListener();

          if (context.mounted) {
            context.go(AppRouter.dashboard);
          }
        }
      }
    } catch (e) {
      debugPrint("Google sign-in error: $e");
    } finally {
      authProvider.setGoogleSignInLoading(false);
    }
  }


  Future<void> googleSignup1(BuildContext context, var authProvider) async {
    // Set loading state to true
    authProvider.setGoogleSignInLoading(true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;
        final AuthCredential authCredential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);

        // Getting users credential
        UserCredential result = await auth.signInWithCredential(authCredential);
        User? user = result.user;
        String firstname = "";
        String lastName = "";

        if (user != null) {
          debugPrint("user....${user.displayName}");
          debugPrint("user....${user.email}");
          debugPrint("user....${user.uid}");


          if (user.displayName != null) {
            var name = user.displayName!.split(" ");
            if (name.length > 1) {
              firstname = name[0];
              lastName = name[1];
            }
          }

         // String fcm = await PreferencesServices.getPreferencesData(PreferencesServices.fcm) ?? "";
          bool success;
          // On successful login, set login state in preferences
          PreferencesServices.setPreferencesData(PreferencesServices.isLogin, true);
          context.go(AppRouter.dashboard);

          // success = await authProvider.socialLogin(
          //     context,
          //     user.displayName,
          //     user.email,
          //     LoginType.loginTypeGoogle.value.toString()
          // );
          //
          // if (success) {
          //   if (context.mounted) {
          //     // Clear form fields
          //     authProvider.clearFormFields();
          //
          //     // Navigate to dashboard
          //     PreferencesServices.setPreferencesData(PreferencesServices.isLogin, true);
          //     context.go('/dashboard');
          //   }
          // }
        }
      }
    } catch (e) {
      debugPrint("Google sign-in error: $e");
      if (context.mounted) {
        // Show error message if needed
        // You can add error handling here
      }
    } finally {
      // Set loading state to false
      authProvider.setGoogleSignInLoading(false);
    }
  }

  /* socialLogin(ParentRegisterModel socialLoginModel,BuildContext context)async {

    await ApiServices.socialLoginRequest(context, socialLoginModel).then((onValue){
      CustomNavigators.pushRemoveUntil(DashBoardView(), context);
    });
  }*/

  Future<void> logoutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      print("Logged out from Google successfully.");
    } catch (e) {
      print("Google sign out error: $e");
    }
  }


}