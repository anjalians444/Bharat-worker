// Updated BookingPage with new UI layout matching the reference image
import 'package:bharat_worker/models/booking_job_model.dart';

import 'package:bharat_worker/view/widgets/booking_job_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../constants/font_style.dart';
import '../../constants/my_colors.dart';
import '../../constants/sized_box.dart';
import '../../helper/common.dart';
import '../../helper/router.dart';
import '../../provider/language_provider.dart';
import '../../provider/booking_jobs_provider.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({Key? key}) : super(key: key);

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final List<ScrollController> _scrollControllers =
      List.generate(4, (_) => ScrollController());
  int? _selectedJobIndex;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Listen to tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedTabIndex = _tabController.index;
        });
      }
    });

    // Fetch booking jobs for all tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingJobsProvider =
          Provider.of<BookingJobsProvider>(context, listen: false);
      // Only fetch if we don't have data already
      // if (bookingJobsProvider.bookingJobs.isEmpty) {
      bookingJobsProvider.fetchBookingJobs();
      // }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    // Dispose scroll controllers
    // for (var controller in _scrollControllers) {
    //   controller.dispose();
    // }
    super.dispose();
  }

  void _refreshData() {
    final bookingJobsProvider =
        Provider.of<BookingJobsProvider>(context, listen: false);
    // Refresh data silently in background without showing loader
    bookingJobsProvider.fetchBookingJobsSilently();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    // Scroll to selected job when returning from detail page

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(
        () => Navigator.pop(context),
        'Booking',
        isLeading: false,
        actions: [
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
            indicatorWeight: 2.0,
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
                        hintText:
                            languageProvider.translate('search_service_hint'),
                        hintStyle: regularTextStyle(
                            fontSize: 14.0, color: Colors.grey),
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
                _BookingJobsList(
                  onJobTap: _onJobTap,
                  scrollController: _scrollControllers[0],
                ),
                _BookingJobsList(
                  onJobTap: _onJobTap,
                  scrollController: _scrollControllers[1],
                ),
                _BookingJobsList(
                  onJobTap: _onJobTap,
                  scrollController: _scrollControllers[2],
                ),
                _BookingJobsList(
                  onJobTap: _onJobTap,
                  scrollController: _scrollControllers[3],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onJobTap(BookingJob job) {
    // Store the selected job index for this tab
    // final bookingJobsProvider =
    //     Provider.of<BookingJobsProvider>(context, listen: false);
    //
    // print("Job tapped: ${job.title} with ID: ${job.id}");
    // print("Current tab index: ${_tabController.index}");
    // print("Total jobs in list: ${bookingJobsProvider.bookingJobs.length}");
    //
    // // Debug: Print all job IDs in the list
    // for (int i = 0; i < bookingJobsProvider.bookingJobs.length; i++) {
    //   print(
    //       "Job $i: ${bookingJobsProvider.bookingJobs[i].title} - ID: ${bookingJobsProvider.bookingJobs[i].id}");
    // }
    //
    // final jobIndex = bookingJobsProvider.bookingJobs.indexWhere((j) => j.id == job.id);
    // print("Found job at index: $jobIndex");
    //
    // if (jobIndex != -1) {
    //   setState(() {
    //     _selectedJobIndex = jobIndex;
    //     _selectedTabIndex = _tabController.index;
    //   });
    //   print(
    //       "Stored selected job index: $_selectedJobIndex for tab: $_selectedTabIndex");
    // } else {
    //   print("Job not found in list! Trying alternative search...");
    //   // Try alternative search methods
    //   final altIndex1 = bookingJobsProvider.bookingJobs
    //       .indexWhere((j) => j.title == job.title);
    //   final altIndex2 = bookingJobsProvider.bookingJobs
    //       .indexWhere((j) => j.id.toString() == job.id.toString());
    //   print("Alternative search 1 (by title): $altIndex1");
    //   print("Alternative search 2 (by ID string): $altIndex2");
    //
    //   // Use alternative search if primary failed
    //   final finalIndex =
    //       altIndex1 != -1 ? altIndex1 : (altIndex2 != -1 ? altIndex2 : -1);
    //   if (finalIndex != -1) {
    //     setState(() {
    //       _selectedJobIndex = finalIndex;
    //       _selectedTabIndex = _tabController.index;
    //     });
    //     print("Used alternative search, stored index: $_selectedJobIndex");
    //   }
    // }

    // Navigate to job detail and refresh data when returning
    context.push(AppRouter.jobDetail, extra: job).then((_) {
      // Refresh data when returning from job detail page
      _refreshData();
    });
  }
}

class _BookingJobsList extends StatelessWidget {
  final Function(BookingJob) onJobTap;
  final ScrollController? scrollController;

  const _BookingJobsList(
      {Key? key, required this.onJobTap, this.scrollController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingJobsProvider>(
      builder: (context, bookingJobsProvider, child) {
        if (bookingJobsProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (bookingJobsProvider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${bookingJobsProvider.errorMessage}',
                  style: TextStyle(color: Colors.red),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => bookingJobsProvider.fetchBookingJobs(),
                  child: Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (bookingJobsProvider.bookingJobs.isEmpty) {
          return const Center(
            child: Text('No jobs found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await bookingJobsProvider.fetchBookingJobs();
          },
          child: ListView.builder(
            //  controller: scrollController,
            itemCount: bookingJobsProvider.bookingJobs.length,
            padding: const EdgeInsets.only(left: 16, right: 16, top: 0),
            itemBuilder: (context, index) {
              final bookingJob = bookingJobsProvider.bookingJobs[index];
              return BookingJobCard(
                bookingJob: bookingJob,
                onBookmarkTap: () {},
                onTap: () => onJobTap(bookingJob),
              );
            },
          ),
        );
      },
    );
  }
}
