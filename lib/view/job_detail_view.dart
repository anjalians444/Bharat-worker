import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/models/job_model.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/job_provider.dart';
import '../widgets/common_success_dialog.dart';
import 'package:go_router/go_router.dart';
import '../helper/router.dart';
import 'chat_view.dart';

class JobDetailView extends StatefulWidget {
  final JobModel jobData;

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

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

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
                child:  Icon(
                  widget.jobData.status == "Completed"?  Icons.bookmark_border:Icons.more_vert_sharp,
                  size: 24,
                )),
            onTap: () async {
              if (widget.jobData.status == "Completed") return;
              final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
              final result = await showMenu<String>(
                context: context,
                color: Colors.white,
                position: RelativeRect.fromLTRB(100, 80, 0, 0), // Adjust as needed
                items: [
                  PopupMenuItem(
                    value: keyNavigateToJob,
                    child: Row(
                      children: [
                        SvgPicture.asset(MyAssetsPaths.navigation,height: 16,width: 16,),

                        SizedBox(width:10),
                        Text('Navigate to Job',style: mediumTextStyle(color: MyColors.blackColor, fontSize: 14.0)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: keyAddExtraWork,
                    child: Row(
                      children: [
                        SvgPicture.asset(MyAssetsPaths.newJobRequestIcon,height: 16,width: 16,),
                        SizedBox(width:10),
                        Text('Add Extra Work' ,style: mediumTextStyle(color: MyColors.blackColor, fontSize: 14.0)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: keyCancelJob,
                    child: Row(
                      children: [
                        SvgPicture.asset(MyAssetsPaths.jobCancelledIcon,height: 16,width: 16,),
                        SizedBox(width:10),
                        Text('Cancel Job', style: mediumTextStyle(color: MyColors.redColor, fontSize: 14.0)),
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
                    'address': widget.jobData.location ?? 'Flat 305, Sector 11, Panchkula',
                    'time': '5 min',
                    'userName': 'Ravi Malhotra',
                    'userAddress': 'Flat 305, Sector 11, Panchkula',
                    'userAvatarUrl': 'https://randomuser.me/api/portraits/men/1.jpg',
                  },
                );
              }
              // Handle other keys as needed
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Header
            _buildJobHeader(languageProvider),
            hsized25,
            widget.jobData.status == 'Accepted'
                ? acceptedStatus(context, languageProvider)
                : completeStatus(languageProvider),
          ],
        ),
      ),
      bottomNavigationBar:  _jobCancelled || widget.jobData.status == "On the Way" || widget.jobData.status == "Started"
          ? _buildAfterCancelBottomBar(languageProvider)
          : (widget.jobData.status == 'Accepted'
          ? _buildAcceptedBottomBar(context, languageProvider)
          : SizedBox.shrink()),
      //_buildDefaultBottomBar(languageProvider)),
    );
  }

  Widget _buildAfterCancelBottomBar(LanguageProvider languageProvider) {
    return Wrap(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 16,horizontal: 24),
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
                      widget.jobData.status == "On the Way" || widget.jobData.status == "Started" ? "markComplete" : 'start_job'),
                  onTap: () {
                    if (widget.jobData.status == "Started") {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => CommonSuccessDialog(
                          image: SvgPicture.asset(MyAssetsPaths.successSvg, height: 120, width: 120),
                          title: languageProvider.translate('job_completed_success'),
                          subtitle: languageProvider.translate('job_completed_success_desc'),
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
                          image: SvgPicture.asset(MyAssetsPaths.successSvg, height: 120, width: 120),
                          title: languageProvider.translate('mark_job_complete_title'),
                          subtitle: languageProvider.translate('mark_job_complete_subtitle'),
                          buttonText: languageProvider.translate('confirm_and_complete'),
                          onButtonTap: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => CommonSuccessDialog(
                                image: SvgPicture.asset(MyAssetsPaths.successSvg, height: 120, width: 120),
                                title: languageProvider.translate('job_completed_success'),
                                subtitle: languageProvider.translate('job_completed_success_desc'),
                                buttonText: languageProvider.translate('ok_got_it'),
                                onButtonTap: () {
                                  Navigator.of(context).pop();
                                  // You can add navigation to past jobs tab here if needed
                                },
                              ),
                            );
                          },
                          secondaryButtonText: languageProvider.translate('cancel'),
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
                child:  CommonButton(
                  text: languageProvider.translate('message'),
                  onTap: () {
                    context.push(
                      AppRouter.chat,
                      extra: {
                        'customerName': 'Ravi Malhotra',
                        'customerAddress': 'Flat 305, Sector 11, Panchkula',
                        'customerAvatarUrl': 'https://randomuser.me/api/portraits/men/3.jpg',
                        'jobType': widget.jobData.title,
                        'jobDateTime': (widget.jobData.date != null && widget.jobData.time != null)
                          ? '${widget.jobData.date}, ${widget.jobData.time}'
                          : '14 June, 12:00 PM – 1:00 PM',
                      },
                    );
                  },
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                  borderColor: MyColors.borderColor,
                  margin: EdgeInsets.zero,
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobHeader(LanguageProvider languageProvider) {
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
                    padding: EdgeInsets.all(20),
                    child: Image.asset(
                      MyAssetsPaths.ac,
                      height: 32,
                      width: 32,
                    ),
                  ),

                  widget.jobData.status == "Compleated"?
                      SizedBox.shrink():
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 24),
                          padding: const EdgeInsets.only(left:10, top:5,bottom: 5,right: 8),
                          decoration: BoxDecoration(
                            color: widget.jobData.badgeColor,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                widget.jobData.badge.toString(),
                                style: mediumTextStyle(fontSize: 14.0, color: MyColors.whiteColor),
                              ),
                              if(widget.jobData.status == "On the Way"  ||  widget.jobData.status == "Paused")
                               Icon(Icons.arrow_drop_down_outlined,color: Colors.white,)


                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              hsized10,
              Text(
                widget.jobData.title?? '',
               textAlign: TextAlign.center,
                style: boldTextStyle(fontSize: 24.0, color: MyColors.blackColor),
              ),
              hsized10,
              Text(
                languageProvider.translate('job_id'),
                style: regularTextStyle(
                    fontSize: 14.0, color: MyColors.color838383),
              ),
              hsized10
            ],
          ),
        ),
        Positioned(
          bottom: 0,
            child: Image.asset(MyAssetsPaths.blur))
      ],
    );
  }

  Widget _buildAcceptedBottomBar(BuildContext context, LanguageProvider languageProvider) {
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
                    '${widget.jobData.price ?? '0'}',
                    style: boldTextStyle(
                        fontSize: 24.0, color: MyColors.darkText),
                  ),
                ],
              ),
              Spacer(),
              // Edit Job Button
              GestureDetector(
                onTap: () => _showEditJobDialog(context, languageProvider),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.appTheme,
                      borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 13),
                  child: Text(
                    languageProvider.translate('edit_job'),
                    style: semiBoldTextStyle(
                        fontSize: 16.0, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Cancel Job Button
              GestureDetector(
                onTap: () => _showCancelJobDialog(context, languageProvider),
                child: Container(
                  decoration: BoxDecoration(
                      color: MyColors.whiteColor,
                      border: Border.all(color: MyColors.borderColor),
                      borderRadius: BorderRadius.circular(80)),
                  padding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
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
                style: mediumTextStyle(
                    fontSize: 16.0, color: Colors.white),
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
                style: mediumTextStyle(
                    fontSize: 16.0, color: Colors.white),
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

  Widget sectionText(LanguageProvider languageProvider, String key, {TextStyle? style}) {
    return Text(
      languageProvider.translate(key),
      style: style ?? regularTextStyle(fontSize: 14.0, color: Colors.grey),
    );
  }

  Widget acceptedStatus(BuildContext context, LanguageProvider languageProvider) {
    int selectedTab = 0;
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(0),
          child: Column(
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
                          Text(languageProvider.translate('accepted_tab_description'),style: regularTextStyle(fontSize:14.0, color: MyColors.color838383),),

                          SizedBox(height: 18),
                          Text(languageProvider.translate('additional_notes'),style: regularTextStyle(fontSize:14.0, color: MyColors.color838383),),

                          SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              sectionText(languageProvider, 'accepted_tab_note_1', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383)),
                              sectionText(languageProvider, 'accepted_tab_note_2', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383)),
                              sectionText(languageProvider, 'accepted_tab_note_3', style: regularTextStyle(fontSize: 14.0, color: MyColors.color08151F)),
                            ],
                          ),
                          SizedBox(height: 18),
                          Row(
                            children: [
                              sectionText(languageProvider, 'user_budget', style: regularTextStyle(fontSize: 14.0, color: MyColors.color08151F.withOpacity(0.85))),
                              Text(' ₹550', style: boldTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                            ],
                          ),
                        ],
                      );
                    } else if (selectedTab == 1) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionText(languageProvider, 'accepted_tab_location', style: regularTextStyle(fontSize: 15.0, color: MyColors.color08151F.withOpacity(0.85))),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          sectionText(languageProvider, 'accepted_tab_schedule', style: regularTextStyle(fontSize: 15.0, color: MyColors.color08151F.withOpacity(0.85))),
                        ],
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget completeStatus(LanguageProvider languageProvider) {
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
                  hsized8,
                  Text(
                    widget.jobData.date ?? '',
                    style: regularTextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                  hsized16,
                  Icon(Icons.access_time, color: Colors.grey, size: 16),
                  hsized8,
                  Text(
                    widget.jobData.time ?? '',
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
                widget.jobData.location ?? '',
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
                widget.jobData.desc ?? '',
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
                value: widget.jobData.timeAgo ?? '45 mins',
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
                          "₹${widget.jobData.price ?? '0'}",
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
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(

          padding: EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? MyColors.appTheme :MyColors.whiteColor,
            border: Border.all(color:  selected ? MyColors.appTheme :MyColors.borderColor),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.06),blurRadius: 5)
            ]
          ),
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
      ),
    );
  }

  void _showEditJobDialog(BuildContext context, LanguageProvider languageProvider) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => JobProvider(),
          child: Consumer<JobProvider>(
            builder: (context, jobProvider, _) {
              final budgetController =
                  TextEditingController(text: jobProvider.budget);
              final timeSlotController =
                  TextEditingController(text: jobProvider.timeSlot);
              final messageController =
                  TextEditingController(text: jobProvider.message);
              return Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28)),
                insetPadding:
                    EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                backgroundColor: Colors.white,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, right: 16),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(Icons.close, size: 28),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 28 + 16, 28, 28),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(languageProvider.translate('edit_job_details'),
                                style: boldTextStyle(
                                    fontSize: 24.0,
                                    color: MyColors.blackColor)),
                            SizedBox(height: 8),
                            Text(
                              languageProvider.translate('edit_job_subtitle'),
                              style: regularTextStyle(
                                  fontSize: 15.0, color: MyColors.color838383),
                            ),
                            SizedBox(height: 28),
                            Text(languageProvider.translate('your_budget') + ' (₹)',
                                style: boldTextStyle(
                                    fontSize: 16.0,
                                    color: MyColors.blackColor)),
                            SizedBox(height: 8),
                            TextField(
                              controller: budgetController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: languageProvider.translate('your_budget_placeholder'),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              onChanged: jobProvider.setBudget,
                            ),
                            SizedBox(height: 22),
                            Text.rich(
                              TextSpan(
                                text: languageProvider.translate('available_time_slot'),
                                style: boldTextStyle(
                                    fontSize: 16.0, color: MyColors.blackColor),
                                children: [
                                  TextSpan(
                                    text: ' ' + languageProvider.translate('optional'),
                                    style: regularTextStyle(
                                        fontSize: 14.0,
                                        color: MyColors.color838383),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: timeSlotController,
                              readOnly: true,
                              decoration: InputDecoration(
                                hintText: languageProvider.translate('available_time_slot_placeholder'),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                suffixIcon: Icon(Icons.calendar_today_outlined),
                              ),
                              onTap: () async {
                                final picked = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                if (picked != null) {
                                  final formatted = picked.format(context);
                                  timeSlotController.text =
                                      languageProvider.translate('available_time_slot_placeholder').replaceAll('4:30 PM', formatted);
                                  jobProvider
                                      .setTimeSlot(timeSlotController.text);
                                }
                              },
                            ),
                            SizedBox(height: 22),
                            Text.rich(
                              TextSpan(
                                text: languageProvider.translate('your_message'),
                                style: boldTextStyle(
                                    fontSize: 16.0, color: MyColors.blackColor),
                                children: [
                                  TextSpan(
                                    text: ' ' + languageProvider.translate('optional'),
                                    style: regularTextStyle(
                                        fontSize: 14.0,
                                        color: MyColors.color838383),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: messageController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: languageProvider.translate('your_message_placeholder'),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              onChanged: jobProvider.setMessage,
                            ),
                            SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  jobProvider.updateJobDetails(
                                    budget: budgetController.text,
                                    timeSlot: timeSlotController.text,
                                    message: messageController.text,
                                  );
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) => CommonSuccessDialog(
                                      image: SvgPicture.asset(
                                          MyAssetsPaths.successSvg,
                                          height: 120,
                                          width: 120),
                                      title: languageProvider.translate('congratulations'),
                                      subtitle: languageProvider.translate('job_update_success'),
                                      buttonText: languageProvider.translate('explore_jobs'),
                                      onButtonTap: () {
                                        Navigator.of(context).pop();
                                        //context.go(AppRouter.dashboard);
                                      },
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: MyColors.appTheme,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(32),
                                  ),
                                ),
                                child: Text(languageProvider.translate('save_changes'),
                                    style: semiBoldTextStyle(
                                        fontSize: 18.0, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showCancelJobDialog(BuildContext context, LanguageProvider languageProvider) {
    final TextEditingController reasonController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image: SvgPicture.asset(MyAssetsPaths.cancelSvg, height: 120, width: 120),
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
                hintText: languageProvider.translate('cancel_reason_placeholder'),
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
                Navigator.of(context).pop();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => CommonSuccessDialog(
                    image: SvgPicture.asset(MyAssetsPaths.successSvg,
                        height: 120, width: 120),
                    title: languageProvider.translate('job_cancelled'),
                    subtitle: languageProvider.translate('job_cancelled_success'),
                    buttonText: languageProvider.translate('explore_jobs'),
                    isCancel: false,
                    onButtonTap: () {
                      Navigator.of(context).pop();
                      setState(() {
                        _jobCancelled = true;
                      });
                    },
                  ),
                );
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
        hintStyle: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: MyColors.borderColor)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onChanged: onChanged,
    );
  }

  void _showAddExtraWorkDialog(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return ChangeNotifierProvider(
          create: (_) => JobProvider(),
          child: Consumer<JobProvider>(
            builder: (context, jobProvider, _) {
              return Dialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
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
                                style: semiBoldTextStyle(fontSize: 24.0, color: MyColors.blackColor),
                              ),
                            ),
                          ],
                        ),
                        hsized12,
                        Text(
                          languageProvider.translate('add_extra_work_subtitle'),
                          textAlign: TextAlign.center,
                          style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                        ),
                        hsized25,
                        heading(languageProvider.translate('extra_work_title')),
                        hsized8,
                        commonTextField(
                          controller: jobProvider.extraWorkTitleController,
                          hint: languageProvider.translate('extra_work_title_hint'),
                          onChanged: jobProvider.setExtraWorkTitle,
                        ),
                        hsized16,
                        heading(languageProvider.translate('extra_work_description')),
                        hsized8,
                        commonTextField(
                          controller: jobProvider.extraWorkDescriptionController,
                          hint: languageProvider.translate('extra_work_description_hint'),
                          onChanged: jobProvider.setExtraWorkDescription,
                          maxLines: 2,
                        ),
                        hsized16,
                        heading(languageProvider.translate('extra_work_charges')),
                        hsized8,
                        commonTextField(
                          controller: jobProvider.extraWorkChargesController,
                          hint: languageProvider.translate('extra_work_charges_hint'),
                          onChanged: jobProvider.setExtraWorkCharges,
                          keyboardType: TextInputType.number,
                        ),
                        hsized16,
                        heading(languageProvider.translate('extra_work_time_taken')),
                        hsized8,
                        commonTextField(
                          controller: jobProvider.extraWorkTimeTakenController,
                          hint: languageProvider.translate('extra_work_time_taken_hint'),
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
                                image: SvgPicture.asset(MyAssetsPaths.successSvg, height: 120, width: 120),
                                title: languageProvider.translate('extra_work_added_success'),
                                subtitle: languageProvider.translate('extra_work_added_success_desc'),
                                buttonText: languageProvider.translate('ok_got_it'),
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
    return Text(s, style:semiBoldTextStyle(fontSize:16.0, color:MyColors.darkText));
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
