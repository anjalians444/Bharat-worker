import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/models/booking_job_model.dart';
import 'package:bharat_worker/provider/booking_jobs_provider.dart';
import 'package:bharat_worker/provider/job_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_success_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

class EditJobDialog extends StatefulWidget {
  final BookingJob jobData;
  final LanguageProvider languageProvider;

  const EditJobDialog({
    Key? key,
    required this.jobData,
    required this.languageProvider,
  }) : super(key: key);

  @override
  State<EditJobDialog> createState() => _EditJobDialogState();
}

class _EditJobDialogState extends State<EditJobDialog> {
  late JobProvider _jobProvider;

  @override
  void initState() {
    super.initState();
    _jobProvider = JobProvider();
    _initializeBidData();
  }

  void _initializeBidData() {
    // Get bid data from BookingJobsProvider
    final bookingJobsProvider =
        Provider.of<BookingJobsProvider>(context, listen: false);
    final bidData = bookingJobsProvider.bidModel;

    // Pre-fill fields if bid data exists (edit case)
    if (bidData != null) {
      // Use WidgetsBinding to ensure this runs after the build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _jobProvider.budgetController.text = bidData.price?.toString() ?? '';
        _jobProvider.timeSlotController.text = bidData.availableTime ?? '';
        _jobProvider.messageController.text = bidData.message ?? '';

        // Update provider values
        _jobProvider.setBudget(bidData.price?.toString() ?? '');
        _jobProvider.setTimeSlot(bidData.availableTime ?? '');
        _jobProvider.setMessage(bidData.message ?? '');
      });
    }
  }

  @override
  void dispose() {
    _jobProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _jobProvider,
      child: Consumer<JobProvider>(
        builder: (context, jobProvider, _) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            insetPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 40),
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
                  padding: const EdgeInsets.fromLTRB(20, 28 + 16, 28, 20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        SizedBox(height: 8),
                        _buildSubtitle(),
                        SizedBox(height: 28),
                        _buildBudgetField(jobProvider),
                        SizedBox(height: 22),
                        _buildTimeSlotField(jobProvider),
                        SizedBox(height: 22),
                        _buildMessageField(jobProvider),
                        SizedBox(height: 32),
                        _buildSubmitButton(jobProvider),
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
  }

  Widget _buildTitle() {
    final bookingJobsProvider =
        Provider.of<BookingJobsProvider>(context, listen: false);
    return Text(
      widget.languageProvider.translate(bookingJobsProvider.bidModel == null
          ? "Add Bid"
          : 'edit_job_details'),
      style: boldTextStyle(fontSize: 24.0, color: MyColors.blackColor),
    );
  }

  Widget _buildSubtitle() {
    final bookingJobsProvider =
        Provider.of<BookingJobsProvider>(context, listen: false);
    return Text(
      widget.languageProvider.translate(bookingJobsProvider.bidModel == null
          ? 'add_bid_subtitle'
          : 'edit_job_subtitle'),
      style: regularTextStyle(fontSize: 15.0, color: MyColors.color838383),
    );
  }

  Widget _buildBudgetField(JobProvider jobProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.languageProvider.translate('your_budget')} (₹)',
          style: boldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
        ),
        SizedBox(height: 8),
        TextField(
          controller: jobProvider.budgetController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText:
                widget.languageProvider.translate('your_budget_placeholder'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
          onChanged: (value) {
            jobProvider.setBudget(value);
          },
        ),
      ],
    );
  }

  Widget _buildTimeSlotField(JobProvider jobProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.languageProvider.translate('available_time_slot'),
            style: boldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
            children: [
              TextSpan(
                text: ' ${widget.languageProvider.translate('optional')}',
                style: regularTextStyle(
                    fontSize: 14.0, color: MyColors.color838383),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: jobProvider.timeSlotController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: widget.languageProvider
                .translate('available_time_slot_placeholder'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            suffixIcon: Icon(Icons.calendar_today_outlined),
          ),
          onTap: () async {
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (picked != null) {
              final formatted = picked.format(context);
              jobProvider.timeSlotController.text = formatted;
              jobProvider.setTimeSlot(formatted);
            }
          },
        ),
      ],
    );
  }

  Widget _buildMessageField(JobProvider jobProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            text: widget.languageProvider.translate('your_message'),
            style: boldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
            children: [
              TextSpan(
                text: ' ${widget.languageProvider.translate('optional')}',
                style: regularTextStyle(
                    fontSize: 14.0, color: MyColors.color838383),
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: jobProvider.messageController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: widget.languageProvider.translate('your_message'),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(JobProvider jobProvider) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () => _handleSubmit(jobProvider),
        style: ElevatedButton.styleFrom(
          backgroundColor: MyColors.appTheme,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Text(
          widget.languageProvider.translate(
              Provider.of<BookingJobsProvider>(context, listen: false)
                          .bidModel ==
                      null
                  ? 'Submit Bid'
                  : 'save_changes'),
          style: semiBoldTextStyle(fontSize: 18.0, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _handleSubmit(JobProvider jobProvider) async {
    final bookingJobsProvider =
        Provider.of<BookingJobsProvider>(context, listen: false);

    if (bookingJobsProvider.bidModel == null) {
      await _handleAddBid(jobProvider, bookingJobsProvider);
    } else {
      await _handleEditJob(jobProvider);
    }
  }

  Future<void> _handleAddBid(
      JobProvider jobProvider, BookingJobsProvider bookingJobsProvider) async {
    // Show loading dialog
    _showLoadingDialog(widget.languageProvider.translate('submitting_bid'));

    // Handle Add Bid case
    final success = await bookingJobsProvider.addJobBid(
      jobId: widget.jobData.id.toString(),
      price: jobProvider.budgetController.text,
      message: jobProvider.messageController.text,
      availableTime: jobProvider.timeSlotController.text,
    );

    // Hide loading dialog
    Navigator.of(context).pop();

    if (success) {
      Navigator.of(context).pop();
      _showSuccessDialog(
        title: widget.languageProvider.translate('congratulations'),
        subtitle: 'Your bid has been submitted successfully!',
        buttonText: widget.languageProvider.translate('ok_got_it'),
      );
    } else {
      _showErrorDialog(
        title: 'Error',
        subtitle: bookingJobsProvider.errorMessage ?? 'Failed to submit bid',
        buttonText: 'OK',
      );
    }
  }

  Future<void> _handleEditJob(JobProvider jobProvider) async {
    final bookingJobsProvider =
        Provider.of<BookingJobsProvider>(context, listen: false);

    // Show loading dialog for edit job
    _showLoadingDialog(widget.languageProvider.translate('updating_bid'));

    // Use the same API call for both add and edit
    final success = await bookingJobsProvider.addJobBid(
      jobId: widget.jobData.id.toString(),
      price: jobProvider.budgetController.text,
      message: jobProvider.messageController.text,
      availableTime: jobProvider.timeSlotController.text,
    );

    // Hide loading dialog
    Navigator.of(context).pop();

    if (success) {
      Navigator.of(context).pop();
      _showSuccessDialog(
        title: widget.languageProvider.translate('congratulations'),
        subtitle: widget.languageProvider.translate('job_update_success'),
        buttonText: widget.languageProvider.translate('explore_jobs'),
      );
    } else {
      _showErrorDialog(
        title: 'Error',
        subtitle: bookingJobsProvider.errorMessage ?? 'Failed to update bid',
        buttonText: 'OK',
      );
    }
  }

  void _showLoadingDialog(String? message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(MyColors.appTheme),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog({
    required String title,
    required String subtitle,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image:
            SvgPicture.asset(MyAssetsPaths.successSvg, height: 120, width: 120),
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _showErrorDialog({
    required String title,
    required String subtitle,
    required String buttonText,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CommonSuccessDialog(
        image:
            SvgPicture.asset(MyAssetsPaths.cancelSvg, height: 120, width: 120),
        title: title,
        subtitle: subtitle,
        buttonText: buttonText,
        onButtonTap: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
