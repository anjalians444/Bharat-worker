import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/models/booking_job_model.dart';
import 'package:flutter/material.dart';

class BookingJobCard extends StatelessWidget {
  final BookingJob bookingJob;
  final VoidCallback? onBookmarkTap;
  final VoidCallback onTap;

  const BookingJobCard({
    Key? key,
    required this.bookingJob,
    this.onBookmarkTap,
    required this.onTap,
  }) : super(key: key);

  Widget _buildImageWidget() {
    final imagePath = bookingJob.image!.isNotEmpty
        ? '${bookingJob.image!.first}'
        : MyAssetsPaths.ac;

    // Check if the imagePath is a network URL
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(500),
        child: Image.network(
          imagePath,
          height: 35,
          width: 35,
          fit: BoxFit.fill,
          errorBuilder: (context, error, stackTrace) {
            // Return grey box when image fails to load
            return Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(100),
              ),
              child: Container(
                height: 24,
                width: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.image_not_supported,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: SizedBox(
                  height: 12,
                  width: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      // For asset images, use Image.asset with error handling
      return Image.asset(
        imagePath,
        height: 24,
        width: 24,
        color: MyColors.appTheme,
        errorBuilder: (context, error, stackTrace) {
          // Return grey box when asset image fails to load
          return Container(
            height: 24,
            width: 24,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.image_not_supported,
              size: 16,
              color: Colors.grey[600],
            ),
          );
        },
      );
    }
  }

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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.0),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(bookingJob.image!.isNotEmpty ? 0 : 8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: _buildImageWidget(),
                ),
                SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              bookingJob.title ?? "",
                              style: mediumTextStyle(
                                  fontSize: 16.0, color: MyColors.blackColor),
                            ),
                          ),
                          GestureDetector(
                            onTap: onBookmarkTap,
                            child: Icon(
                              Icons.bookmark_border,
                              color: MyColors.appTheme,
                            ),
                          ),
                        ],
                      ),
                      hsized2,
                      Text(
                        bookingJob.fullAddress ?? "",
                        style: regularTextStyle(
                            fontSize: 12.0, color: MyColors.color7A849C),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _Tag(text: bookingJob.jobDate ?? ""),
                SizedBox(width: 8),
                _Tag(text: bookingJob.jobTime ?? ""),
                SizedBox(width: 8),
                _Tag(text: '${bookingJob.jobDistance} km'),
              ],
            ),
            SizedBox(height: 10),
            Text(
              bookingJob.description ?? "",
              style:
                  regularTextStyle(fontSize: 12.0, color: MyColors.color7A849C),
            ),
            SizedBox(height: 14),
            Divider(),
            SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _getTimeAgo(bookingJob.createdAt ?? ""),
                        style: regularTextStyle(
                            fontSize: 11.0, color: MyColors.color838383),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 5),
                        height: 14,
                        width: 2,
                        decoration: BoxDecoration(color: MyColors.borderColor),
                      ),
                      Text(
                        '${bookingJob.applicants} Applicants',
                        style: mediumTextStyle(
                            fontSize: 11.0, color: MyColors.appTheme),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 8),
                        height: 14,
                        width: 2,
                        decoration: BoxDecoration(color: MyColors.borderColor),
                      ),
                      Text(
                        '₹${bookingJob.price}',
                        style: boldTextStyle(
                            fontSize: 11.0, color: MyColors.appTheme),
                      ),
                      SizedBox(width: 16),
                    ],
                  ),
                ),
                if (bookingJob.status!.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: bookingJob.status == 'open'
                          ? MyColors.greenColor
                          : MyColors.colorFFCA15,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bookingJob.status.toString() == 'open'
                          ? 'Open'
                          : bookingJob.status.toString(),
                      style: regularTextStyle(
                        fontSize: 10.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;

  const _Tag({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: regularTextStyle(fontSize: 10.0, color: MyColors.color7A849C),
      ),
    );
  }
}
