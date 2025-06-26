import 'package:bharat_worker/models/job_model.dart';
import 'package:bharat_worker/view/add_money_view.dart';
import 'package:bharat_worker/view/my_payment_view.dart';
import 'package:bharat_worker/view/onboarding_view.dart';
import 'package:bharat_worker/view/pages/saved_job_view.dart';
import 'package:bharat_worker/view/splash_view.dart';
import 'package:bharat_worker/view/languages_selection_view.dart';
import 'package:bharat_worker/view/login_signup_view.dart';
import 'package:bharat_worker/view/login_view.dart';
import 'package:bharat_worker/view/otp_verify_view.dart';
import 'package:bharat_worker/view/tell_us_about_view.dart';
import 'package:bharat_worker/view/all_category_view.dart';
import 'package:bharat_worker/view/work_address_view.dart';
import 'package:bharat_worker/view/dashboard_view.dart';
import 'package:bharat_worker/view/job_detail_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view/notification_view.dart';
import '../view/notification_settings_view.dart';
import '../view/notification_detail_view.dart';
import '../view/pages/profile_details_page.dart';
import '../view/pages/edit_profile_view.dart';
import '../view/pages/training_certification_page.dart';
import '../view/pages/quiz_view.dart';
import '../view/pages/see_all_transactions_view.dart';
import '../view/chat_view.dart';
import '../view/job_navigation_view.dart';

class AppRouter {
  static const String splash = '/';
  static const String languageSelection = '/language-selection';
  static const String onBoarding = '/onboarding';
  static const String loginSignUp = '/login-signup';
  static const String login = '/login';
  static const String otpVerify = '/otp-verify';
  static const String tellUsAbout = '/tell-us-about';
  static const String allCategory = '/all-category';
  static const String workAddress = '/work-address';
  static const String dashboard = '/dashboard';
  static const String jobDetail = '/job-detail';
  static const String notifications = '/notifications';
  static const String notificationSettings = '/notification-settings';
  static const String notificationDetail = '/notification-detail';
  static const String profileDetails = '/profile-details';
  static const String editProfile = '/edit-profile';
  static const String trainingCertification = '/training-certification';
  static const String quiz = '/quiz';
  static const String chat = '/chat';
  static const String jobNavigation = '/job-navigation';
  static const String savedJob = '/saved-job';
  static const String myPayment = '/my-payment';
  static const String seeAllTransaction = '/see-all-transactions';
  static String addMoney = '/add-money';

  static final GoRouter router = GoRouter(
    initialLocation: splash, // Splash screen as the initial screen
    routes: [
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashView(),
      ),

      GoRoute(
        path:languageSelection,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LanguagesSelectionView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path:onBoarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: loginSignUp,
        builder: (context, state) => const LoginSignUpView(),
      ),

      GoRoute(
        path: login,
        builder: (context, state) => const LoginView(),
      ),

      GoRoute(
        path: otpVerify,
        builder: (context, state) => const OtpVerifyView(),
      ),

      GoRoute(
        path: tellUsAbout,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TellUsAboutView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: allCategory,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AllCategoryView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: workAddress,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WorkAddressView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: seeAllTransaction,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SeeAllTransactionsView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: dashboard,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const DashboardView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: jobDetail,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: JobDetailView(jobData: state.extra as JobModel),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: notifications,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationsView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),
   GoRoute(
        path: addMoney,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isWithdraw = extra != null && extra['isWithdraw'] == true;
          return CustomTransitionPage(
            key: state.pageKey,
            child: AddMoneyView(isWithdraw: isWithdraw),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              );
            },
          );
        },
      ),

      GoRoute(
        path: notificationSettings,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationSettingsView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: savedJob,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SavedJobView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: myPayment,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MyPaymentView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: notificationDetail,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const NotificationDetailView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: profileDetails,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileDetailsPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: editProfile,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const EditProfileView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: trainingCertification,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const TrainingCertificationPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: quiz,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const QuizView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: '/see-all-transactions',
        builder: (context, state) => const SeeAllTransactionsView(),
      ),

      GoRoute(
        path: chat,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: ChatView(
            customerName: (state.extra as Map<String, dynamic>)['customerName'] ?? '',
            customerAddress: (state.extra as Map<String, dynamic>)['customerAddress'] ?? '',
            customerAvatarUrl: (state.extra as Map<String, dynamic>)['customerAvatarUrl'] ?? '',
            jobType: (state.extra as Map<String, dynamic>)['jobType'] ?? '',
            jobDateTime: (state.extra as Map<String, dynamic>)['jobDateTime'] ?? '',
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

      GoRoute(
        path: jobNavigation,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: JobNavigationView(
            address: (state.extra as Map<String, dynamic>)['address'] ?? '',
            time: (state.extra as Map<String, dynamic>)['time'] ?? '',
            userName: (state.extra as Map<String, dynamic>)['userName'] ?? '',
            userAddress: (state.extra as Map<String, dynamic>)['userAddress'] ?? '',
            userAvatarUrl: (state.extra as Map<String, dynamic>)['userAvatarUrl'] ?? '',
            onCall: () {},
            onMessage: () {},
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          },
        ),
      ),

    ],
    redirect: (context, state) {
      if (state.matchedLocation == '/') {
        return null;
      }

      //final authProvider = Provider.of<AuthProvider>(context, listen: false);
      //final isLoggedIn = authProvider.isLoggedIn;
       final isLoginRoute = state.matchedLocation == '/login-signup';
      //
     /* if (!isLoggedIn && !isLoginRoute) {
        return '/login-signup';
      }*/

     /* if (isLoggedIn && isLoginRoute) {
        return '/dashboard';
      }*/

      return null;
    },
  );


}