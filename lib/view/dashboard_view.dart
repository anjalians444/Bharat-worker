import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/view/pages/booking_page.dart';
import 'package:bharat_worker/view/pages/explore_page.dart';
import 'package:bharat_worker/view/pages/home_page.dart';
import 'package:bharat_worker/view/pages/message_page.dart';
import 'package:bharat_worker/view/pages/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const BookingPage(),
    const ExplorePage(),
    const MessagePage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: MyColors.appTheme,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: mediumTextStyle(fontSize: 12.0, color: MyColors.appTheme),
          unselectedLabelStyle: mediumTextStyle(fontSize: 12.0, color: Colors.grey),
          items: [
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _currentIndex == 0 ?MyAssetsPaths.filHome:  MyAssetsPaths.home,
                width: 24,
                height: 24,
              ),
              label: languageProvider.translate('home'),
            ),
            BottomNavigationBarItem(
              icon:SvgPicture.asset(
                _currentIndex == 1 ?MyAssetsPaths.fillBooking:  MyAssetsPaths.booking,
                width: 24,
                height: 24,
              ),
              label: languageProvider.translate('booking'),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _currentIndex == 2 ?MyAssetsPaths.fillExplore:    MyAssetsPaths.radar,
                width: 24,
                height: 24,
              ),
              label: languageProvider.translate('explore'),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _currentIndex == 3 ?MyAssetsPaths.fillMessage:  MyAssetsPaths.message,
                width: 24,
                height: 24,

              ),
              label: languageProvider.translate('message'),
            ),
            BottomNavigationBarItem(
              icon: SvgPicture.asset(
                _currentIndex == 4 ?MyAssetsPaths.fillSetting: MyAssetsPaths.setting,
                width: 24,
                height: 24,

              ),
              label: languageProvider.translate('settings'),
            ),
          ],
        ),
      ),
    );
  }
} 