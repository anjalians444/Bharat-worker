import 'package:bharat_worker/enums/register_enum.dart';
import 'package:bharat_worker/services/user_prefences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
        debugPrint("🔵 Google ID Token: $googleAccessToken");

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
         // print("firebaseIdToken....${user.refreshToken}");

          // Store tokens if needed
           PreferencesServices.setPreferencesData(PreferencesServices.idToken, firebaseIdToken);
          PreferencesServices.setPreferencesData(PreferencesServices.loginType, LoginType.loginTypeGoogle.value);
          await  authProvider.googleSignUpApi(context, user);
         //  PreferencesServices.setPreferencesData(PreferencesServices.isLogin, true);
         // bool loginResponse = await authProvider.signUpApi(context,firebaseIdToken.toString());
          // Optionally: Start token listener
        //  authProvider.startTokenListener();

          // if (context.mounted) {
          //   context.go(AppRouter.dashboard);
          // }
        }
      }
    } catch (e) {
      debugPrint("Google sign-in error: $e");
    } finally {
      authProvider.setGoogleSignInLoading(false);
    }
  }




  Future<void> logoutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
      print("Logged out from Google successfully.");
    } catch (e) {
      print("Google sign out error: $e");
    }
  }


}