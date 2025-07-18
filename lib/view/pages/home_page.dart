import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/provider/profile_provider.dart';
import 'package:bharat_worker/view/widgets/job_match.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../constants/assets_paths.dart';
import '../../models/job_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Move jobs list to state
  List<JobModel> jobs = [
    JobModel(
      icon: MyAssetsPaths.ac,
      title: '1.5 Ton Split AC',
      location: 'Dhakoli, Sector 7',
      date: 'Today',
      time: '6:00 PM – 7:00 PM',
      distance: '6 km',
      desc: '1-ton window AC, seasonal cleaning.',
      timeAgo: '2 hours ago',
      applicants: '8 Applicants',
      price: '₹850',
      bookmarked: false,
      status: '',
    ),
    JobModel(
      icon: MyAssetsPaths.beauty,
      title: 'Tap Repair',
      location: 'Zirakpur',
      date: 'Tomorrow',
      time: '10:00 AM – 11:00 AM',
      distance: '4 km',
      desc: 'Kitchen tap leakage repair.',
      timeAgo: '2 hours ago',
      applicants: '5 Applicants',
      price: '₹400',
      bookmarked: false,
      status: ''
    ),
  ];

  void toggleBookmark(int index) {
    setState(() {
      jobs[index] = JobModel(
        icon: jobs[index].icon,
        title: jobs[index].title,
        location: jobs[index].location,
        date: jobs[index].date,
        time: jobs[index].time,
        distance: jobs[index].distance,
        desc: jobs[index].desc,
        timeAgo: jobs[index].timeAgo,
        applicants: jobs[index].applicants,
        price: jobs[index].price,
        bookmarked: !jobs[index].bookmarked, status: '',
      );
    });
  }
  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration.zero,(){
    //   final profileProvider = Provider.of<ProfileProvider>(context);
    //   profileProvider.getProfileData();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    return Scaffold(
      backgroundColor: MyColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius:23,
                          backgroundColor: MyColors.appTheme,
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: CircleAvatar(
                              radius: 23,
                              backgroundColor: Colors.white,
                              child: ClipRRect(
                                  borderRadius: BorderRadius.circular(500),
                                  child: Image.network(profileProvider.profileImageUrl.toString())),
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: MyColors.appTheme,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(Icons.emoji_events, color: Colors.white, size: 12),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(width: 10,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Hi, ${profileProvider.name.split(" ").first}!",
                                style: mediumTextStyle(fontSize: 18.0, color: MyColors.darkText),
                              ),
                              Text(
                                "👋",
                                style: TextStyle(fontSize: 18.0),
                              ),
                            ],
                          ),
                          hsized5,
                          Row(
                            children: [
                              Text(
                                "Jaipur, Rajasthan",
                                style: regularTextStyle(fontSize: 12.0, color:MyColors.darkText),
                              ),
                              Icon(Icons.arrow_drop_down_rounded, color:MyColors.darkText,size: 16,),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10,),
                    Row(
                      children: [

                        // Points Badge
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "BRONZE",
                              style: mediumTextStyle(fontSize: 13.0, color: MyColors.appTheme),
                            ),

                            SizedBox(height: 2,),
                            Text(
                              "100 POINTS",
                              style: mediumTextStyle(fontSize: 11.0, color:MyColors.color7A849C),
                            ),
                          ],
                        ),
                        SizedBox(width: 10,),

                        InkWell(
                          child: Container(
                              decoration: BoxDecoration(
                                  color: MyColors.bg,
                                  border: Border.all(color: MyColors.borderColor),
                                  borderRadius: BorderRadius.circular(12)
                              ),
                              padding: EdgeInsets.all(10),
                              child:  SvgPicture.asset(MyAssetsPaths.notificationIcon)),
                          onTap: () {
                            context.push(AppRouter.notifications);
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),


             hsized8,

              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(color: MyColors.borderColor,blurRadius: 5)
                          ]
                        ),
                        child: Row(
                          children: [
                            SvgPicture.asset(MyAssetsPaths.searchIcon,height: 15,width: 15,color: MyColors.color08151F.withOpacity(0.60),),
                           SizedBox(width: 6,),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: languageProvider.translate('search_service_hint'),
                                  hintStyle: regularTextStyle(fontSize: 14.0, color:MyColors.color08151F.withOpacity(0.60)),
                                ),
                              ),
                            ),
                      
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 10,),
                    InkWell(
                      child: Container(
                          decoration: BoxDecoration(
                              color: MyColors.whiteColor,
                              border: Border.all(color: MyColors.borderColor),
                              borderRadius: BorderRadius.circular(200),
                              boxShadow: [
                                BoxShadow(color: MyColors.borderColor,blurRadius: 5)
                              ]
                          ),
                          padding: EdgeInsets.all(13),
                          child:  SvgPicture.asset(MyAssetsPaths.filterIcon,height: 24,width: 24,)),
                      onTap: () {
                        context.push(AppRouter.notifications);
                      },
                    ),
                  ],
                ),
              ),

              // Quick Jobs Banner
              hsized25,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:24.0),
                child: Container(
                  width: double.infinity,
                  //padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: MyColors.appTheme,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                  // alignment: Alignment.bottomRight,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal:20,vertical: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Find Quick Jobs\nNear You",
                              style: boldTextStyle(fontSize: 22.0, color: Colors.white),
                            ),
                            hsized8,
                            Text(
                              "No waiting. No hassle.\nJust accept, serve, and earn.",
                              style: regularTextStyle(fontSize: 12.0, color: Colors.white.withOpacity(0.8)),
                            ),
                            hsized20,
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.yellow,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "Read More",
                                style: semiBoldTextStyle(fontSize: 16.0, color:MyColors.darkText),
                              ),
                            ),
                          ],
                        ),
                      ),


                      Container(
                        padding: EdgeInsets.only(left: 40),
                        alignment: Alignment.bottomRight,
                        child: Image.asset(
                          MyAssetsPaths.deliveryBoy,
                         // width:243,
                          height:231,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile Completion Card
          if (!profileProvider.isProfileComplete ) ...[

            hsized25,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal:24.0,),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color:MyColors.borderColor),
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: MyColors.appTheme.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(8)
                          ),
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.perm_identity_rounded, color: MyColors.lightText,size: 24,),
                        ),
                        SizedBox(width: 12,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Complete your profile!",
                                style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                              ),
                              hsized2,
                              Text(
                                "Your profile has complete ${profileProvider.partner!.profileCompletion??0}%",
                                style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, color:MyColors.darkText.withOpacity(0.80),size: 24,),
                      ],
                    ),
                    hsized12,
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.7,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(MyColors.greenColor),
                        minHeight:5,
                      ),
                    ),
                  ],
                ),
              ),
            )
            ],

              // Running Job Section
        if (profileProvider.isProfileComplete ) ...[
              hsized25,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    heading("Running Job"),

                    hsized12,
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MyColors.appTheme,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Image.asset(
                                  MyAssetsPaths.ac,
                                  height: 28,
                                  width: 28,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '1.5 Ton Split AC',
                                      style: mediumTextStyle(fontSize: 16.0, color: Colors.white),
                                    ),
                                    hsized4,
                                    Text(
                                      'House No. 102, Sector 22, Chandigarh',
                                      style: regularTextStyle(fontSize: 13.0, color: Colors.white.withOpacity(0.90)),
                                    ),
                                    hsized2,
                                    Row(
                                      children: [
                                        Text(
                                          'Today',
                                          style: regularTextStyle(fontSize: 12.0, color: Colors.white.withOpacity(0.90)),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          ' - 11:00 AM – 12:00 PM',
                                          style: regularTextStyle(fontSize: 12.0, color: Colors.white.withOpacity(0.85)),
                                        ),
                                      ],
                                    ),

                                    hsized5,
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical:3),
                                          decoration: BoxDecoration(
                                            color: MyColors.colorOrange,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Row(
                                            children: [
                                              Text(
                                                'On the Way',
                                                style: mediumTextStyle(fontSize: 14.0, color: Colors.white),
                                              ),
                                              Icon(Icons.arrow_drop_down, color: Colors.white),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          hsized16,
                          Row(
                           // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: buttons('Message')
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right:6.0),
                                child: buttons('Navigate')
                              ),
                              buttons( 'Mark Complete'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              ],
              // Today's Summary
              hsized25,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal:24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    heading("Today's Summary"),

                    hsized16,
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: "2",
                            subtitle: "Jobs Accepted",
                          ),
                        ),
                       SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: "₹850",
                            subtitle: "Earnings Today",
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: "4.7",
                            subtitle: "Jobs Rating",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Job Matches
              hsized25,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Job Match With You (5)",
                      style: semiBoldTextStyle(fontSize:18.0, color: MyColors.blackColor),
                    ),
                    Text(
                      "View more",
                      style: mediumTextStyle(fontSize: 14.0, color: MyColors.appTheme),
                    ),
                  ],
                ),
              ),

              hsized16,
              // Job List
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 19),
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:List.generate(jobs.length, (int index){
                    final job = jobs[index];
                    return Container(
                      margin: EdgeInsets.only(right: 5,left: 5),
                      width: 330,
                        child: JobMatchCard(
                        iconPath: job.icon,
                        title: job.title,
                        location: job.location,
                        date: job.date,
                        time: job.time,
                        distance: job.distance,
                        desc: job.desc,
                        timeAgo: job.timeAgo,
                        applicants: job.applicants,
                        price: job.price,
                        bookmarked: job.bookmarked,
                        onBookmarkTap: () => toggleBookmark(index),
                          onTap: () => _onJobTap(job),
                      ),
                    );
                  }),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
  void _onJobTap(JobModel job) {
    context.push(AppRouter.jobDetail, extra: job);
  }

  buttons(String text) {
    return Container(
      padding: EdgeInsets.symmetric(vertical:7,horizontal:11),
      decoration: BoxDecoration(
        color: Color(0xFFF0F1F4),
        borderRadius: BorderRadius.circular(6)
      ),
      child: Text(
        text,
        style: mediumTextStyle(
            fontSize:14.0,
            color:MyColors.darkText
        ),
      ),
    );

      CommonButton(
      text:text,
      onTap: () {},
      backgroundColor: Colors.white,
      textColor: MyColors.darkText,
      borderColor: MyColors.borderColor,
      fontSize:13.0,
      borderRadius: 6,
      width: 0,
      padding: EdgeInsets.symmetric(vertical:7,horizontal:10),
      margin: EdgeInsets.zero,
    );
  }


}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SummaryCard({
    Key? key,
    required this.title,
    required this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: MyColors.borderColor,width: 0.5),
        boxShadow: [
          BoxShadow(color: MyColors.bg,blurRadius: 2)
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: boldTextStyle(fontSize: 20.0, color: MyColors.blackColor),
          ),
          hsized4,
          Text(
            subtitle,
            style: mediumTextStyle(fontSize: 14.0, color:MyColors.lightText),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}



