import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/models/booking_job_model.dart';
import 'package:bharat_worker/provider/booking_jobs_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:bharat_worker/widgets/edit_job_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/job_provider.dart';
import '../widgets/common_success_dialog.dart';
import 'package:go_router/go_router.dart';
import '../helper/router.dart';

class JobDetailView extends StatefulWidget {
  final BookingJob jobData;

  const JobDetailView({
    Key? key,
    required this.jobData,
  }) : super(key: key);

  @override
  State<JobDetailView> createState() => _JobDetailViewState();
}

class _JobDetailViewState extends State<JobDetailView> {
  bool _jobCancelled = false;
  // String keys for popup menu
  final String keyNavigateToJob = 'navigate_to_job';
  final String keyAddExtraWork = 'add_extra_work';
  final String keyCancelJob = 'cancel_job';

  String _getTimeAgo(String createdAt) {
    try {
      final createdTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(createdTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} days ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hours ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minutes ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return '2 hours ago'; // Default fallback
    }
  }

  @override
  void initState() {
    super.initState();
    // Fetch booking jobs for all tabs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingJobsProvider =
          Provider.of<BookingJobsProvider>(context, listen: false);
      bookingJobsProvider.fetchJobDetail(widget.jobData.id.toString());
    });
  }

  @override
  void dispose() {
    // Clear job detail when widget is disposed
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   final bookingJobsProvider =
    //       Provider.of<BookingJobsProvider>(context, listen: false);
    //   bookingJobsProvider.clearJobDetail();
    // });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final jobProvider = Provider.of<BookingJobsProvider>(context);
    BookingJob jobData = jobProvider.jobModel;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar(
        () {
          Navigator.of(context).pop();
        },
        languageProvider.translate('job_detail'),
        bg: MyColors.appTheme.withOpacity(0.01),
        actions: [
          InkWell(
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: MyColors.borderColor),
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.all(10),
                child: Icon(
                  jobData.status == "completed"
                      ? Icons.bookmark_border
                      : Icons.more_vert_sharp,
                  size: 24,
                )),
            onTap: () async {
              if (jobData.status == "completed") return;
              final RenderBox overlay =
                  Overlay.of(context).context.findRenderObject() as RenderBox;
              final result = await showMenu<String>(
                context: context,
                color: Colors.white,
                position:
                    RelativeRect.fromLTRB(100, 80, 0, 0), // Adjust as needed
                items: [
                  PopupMenuItem(
                    value: keyNavigateToJob,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          MyAssetsPaths.navigation,
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(width: 10),
                        Text('Navigate to Job',
                            style: mediumTextStyle(
                                color: MyColors.blackColor, fontSize: 14.0)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: keyAddExtraWork,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          MyAssetsPaths.newJobRequestIcon,
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(width: 10),
                        Text('Add Extra Work',
                            style: mediumTextStyle(
                                color: MyColors.blackColor, fontSize: 14.0)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: keyCancelJob,
                    child: Row(
                      children: [
                        SvgPicture.asset(
                          MyAssetsPaths.jobCancelledIcon,
                          height: 16,
                          width: 16,
                        ),
                        SizedBox(width: 10),
                        Text('Cancel Bid',
                            style: mediumTextStyle(
                                color: MyColors.redColor, fontSize: 14.0)),
                      ],
                    ),
                  ),
                ],
                elevation: 8.0,
              );
              if (result == keyAddExtraWork) {
                _showAddExtraWorkDialog(context);
              }
              if (result == keyNavigateToJob) {
                context.push(
                  AppRouter.jobNavigation,
                  extra: {
                    'address':
                        jobData.fullAddress ?? 'Flat 305, Sector 11, Panchkula',
                    'time': '5 min',
                    'userName': jobData.contactName ?? 'Ravi Malhotra',
                    'userAddress':
                        jobData.fullAddress ?? 'Flat 305, Sector 11, Panchkula',
                    'userAvatarUrl':
                        'https://randomuser.me/api/portraits/men/1.jpg',
                  },
                );
              }
              // Handle other keys as needed
            },
          ),
        ],
      ),
      body: jobProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : jobProvider.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${jobProvider.errorMessage}',
                        style: TextStyle(color: Colors.red),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => jobProvider
                            .fetchJobDetail(widget.jobData.id.toString()),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Job Header
                      _buildJobHeader(languageProvider, jobData),
                      hsized25,

                      jobData.status == 'accepted' || jobData.status == 'open'
                          ? acceptedStatus(context, languageProvider, jobData,
                              jobProvider.bidModel)
                          : completeStatus(languageProvider, jobData),
                    ],
                  ),
                ),
      bottomNavigationBar: _jobCancelled ||
              jobData.status == "on_the_way" ||
              jobData.status == "started"
          ? _buildAfterCancelBottomBar(languageProvider, jobData)
          : (jobData.status == 'accepted' || jobData.status == 'open'
              ? jobProvider.bidModel == null
                  ? _buildBidButtonBottomBar(
                      context, languageProvider, jobData, jobProvider)
                  : _buildAcceptedBottomBar(
                      context, languageProvider, jobData, jobProvider)
              : SizedBox.shrink()),
      //_buildDefaultBottomBar(languageProvider)),
    );
  }

  Widget _buildAfterCancelBottomBar(
      LanguageProvider languageProvider, BookingJob jobData) {
    return Wrap(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                  child: CommonButton(
                text: languageProvider.translate(
                    jobData.status == "on_the_way" ||
                            jobData.status == "started"
                        ? "markComplete"
                        : 'start_job'),
                onTap: () {
                  if (jobData.status == "started") {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => CommonSuccessDialog(
                        image: SvgPicture.asset(MyAssetsPaths.successSvg,
                            height: 120, width: 120),
                        title:
                            languageProvider.translate('job_completed_success'),
                        subtitle: languageProvider
                            .translate('job_completed_success_desc'),
                        buttonText: languageProvider.translate('ok_got_it'),
                        onButtonTap: () {
                          Navigator.of(context).pop();
                          // You can add navigation to past jobs tab here if needed
                        },
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => CommonSuccessDialog(
                        image: SvgPicture.asset(MyAssetsPaths.successSvg,
                            height: 120, width: 120),
                        title: languageProvider
                            .translate('mark_job_complete_title'),
                        subtitle: languageProvider
                            .translate('mark_job_complete_subtitle'),
                        buttonText:
                            languageProvider.translate('confirm_and_complete'),
                        onButtonTap: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => CommonSuccessDialog(
                              image: SvgPicture.asset(MyAssetsPaths.successSvg,
                                  height: 120, width: 120),
                              title: languageProvider
                                  .translate('job_completed_success'),
                              subtitle: languageProvider
                                  .translate('job_completed_success_desc'),
                              buttonText:
                                  languageProvider.translate('ok_got_it'),
                              onButtonTap: () {
                                Navigator.of(context).pop();
                                // You can add navigation to past jobs tab here if needed
                              },
                            ),
                          );
                        },
                        secondaryButtonText:
                            languageProvider.translate('cancel'),
                        onSecondaryButtonTap: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  }
                },
                margin: EdgeInsets.zero,
              )),
              SizedBox(width: 10),
              Expanded(
                  child: CommonButton(
                text: languageProvider.translate('message'),
                onTap: () {
                  context.push(
                    AppRouter.chat,
                    extra: {
                      'customerName': jobData.contactName ?? 'Ravi Malhotra',
                      'customerAddress': jobData.fullAddress ??
                          'Flat 305, Sector 11, Panchkula',
                      'customerAvatarUrl':
                          'https://randomuser.me/api/portraits/men/3.jpg',
                      'jobType': jobData.title ?? '',
                      'jobDateTime': (jobData.jobDate != null &&
                              jobData.jobDate!.isNotEmpty &&
                              jobData.jobTime != null &&
                              jobData.jobTime!.isNotEmpty)
                          ? '${jobData.jobDate}, ${jobData.jobTime}'
                          : '14 June, 12:00 PM – 1:00 PM',
                    },
                  );
                },
                backgroundColor: Colors.white,
                textColor: Colors.black,
                borderColor: MyColors.borderColor,
                margin: EdgeInsets.zero,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBidDetailsSection(
      LanguageProvider languageProvider, Bid bidData) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
      // padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // border: Border.all(color: MyColors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(),
          Text(
            'Your Bid Details',
            style: boldTextStyle(
              fontSize: 18.0,
              color: MyColors.blackColor,
            ),
          ),
          SizedBox(height: 16),
          if (bidData.message != null && bidData.message!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message: ',
                  style: boldTextStyle(
                    fontSize: 14.0,
                    color: MyColors.blackColor,
                  ),
                ),
                Expanded(
                  child: Text(
                    bidData.message!,
                    style: regularTextStyle(
                      fontSize: 14.0,
                      color: MyColors.color08151F,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
          if (bidData.availableTime != null &&
              bidData.availableTime!.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Available Time: ',
                  style: boldTextStyle(
                    fontSize: 14.0,
                    color: MyColors.blackColor,
                  ),
                ),
                Text(
                  bidData.availableTime!,
                  style: boldTextStyle(
                    fontSize: 14.0,
                    color: MyColors.color08151F,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
          ],
          Row(
            children: [
              Text(
                'Your Bid: ',
                style: boldTextStyle(
                  fontSize: 14.0,
                  color: MyColors.blackColor,
                ),
              ),
              Text(
                '₹${bidData.price ?? 0}',
                style: boldTextStyle(
                  fontSize: 14.0,
                  color: MyColors.appTheme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildJobHeader(
      LanguageProvider languageProvider, BookingJob jobData) {
    return Stack(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
              color: MyColors.appTheme.withOpacity(0.01),
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                // mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: MyColors.appTheme.withOpacity(0.10),
                        shape: BoxShape.circle),
                    padding: EdgeInsets.all(jobData.serviceId?.image != null &&
                            jobData.serviceId!.image!.isNotEmpty
                        ? 0
                        : 20),
                    child: jobData.serviceId?.image != null &&
                            jobData.serviceId!.image!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              jobData.serviceId!.image!,
                              height: 62,
                              width: 62,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  MyAssetsPaths.ac,
                                  height: 32,
                                  width: 32,
                                );
                              },
                            ),
                          )
                        : Image.asset(
                            MyAssetsPaths.ac,
                            height: 32,
                            width: 32,
                          ),
                  ),
                  jobData.status == "completed"
                      ? SizedBox.shrink()
                      : Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(right: 24),
                                padding: const EdgeInsets.only(
                                    left: 10, top: 5, bottom: 5, right: 8),
                                decoration: BoxDecoration(
                                  color: jobData.status == 'open'
                                      ? MyColors.greenColor
                                      : MyColors.colorFFCA15,
                                  borderRadius: BorderRadius.circular(60),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      jobData.status.toString() == 'open'
                                          ? 'Open'
                                          : jobData.status.toString(),
                                      style: mediumTextStyle(
                                          fontSize: 14.0,
                                          color: MyColors.whiteColor),
                                    ),
                                    if (jobData.status == "on_the_way" ||
                                        jobData.status == "paused")
                                      Icon(
                                        Icons.arrow_drop_down_outlined,
                                        color: Colors.white,
                                      )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                ],
              ),
              hsized8,
              Text(
                jobData.title ?? '',
                textAlign: TextAlign.center,
                style:
                    boldTextStyle(fontSize: 24.0, color: MyColors.blackColor),
              ),
              hsized8,
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    languageProvider.translate('job_id'),
                    style: regularTextStyle(
                        fontSize: 14.0, color: MyColors.color838383),
                  ),
                  Text(
                    jobData.id ?? '',
                    style: regularTextStyle(
                        fontSize: 14.0, color: MyColors.color838383),
                  ),
                ],
              ),
              hsized8
            ],
          ),
        ),
        Positioned(bottom: 0, child: Image.asset(MyAssetsPaths.blur))
      ],
    );
  }

  Widget _buildBidButtonBottomBar(
      BuildContext context,
      LanguageProvider languageProvider,
      BookingJob jobData,
      BookingJobsProvider jobProvider) {
    return GestureDetector(
      onTap: () => _showEditJobDialog(context, languageProvider, jobData),
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: MyColors.appTheme, borderRadius: BorderRadius.circular(80)),
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Text(
          languageProvider.translate("Add Bid"),
          style: semiBoldTextStyle(fontSize: 16.0, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAcceptedBottomBar(
      BuildContext context,
      LanguageProvider languageProvider,
      BookingJob jobData,
      BookingJobsProvider jobProvider) {
    return Wrap(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              // Budget Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.translate('your_budget'),
                    style: regularTextStyle(
                      fontSize: 12.0,
                      color: MyColors.color7A849C,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₹${jobData.price ?? 0}',
                    style:
                        boldTextStyle(fontSize: 24.0, color: MyColors.darkText),
                  ),
                ],
              ),
              Spacer(),
              // Add Bid / Edit Job Button
              GestureDetector(
                onTap: () =>
                    _showEditJobDialog(context, languageProvider, jobData),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.appTheme,
                      borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Text(
                    languageProvider.translate('edit_job'),
                    style:
                        semiBoldTextStyle(fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 10),
              // Cancel Job Button
              GestureDetector(
                onTap: () => _showCancelJobDialog(context, languageProvider),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.whiteColor,
                      border: Border.all(color: MyColors.borderColor),
                      borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                  child: Text(
                    languageProvider.translate('cancel_job'),
                    style: semiBoldTextStyle(
                        fontSize: 16.0, color: MyColors.blackColor),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultBottomBar(LanguageProvider languageProvider) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                languageProvider.translate('cancel_job'),
                style: mediumTextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
          hsized12,
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: MyColors.appTheme,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                languageProvider.translate('edit_job'),
                style: mediumTextStyle(fontSize: 16.0, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionHeader(LanguageProvider languageProvider, String key) {
    return Text(
      languageProvider.translate(key),
      style: boldTextStyle(fontSize: 18.0, color: MyColors.blackColor),
    );
  }

  Widget sectionText(LanguageProvider languageProvider, String key,
      {TextStyle? style}) {
    return Text(
      languageProvider.translate(key),
      style: style ?? regularTextStyle(fontSize: 14.0, color: Colors.grey),
    );
  }

  Widget acceptedStatus(BuildContext context, LanguageProvider languageProvider,
      BookingJob jobData, Bid? bidData) {
    int selectedTab = 0;
    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _TabButton(
                      text: languageProvider.translate('description'),
                      selected: selectedTab == 0,
                      onTap: () => setState(() => selectedTab = 0),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      text: languageProvider.translate('location'),
                      selected: selectedTab == 1,
                      onTap: () => setState(() => selectedTab = 1),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: _TabButton(
                      text: languageProvider.translate('schedule'),
                      selected: selectedTab == 2,
                      onTap: () => setState(() => selectedTab = 2),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Builder(
                builder: (_) {
                  if (selectedTab == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobData.description ??
                              languageProvider
                                  .translate('accepted_tab_description'),
                          style: regularTextStyle(
                              fontSize: 14.0, color: MyColors.color838383),
                        ),
                        SizedBox(height: 18),
                        if (bidData?.message != null &&
                            bidData!.message!.isNotEmpty) ...[
                          Text(
                            languageProvider.translate('additional_notes'),
                            style: regularTextStyle(
                                fontSize: 14.0, color: MyColors.color838383),
                          ),
                          SizedBox(height: 6),
                          Text(
                            bidData.message!,
                            style: regularTextStyle(
                                fontSize: 14.0, color: MyColors.color08151F),
                          ),
                          SizedBox(height: 18),
                        ],
                        Row(
                          children: [
                            Text(
                              languageProvider.translate('user_budget'),
                              style: regularTextStyle(
                                  fontSize: 14.0,
                                  color:
                                      MyColors.color08151F.withOpacity(0.85)),
                            ),
                            Text(' ₹${jobData.price ?? 0}',
                                style: boldTextStyle(
                                    fontSize: 14.0,
                                    color: MyColors.blackColor)),
                          ],
                        ),

                        /* if (bidData != null) ...[
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Your Bid: ',
                                style: regularTextStyle(
                                    fontSize: 14.0,
                                    color: MyColors.color08151F
                                        .withOpacity(0.85)),
                              ),
                              Text('₹${bidData.price ?? 0}',
                                  style: boldTextStyle(
                                      fontSize: 14.0,
                                      color: MyColors.appTheme)),
                            ],
                          ),
                          if (bidData.availableTime != null &&
                              bidData.availableTime!.isNotEmpty) ...[
                            SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  'Available Time: ',
                                  style: regularTextStyle(
                                      fontSize: 14.0,
                                      color: MyColors.color08151F
                                          .withOpacity(0.85)),
                                ),
                                Text(bidData.availableTime!,
                                    style: boldTextStyle(
                                        fontSize: 14.0,
                                        color: MyColors.blackColor)),
                              ],
                            ),



                          ],
                        ],*/
                        // Bid Details Section (show only when bid exists)
                        if (bidData != null) ...[
                          _buildBidDetailsSection(languageProvider, bidData),
                          hsized25,
                        ],
                      ],
                    );
                  } else if (selectedTab == 1) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobData.fullAddress ??
                              languageProvider
                                  .translate('accepted_tab_location'),
                          style: regularTextStyle(
                              fontSize: 15.0,
                              color: MyColors.color08151F.withOpacity(0.85)),
                        ),
                        if (jobData.contactName != null) ...[
                          SizedBox(height: 12),
                          Text(
                            'Contact: ${jobData.contactName}',
                            style: regularTextStyle(
                                fontSize: 14.0, color: MyColors.color838383),
                          ),
                        ],
                        if (jobData.contactNumber != null) ...[
                          SizedBox(height: 6),
                          Text(
                            'Phone: ${jobData.contactNumber}',
                            style: regularTextStyle(
                                fontSize: 14.0, color: MyColors.color838383),
                          ),
                        ],
                        if (jobData.contactEmail != null) ...[
                          SizedBox(height: 6),
                          Text(
                            'Email: ${jobData.contactEmail}',
                            style: regularTextStyle(
                                fontSize: 14.0, color: MyColors.color838383),
                          ),
                        ],
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${jobData.jobDate ?? ''} ${jobData.jobTime ?? ''}',
                          style: regularTextStyle(
                              fontSize: 15.0,
                              color: MyColors.color08151F.withOpacity(0.85)),
                        ),
                        if (jobData.estimatedTime != null) ...[
                          SizedBox(height: 12),
                          Text(
                            'Estimated Time: ${jobData.estimatedTime} hours',
                            style: regularTextStyle(
                                fontSize: 14.0, color: MyColors.color838383),
                          ),
                        ],
                      ],
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget completeStatus(LanguageProvider languageProvider, BookingJob jobData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date & Time Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey[200]!),
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader(languageProvider, 'date_time'),
              hsized12,
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey, size: 16),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    jobData.jobDate ?? '',
                    style: regularTextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Icon(Icons.access_time, color: Colors.grey, size: 16),
                  SizedBox(width: 5),
                  Text(
                    jobData.jobTime ?? '',
                    style: regularTextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Location Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader(languageProvider, 'location'),
              hsized12,
              Text(
                jobData.fullAddress ?? '',
                style: regularTextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ],
          ),
        ),
        // Job Description Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader(languageProvider, 'job_description'),
              hsized12,
              Text(
                jobData.description ?? '',
                style: regularTextStyle(fontSize: 14.0, color: Colors.grey),
              ),
            ],
          ),
        ),
        // Partner Performance Section
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader(languageProvider, 'partner_performance'),
              hsized12,
              _PerformanceItem(
                title: languageProvider.translate('customer_rating'),
                value: '5.0',
              ),
              _PerformanceItem(
                title: languageProvider.translate('time_taken'),
                value: _getTimeAgo(widget.jobData.createdAt.toString()),
              ),
              _PerformanceItem(
                title: languageProvider.translate('service_quality'),
                value: 'Excellent',
              ),
            ],
          ),
        ),
        // Total Payment Summary
        Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              sectionHeader(languageProvider, 'total_payment_summary'),
              hsized16,
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          languageProvider.translate('your_budget'),
                          style: regularTextStyle(
                              fontSize: 14.0, color: Colors.grey),
                        ),
                        Text(
                          "₹${jobData.price ?? 0}",
                          style: boldTextStyle(
                              fontSize: 16.0, color: MyColors.blackColor),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _TabButton(
      {required String text,
      required bool selected,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
            color: selected ? MyColors.appTheme : MyColors.whiteColor,
            border: Border.all(
                color: selected ? MyColors.appTheme : MyColors.borderColor),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 5)
            ]),
        alignment: Alignment.center,
        child: Text(
          text,
          style: mediumTextStyle(
              fontSize: 15.0,
              color: selected
                  ? Colors.white
                  : MyColors.color08151F.withOpacity(0.85)),
        ),
      ),
    );
  }

  void _showEditJobDialog(BuildContext context,
      LanguageProvider languageProvider, BookingJob jobData) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => EditJobDialog(
        jobData: jobData,
        languageProvider: languageProvider,
      ),
    );
  }

  void _handleBidCancellation(
      Bid? bidData,
      String reason,
      BookingJobsProvider bookingJobsProvider,
      LanguageProvider languageProvider) async {
    // Use a small delay to ensure the dialog is fully closed
    await Future.delayed(Duration(milliseconds: 100));

    if (bidData != null && bidData.id != null) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(MyColors.appTheme),
          ),
        ),
      );

      // Call the bidCancel API
      final success = await bookingJobsProvider.bidCancel(
        bidId: bidData.id!,
        reasonForCancel: reason,
      );

      // Hide loading dialog
      Navigator.of(context).pop();
      Navigator.of(context).pop();

      if (success) {
        // Show success dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CommonSuccessDialog(
            image: SvgPicture.asset(MyAssetsPaths.successSvg,
                height: 120, width: 120),
            title: languageProvider.translate('job_cancelled'),
            subtitle: languageProvider.translate('job_cancelled_success'),
            buttonText: languageProvider.translate('ok_got_it'),
            isCancel: false,
            onButtonTap: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                // _jobCancelled = true;
              });
            },
          ),
        );
      } else {
        // Show error dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => CommonSuccessDialog(
            image: SvgPicture.asset(MyAssetsPaths.cancelSvg,
                height: 120, width: 120),
            title: 'Error',
            subtitle:
                bookingJobsProvider.errorMessage ?? 'Failed to cancel bid',
            buttonText: 'OK',
            isCancel: false,
            onButtonTap: () {
              Navigator.of(dialogContext).pop();
            },
          ),
        );
      }
    } else {
      // Show error dialog if no bid data
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => CommonSuccessDialog(
          image: SvgPicture.asset(MyAssetsPaths.cancelSvg,
              height: 120, width: 120),
          title: 'Error',
          subtitle: 'No bid data found to cancel',
          buttonText: 'OK',
          isCancel: false,
          onButtonTap: () {
            Navigator.of(dialogContext).pop();
          },
        ),
      );
    }
  }

  void _showCancelJobDialog(
      BuildContext context, LanguageProvider languageProvider) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image:
            SvgPicture.asset(MyAssetsPaths.cancelSvg, height: 120, width: 120),
        title: languageProvider.translate('about_to_cancel_job'),
        subtitle: languageProvider.translate('cancel_job_warning'),
        buttonText: languageProvider.translate('confirm_cancellation'),
        isCancel: true,
        extraContent: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            hsized10,
            Text(languageProvider.translate('why_cancelling'),
                style: semiBoldTextStyle(
                    fontSize: 14.0, color: MyColors.darkText)),
            hsized8,
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintStyle: regularTextStyle(
                    fontSize: 14.0, color: MyColors.color838383),
                hintText:
                    languageProvider.translate('cancel_reason_placeholder'),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.borderColor),
                    borderRadius: BorderRadius.circular(14)),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: MyColors.borderColor),
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
            hsized25,
            CommonButton(
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
              text: languageProvider.translate('go_back'),
              onTap: () {
                Navigator.pop(context);
              },
              backgroundColor: MyColors.appTheme,
            ),
            CommonButton(
              text: languageProvider.translate('confirm_cancellation'),
              onTap: () {
                // Get the booking jobs provider and bid data before closing dialog
                final bookingJobsProvider =
                    Provider.of<BookingJobsProvider>(context, listen: false);
                final bidData = bookingJobsProvider.bidModel;
                final reason = reasonController.text.trim();

                // Close the cancel dialog first
                // Navigator.of(context).pop();

                // Call the cancel method with a delay
                _handleBidCancellation(
                    bidData, reason, bookingJobsProvider, languageProvider);
              },
              backgroundColor: MyColors.redColor,
              margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            )
          ],
        ),
        onButtonTap: () {}, // Not used for cancel, handled in extraContent
      ),
    );
  }

  // Common TextField method for extra work dialog
  Widget commonTextField({
    required TextEditingController controller,
    required String hint,
    required Function(String) onChanged,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: regularTextStyle(fontSize: 14.0, color: MyColors.blackColor),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MyColors.borderColor)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onChanged: onChanged,
    );
  }

  void _showAddExtraWorkDialog(BuildContext context) {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => JobProvider(),
          child: Consumer<JobProvider>(
            builder: (context, jobProvider, _) {
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                backgroundColor: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(28.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Icon(Icons.close, size: 28),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                languageProvider.translate('add_extra_work'),
                                textAlign: TextAlign.center,
                                style: semiBoldTextStyle(
                                    fontSize: 24.0, color: MyColors.blackColor),
                              ),
                            ),
                          ],
                        ),
                        hsized12,
                        Text(
                          languageProvider.translate('add_extra_work_subtitle'),
                          textAlign: TextAlign.center,
                          style: regularTextStyle(
                              fontSize: 14.0, color: MyColors.color838383),
                        ),
                        hsized25,
                        heading(languageProvider.translate('extra_work_title')),
                        hsized8,
                        commonTextField(
                          controller: jobProvider.extraWorkTitleController,
                          hint: languageProvider
                              .translate('extra_work_title_hint'),
                          onChanged: jobProvider.setExtraWorkTitle,
                        ),
                        hsized16,
                        heading(languageProvider
                            .translate('extra_work_description')),
                        hsized8,
                        commonTextField(
                          controller:
                              jobProvider.extraWorkDescriptionController,
                          hint: languageProvider
                              .translate('extra_work_description_hint'),
                          onChanged: jobProvider.setExtraWorkDescription,
                          maxLines: 2,
                        ),
                        hsized16,
                        heading(
                            languageProvider.translate('extra_work_charges')),
                        hsized8,
                        commonTextField(
                          controller: jobProvider.extraWorkChargesController,
                          hint: languageProvider
                              .translate('extra_work_charges_hint'),
                          onChanged: jobProvider.setExtraWorkCharges,
                          keyboardType: TextInputType.number,
                        ),
                        hsized16,
                        heading(languageProvider
                            .translate('extra_work_time_taken')),
                        hsized8,
                        commonTextField(
                          controller: jobProvider.extraWorkTimeTakenController,
                          hint: languageProvider
                              .translate('extra_work_time_taken_hint'),
                          onChanged: jobProvider.setExtraWorkTimeTaken,
                        ),
                        hsized25,
                        CommonButton(
                          text: languageProvider.translate('add_work_button'),
                          onTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => CommonSuccessDialog(
                                image: SvgPicture.asset(
                                    MyAssetsPaths.successSvg,
                                    height: 120,
                                    width: 120),
                                title: languageProvider
                                    .translate('extra_work_added_success'),
                                subtitle: languageProvider
                                    .translate('extra_work_added_success_desc'),
                                buttonText:
                                    languageProvider.translate('ok_got_it'),
                                onButtonTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  heading(String s) {
    return Text(s,
        style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.darkText));
  }
}

class _PerformanceItem extends StatelessWidget {
  final String title;
  final String value;

  const _PerformanceItem({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: regularTextStyle(fontSize: 14.0, color: Colors.grey),
          ),
          Text(
            value,
            style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor),
          ),
        ],
      ),
    );
  }
}
