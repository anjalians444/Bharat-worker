import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:flutter/material.dart';

class JobMatchCard extends StatelessWidget {
  final String iconPath;
  final String title;
  final String location;
  final String date;
  final String time;
  final String distance;
  final String desc;
  final String timeAgo;
  final String applicants;
  final String price;
  final bool bookmarked;
  final bool? isStatus;
  final String? badgeText;
  final Color? badgeColor;
  final String? status;
  final double? bottom;
  final VoidCallback? onBookmarkTap;
  final VoidCallback onTap;

  const JobMatchCard({
    Key? key,
    required this.iconPath,
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.distance,
    required this.desc,
    required this.timeAgo,
    required this.applicants,
    required this.price,
    required this.bookmarked,
    this.onBookmarkTap,
    this.isStatus = false,
    this.badgeText,
    this.badgeColor,
    this.status,
    this.bottom = 16.0,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: bottom??10.0),
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
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Image.asset(
                    iconPath,
                    height: 24,
                    width: 24,
                    color: MyColors.appTheme,
                  ),
                ),
                SizedBox(width: 6,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: mediumTextStyle(fontSize: 16.0, color: MyColors.blackColor),
                            ),
                          ),
                          GestureDetector(
                            onTap: onBookmarkTap,
                            child: Icon(
                              bookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: MyColors.appTheme,
                            ),
                          ),
                        ],
                      ),
                      hsized2,
                      Text(
                        location,
                        style: regularTextStyle(fontSize: 12.0, color: MyColors.color7A849C),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                _Tag(text: date),
                SizedBox(width: 8),
                _Tag(text: time),
                SizedBox(width: 8),
                _Tag(text: distance),
              ],
            ),
            SizedBox(height: 10),
            Text(
              desc,
              style: regularTextStyle(fontSize: 12.0, color: MyColors.color7A849C),
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
                        timeAgo,
                        style: regularTextStyle(fontSize: 11.0, color: MyColors.color838383),
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal:5),
                        height: 14,width:2,decoration: BoxDecoration(color: MyColors.borderColor),),
                      Text(
                        applicants,
                        style: mediumTextStyle(fontSize: 11.0, color: MyColors.appTheme),
                      ),
                      if(isStatus == true)...[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          height: 14,width:2,decoration: BoxDecoration(color: MyColors.borderColor),),

                        Text(
                          price,
                          style: boldTextStyle(fontSize: 11.0, color: MyColors.appTheme),
                        ),
                      ],


                      SizedBox(width: 16),

                    ],
                  ),
                ),
      if(isStatus == false)...[
                Text(
                  price,
                  style: boldTextStyle(fontSize: 12.0, color: MyColors.appTheme),
                ),
      ],
                if(isStatus == true )...[
                  if (badgeText != null && badgeColor != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal:5, vertical: 4),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            badgeText!,
                            style: semiBoldTextStyle(fontSize: 11.0, color: MyColors.whiteColor),
                          ),
                          if(status == "On the Way"  ||  status == "Paused")
                          Icon(Icons.arrow_drop_down,color: Colors.white,size:23,)
                        ],
                      ),
                    ),
                ],

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
      padding: EdgeInsets.symmetric(horizontal: 7, vertical: 7),
      decoration: BoxDecoration(
        color:MyColors.colorE7E9EE,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: mediumTextStyle(fontSize: 12.0, color: MyColors.color7A849C),
      ),
    );
  }
}