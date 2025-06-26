// Updated BookingPage with new UI layout matching the reference image
import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/models/job_model.dart';
import 'package:bharat_worker/view/widgets/job_match.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../constants/font_style.dart';
import '../../constants/my_colors.dart';
import '../../constants/sized_box.dart';
import '../../helper/common.dart';
import '../../helper/router.dart';
import '../../provider/language_provider.dart';
import '../../widgets/common_job_card.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Sample job data for demonstration
  // Move jobs list to state

  final List<JobModel> _jobs = [
    JobModel(
      icon: MyAssetsPaths.ac,
      title:'Tap Repair in Kitchen',
      location:  'Dhakoli, Sector 5',
      date: 'Tomorrow',
      time: '9:30 AM – 10:30 AM',
      distance: '6 km',
      desc: 'Kitchen tap leaking; bring washer and tools.',
      timeAgo: '2 hours ago',
      applicants: '8 Applicants',
      price: '₹850',
      bookmarked: false,
      status: 'Accepted',
      badge: 'Accepted',
      badgeColor: MyColors.color1056BD,
    ),
    JobModel(
      icon: MyAssetsPaths.ac,
      title:'Drain Blockage Fix',
      location: 'VIP Road, Zirakpur',
      date:'Today',
      time: '9:30 AM – 10:30 AM',
      distance: '6 km',
      desc: 'Bathroom drain blocked; may need pipe cleaning tool.',
      timeAgo: '2 hours ago',
      applicants: '8 Applicants',
      price: '₹850',
      bookmarked: false,
      status: 'Cancelled',
      badge: 'Cancelled',
      badgeColor: MyColors.redColor,
    ), JobModel(
      icon: MyAssetsPaths.ac,
      title: '1.5 Ton Split AC',
      location:  'Sector 21, Panchkula',
      date: 'Tomorrow',
      time: '9:30 AM – 10:30 AM',
      distance: '6 km',
      desc: '1-ton window AC, seasonal cleaning.',
      timeAgo: '2 hours ago',
      applicants: '8 Applicants',
      price: '₹850',
      bookmarked: false,
      status: 'Paused',
      badge: 'Paused',
      badgeColor: MyColors.colorFFCA15,
    ),
    JobModel(
      icon: MyAssetsPaths.beauty,
      title: 'Tap Repair in Kitchen',
      location:  'VIP Road, Zirakpur',
      date: 'Tomorrow',
      time: '9:30 AM – 10:30 AM',
      distance: '6 km',
      desc: 'Kitchen tap leaking; bring washer and tools.',
      timeAgo: '2 hours ago',
      applicants: '8 Applicants',
      price: '₹850',
      bookmarked: false,
      status: 'On the Way',
      badge: 'On the Way',
      badgeColor: MyColors.colorOrange,
    ),
 /*   {
      'title': 'Tap Repair in Kitchen',
      'location': 'VIP Road, Zirakpur',
      'date': 'Tomorrow',
      'time': '9:30 AM – 10:30 AM',
      'distance': '6 km',
      'status': 'Accepted',
      'description': 'Kitchen tap leaking; bring washer and tools.',
      'applicants': '8',
      'price': '₹1150',
      'badge': 'Accepted',
      'badgeColor': MyColors.greenColor,
    },
    {
      'title': 'Drain Blockage Fix',
      'location': 'Dhakoli, Sector 5',
      'date': 'Today',
      'time': '3:00 PM – 4:00 PM',
      'distance': '6 km',
      'status': 'Cancelled',
      'description': 'Bathroom drain blocked; may need pipe cleaning tool.',
      'applicants': '8',
      'price': '₹1150',
      'badge': 'Cancelled',
      'badgeColor': MyColors.redColor,
    },
    {
      'title': '1.5 Ton Split AC',
      'location': 'Sector 21, Panchkula',
      'date': 'Today',
      'time': '6:00 PM – 7:00 PM',
      'distance': '6 km',
      'status': 'Paused',
      'description': '1-ton window AC, seasonal cleaning.',
      'applicants': '8',
      'price': '₹1150',
      'badge': 'Paused',
      'badgeColor': Colors.orange,
    },*/
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(
            () => Navigator.pop(context),
        'Booking',
        actions: [
          InkWell(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: MyColors.borderColor),
                    borderRadius: BorderRadius.circular(12)
                ),
                padding: EdgeInsets.all(10),
                child: Icon(Icons.bookmark_border, color: Colors.black)),
            onTap: () {
              context.push(AppRouter.savedJob);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
           // isScrollable: true,
            labelColor: MyColors.appTheme,
            padding: EdgeInsets.symmetric(horizontal: 5),
            labelPadding: EdgeInsets.symmetric(horizontal: 2),
            unselectedLabelColor: Colors.grey,
            indicatorColor: MyColors.appTheme,
            indicatorWeight:2.0 ,
            dividerColor: MyColors.borderColor,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Ongoing'),
              Tab(text: 'Previous'),
              Tab(text: 'Bid'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  hsized12,
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: languageProvider.translate('search_service_hint'),
                        hintStyle: regularTextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _JobList(jobs: _jobs, onJobTap: _onJobTap),
                _RunningJobList(jobs: _jobs, onJobTap: _onJobTap),
                _JobList(jobs: _jobs, onJobTap: _onJobTap),
                _JobList(jobs: _jobs, onJobTap: _onJobTap),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onJobTap(JobModel job) {
    context.push(AppRouter.jobDetail, extra: job);
  }
}

class _JobList extends StatelessWidget {
  final List<JobModel> jobs;
  final Function(JobModel) onJobTap;

  const _JobList({Key? key, required this.jobs, required this.onJobTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (jobs.isEmpty) {
      return const Center(child: Text('No jobs found'));
    }
    return ListView.builder(
      itemCount: jobs.length,
      padding: const EdgeInsets.only(left: 16,right: 16,top:0),
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
          onBookmarkTap: () => toggleBookmark(index),
          onTap: () => onJobTap(job),
        );

       /*   CommonJobCard(
          title: job['title'],
          location: job['location'],
          date: job['date'],
          time: job['time'],
          price: job['price'],
          distance: job['distance'],
          applicants: job['applicants'],
          badgeText: job['badge'],
          badgeColor: job['badgeColor'],
          description: job['description'],
          onTap: () => onJobTap(job),
        );*/
      },
    );
  }
  void toggleBookmark(int index) {
   // setState(() {
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
   // });
  }
}

class _RunningJobList extends StatelessWidget {
  final List<JobModel> jobs;
  final Function(JobModel) onJobTap;

  const _RunningJobList({Key? key, required this.jobs, required this.onJobTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filter jobs for running statuses
    final runningJobs = jobs.where((job) =>
      job.status == 'On the Way' || job.status == 'Paused' || job.status == 'Started').toList();
    if (runningJobs.isEmpty) {
      return const Center(child: Text('No running jobs found'));
    }
    return ListView.builder(
      itemCount: runningJobs.length,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
      itemBuilder: (context, index) {
        final job = runningJobs[index];
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
          onBookmarkTap: () {},
          onTap: () => onJobTap(job),
        );
      },
    );
  }
}
