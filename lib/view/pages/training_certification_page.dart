import 'package:bharat_worker/constants/assets_paths.dart';
import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/font_style.dart';
import '../../constants/my_colors.dart';
import '../../constants/sized_box.dart';
import '../../provider/training_provider.dart';

class TrainingCertificationPage extends StatelessWidget {
  const TrainingCertificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trainingProvider = Provider.of<TrainingProvider>(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: commonAppBar((){
        Navigator.pop(context);
      },
        languageProvider.translate('Training & Certification'),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal:24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hsized25,
              Text('Get Trained. Get Certified.', style: boldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),
              hsized12,
              Text('Learn the best practices, improve your skills, and unlock certifications to earn more.', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383)),
              hsized25,
              ...List.generate(trainingProvider.trainings.length, (index) {
                final item = trainingProvider.trainings[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.black12,
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          item.imagePath,
                          height: 223,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: SvgPicture.asset(MyAssetsPaths.playCircle,height: 37,width: 37,)
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 24,
                        child: Column(
                          children: [
                            Text(item.title, style: boldTextStyle(fontSize: 16.0, color: Colors.white), textAlign: TextAlign.center),
                            hsized5,
                            Text(item.duration, style: regularTextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.90)), textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              hsized8,
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: MyColors.blueColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Stack(
                  alignment: Alignment.bottomRight,

                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ready to test your knowledge?', style: semiBoldTextStyle(fontSize: 16.0, color: Colors.white)),
                        hsized10,
                        Text('Complete the quiz to unlock your certification badge.', style: regularTextStyle(fontSize: 14.0, color: Colors.white.withOpacity(0.90))),
                        hsized10,

                        InkWell(
                          onTap: (){ context.push(AppRouter.quiz);},
                          child: Container(
                            decoration: BoxDecoration(
                              color: MyColors.yellowColor,
                              borderRadius: BorderRadius.circular(50)
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                            child: Text('Take Quiz',style: semiBoldTextStyle(fontSize: 14.0, color: MyColors.darkText),),
                          ),
                        )

                      ],
                    ),


                    Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset(MyAssetsPaths.hathodi),
                    )


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 