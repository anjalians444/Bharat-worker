import 'package:flutter/material.dart';

class JobModel {
  final String icon;
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
  final String status;
  final String? badge;
  final Color? badgeColor;

  JobModel({
    required this.icon,
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
    required this.status,   this.badge,this.badgeColor,
  });
} 