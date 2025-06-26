// Updated CommonJobCard widget to include distance, applicants, badgeText, badgeColor, and description
import 'package:flutter/material.dart';
import '../constants/font_style.dart';
import '../constants/my_colors.dart';
import '../constants/sized_box.dart';

class CommonJobCard extends StatelessWidget {
  final String title;
  final String location;
  final String? time;
  final String? date;
  final String? price;
  final String? status;
  final String? distance;
  final String? applicants;
  final String? badgeText;
  final Color? badgeColor;
  final String? description;
  final VoidCallback onTap;
  final bool showBookmark;

  const CommonJobCard({
    Key? key,
    required this.title,
    required this.location,
    this.time,
    this.date,
    this.price,
    this.status,
    this.distance,
    this.applicants,
    this.badgeText,
    this.badgeColor,
    this.description,
    required this.onTap,
    this.showBookmark = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.home_repair_service,
                    color: MyColors.appTheme,
                  ),
                ),
                hsized16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: semiBoldTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                      ),
                      Text(
                        location,
                        style: regularTextStyle(fontSize: 14.0, color: Colors.grey),
                      ),
                      hsized5,
                      Row(
                        children: [
                          if (date != null) ...[
                            _infoChip(Icons.calendar_today, date!),
                            hsized8,
                          ],
                          if (time != null) ...[
                            _infoChip(Icons.access_time, time!),
                            hsized8,
                          ],
                          if (distance != null) ...[
                            _infoChip(Icons.location_on, distance!),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (showBookmark)
                  Icon(Icons.bookmark_border, color: MyColors.appTheme),
              ],
            ),
            if (description != null) ...[
              hsized12,
              Text(
                description!,
                style: regularTextStyle(fontSize: 14.0, color: Colors.grey[700]),
              ),
            ],
            hsized12,
            Row(
              children: [
                if (applicants != null) ...[
                  Text('$applicants Applicants', style: regularTextStyle(fontSize: 12.0, color: Colors.grey)),
                  hsized16,
                ],
                if (price != null) ...[
                  Text(price!, style: semiBoldTextStyle(fontSize: 14.0, color:MyColors.greenColor)),
                  hsized16,
                ],
                if (badgeText != null && badgeColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor!.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText!,
                      style: mediumTextStyle(fontSize: 12.0, color: badgeColor!),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        hsized4,
        Text(
          text,
          style: regularTextStyle(fontSize: 12.0, color: Colors.grey),
        ),
      ],
    );
  }
}
