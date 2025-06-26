import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bharat_worker/models/job_model.dart';
import 'package:bharat_worker/view/widgets/job_match.dart';

import '../../helper/common.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  TextEditingController _searchController = TextEditingController();
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
      bookmarked: true,
      status: '',
      badge: null,
      badgeColor: null,
    ),
    JobModel(
      icon: MyAssetsPaths.beauty,
      title: 'Tap Repair in Kitchen',
      location: 'Zirakpur, VIP Road',
      date: 'Tomorrow',
      time: '9:30 AM – 10:30 AM',
      distance: '6 km',
      desc: 'Kitchen tap leaking; bring washer and tools.',
      timeAgo: '2 hours ago',
      applicants: '12 Applicants',
      price: '₹900',
      bookmarked: false,
      status: '',
      badge: null,
      badgeColor: null,
    ),
    JobModel(
      icon: MyAssetsPaths.ac,
      title: 'Drain Blockage Fix',
      location: 'Sector 20, Panchkula',
      date: 'Today',
      time: '3:00 PM – 4:00 PM',
      distance: '6 km',
      desc: 'Bathroom drain blocked; may need pipe cleaning tool.',
      timeAgo: '2 hours ago',
      applicants: '5 Applicants',
      price: '₹700',
      bookmarked: false,
      status: '',
      badge: null,
      badgeColor: null,
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
        bookmarked: !jobs[index].bookmarked,
        status: jobs[index].status,
        badge: jobs[index].badge,
        badgeColor: jobs[index].badgeColor,
      );
    });
  }

  void onJobTap(JobModel job) {
    // Implement navigation or details logic here
    // For now, just show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Tapped on: ' + job.title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(() {
        // Navigator.pop(context);
      }, 'Explore Jobs', actions: [
        InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: MyColors.borderColor),
                  borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.all(10),
              child: Icon(Icons.bookmark_border, color: Colors.black)),
          onTap: () {
            context.push(AppRouter.savedJob);
          },
        ),
      ]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          hsized35,
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 0),

            child: Row(
              children: [
                Expanded(
                  child: CommonTextField(
                    controller: _searchController,
                    borderRadius: 40,
                    borderColor: Color(0xFFEEEEEE),
                    hintText:  'Find jobs by service, area, or time...',
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: SvgPicture.asset(
                        MyAssetsPaths.searchIcon,color: MyColors.lightText,
                      ),
                    ),
                  ),
                ),
                wsized10,
                Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: MyColors.borderColor),
                        shape: BoxShape.circle
                    ),
                    padding: EdgeInsets.all(13),
                    child: SvgPicture.asset(MyAssetsPaths.filterIcon,height: 24,width: 24,))
              ],
            ),
          ),
       /*   Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                        color: MyColors.colorFAFAFA,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: MyColors.borderColor, blurRadius: 1)
                        ]),
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          MyAssetsPaths.searchIcon,
                          height: 15,
                          width: 15,
                          color: MyColors.color08151F.withOpacity(0.60),
                        ),
                        SizedBox(
                          width: 6,
                        ),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: languageProvider.translate(
                                  'Find jobs by service, area, or time...'),
                              hintStyle: regularTextStyle(
                                  fontSize: 14.0,
                                  color:
                                      MyColors.color08151F.withOpacity(0.60)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  child: Container(
                      decoration: BoxDecoration(
                          color: MyColors.colorFAFAFA,
                          boxShadow: [
                            BoxShadow(
                                color: MyColors.borderColor, blurRadius: 1)
                          ],
                          border: Border.all(color: MyColors.borderColor),
                          borderRadius: BorderRadius.circular(200)),
                      padding: EdgeInsets.all(13),
                      child: SvgPicture.asset(
                        MyAssetsPaths.filterIcon,
                        height: 24,
                        width: 24,
                      )),
                  onTap: () {
                    //  context.push(AppRouter.notifications);
                  },
                ),
              ],
            ),
          ),*/

          hsized8,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical:16),
            child:  heading('Job Match With You (${jobs.length})'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: jobs.length,
              padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return JobMatchCard(
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
                  isStatus: true,
                  badgeText: job.badge,
                  badgeColor: job.badgeColor,
                  status: job.status,
                  bottom: 10.0,
                  onBookmarkTap: () => toggleBookmark(index),
                  onTap: () => onJobTap(job),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
