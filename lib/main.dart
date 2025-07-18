import 'dart:io';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/auth_provider.dart';
import 'package:bharat_worker/provider/chat_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/provider/subscription_provider.dart';
import 'package:bharat_worker/services/chat_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'provider/language_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:bharat_worker/provider/category_provider.dart';
import 'package:bharat_worker/provider/work_address_provider.dart';
import 'package:bharat_worker/provider/training_provider.dart';
import 'package:bharat_worker/provider/quiz_provider.dart';
import 'package:bharat_worker/provider/payment_provider.dart';

late ChatServices chatServices;
void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Platform.isAndroid) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyBzH53Nqcs0NtZUF5FKVTLsKIZGOvSkLpM',
          appId: '1:238904276518:android:7ea76e2e360e958d1718e7',
          messagingSenderId: '238904276518',
          projectId: 'bharat-worker-ff0c4',
          storageBucket: 'bharat-worker-ff0c4.firebasestorage.app',
        ),
      );
    } else if (Platform.isIOS) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyACd2C3muhwy3l03xy7_-t29lfwv-swoOk',
          appId: '1:416464642519:ios:4f900fc1992f06051c2b92',
          messagingSenderId: '416464642519',
          projectId: 'babella-753f1',
          storageBucket: 'babella-753f1.firebasestorage.app',
          iosClientId: '416464642519-3rs6v6j7uqs5kk9a9net9i1n0gn7t3sn.apps.googleusercontent.com',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  // For Android & iOS: Set bar colors and icon brightness
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark, // iOS specific
      systemNavigationBarColor: Colors.white, // Android specific
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => WorkAddressProvider()),
        ChangeNotifierProvider(create: (_) => TrainingProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
        ChangeNotifierProvider(
          create: (_) => ChatProvider(
            chatServices: ChatServices(
              firebaseFirestore: firebaseFirestore,
              firebaseStorage: firebaseStorage,
            ),
          ),
        ),
        // Remove Provider<ChatServices> unless you use it elsewhere
      ],
      child:
      // DevicePreview(
      //   enabled: !kReleaseMode,
      //   builder: (context) => MyApp(), // Wrap your app
      // ),
       const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
       // themeMode: themeProvider.themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.green,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.green,
        ),
        locale: languageProvider.locale,
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('hi', 'IN'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    );
  }
}

