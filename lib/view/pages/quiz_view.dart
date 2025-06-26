import 'package:bharat_worker/helper/common.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/font_style.dart';
import '../../constants/my_colors.dart';
import '../../constants/sized_box.dart';
import '../../provider/quiz_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../widgets/common_success_dialog.dart';
import '../../constants/assets_paths.dart';
import 'package:go_router/go_router.dart';
import '../../helper/router.dart';

class QuizView extends StatefulWidget {
  const QuizView({Key? key}) : super(key: key);

  @override
  State<QuizView> createState() => _QuizViewState();
}

class _QuizViewState extends State<QuizView> {
  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:  commonAppBar((){
        Navigator.pop(context);
      },
          languageProvider.translate('Quiz Test'),
         ),

      body: Consumer<QuizProvider>(
        builder: (context, quizProvider, _) {
          final q = quizProvider.questions[quizProvider.currentIndex];
          final total = quizProvider.questions.length;
          final current = quizProvider.currentIndex + 1;
          final selected = quizProvider.selectedAnswers[quizProvider.currentIndex];
          final submitted = quizProvider.submitted;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                hsized25,
                Text('Skill Quiz – Get Certified', style: boldTextStyle(fontSize: 18.0, color: MyColors.blackColor)),
                hsized12,
                Text('Answer the questions based on training videos. Score 80% or higher to earn your certification badge.', style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383)),
                hsized25,
                // Progress bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                    border: Border.all(color: MyColors.borderColor,width: 1.5),
                    boxShadow: [
                      BoxShadow(color: MyColors.borderColor,blurRadius:10)
                    ]
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: quizProvider.currentIndex == 0
                              ? 0.0
                              : quizProvider.currentIndex == total - 1 && !quizProvider.submitted
                                  ? (total - 1) / total
                                  : (quizProvider.submitted ? 1.0 : (quizProvider.currentIndex + 1) / total),
                          backgroundColor: MyColors.appTheme.withOpacity(0.10),
                          color: MyColors.yellowColor,
                          borderRadius: BorderRadius.circular(20),
                          minHeight:8,
                        ),
                      ),
                      SizedBox(width:4),
                      Icon(Icons.emoji_events, color: Colors.amber, size: 25),
                      SizedBox(width: 4),
                      Text('${quizProvider.score}/${total}', style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                    ],
                  ),
                ),
                hsized20,
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical:23, horizontal:50),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: MyColors.borderColor)
                  ),
                  child: Column(
                    children: [
                      Text('Quiz $current/$total', style: mediumTextStyle(fontSize: 14.0, color: MyColors.darkText)),
                      hsized10,
                      Text(q.question, style: boldTextStyle(fontSize: 18.0, color: MyColors.darkText), textAlign: TextAlign.center),
                    ],
                  ),
                ),
                hsized20,
                ...List.generate(q.options.length, (i) {
                  final isSelected = selected == i;
                  final isCorrect = submitted && i == q.correctIndex;
                  final isWrong = submitted && isSelected && i != q.correctIndex;
                  return GestureDetector(
                    onTap: submitted ? null : () => quizProvider.selectAnswer(i),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                      decoration: BoxDecoration(
                        color:
                       /* isCorrect ? Colors.green.withOpacity(0.15): isWrong ? Colors.red.withOpacity(0.15) :*/
                        isSelected
                                    ? MyColors.appTheme.withOpacity(0.10)
                                    : Colors.white,
                        border: Border.all(
                          color:
                        //  isCorrect ? Colors.green : isWrong ? Colors.red :
                          isSelected
                                      ? Colors.transparent
                                      : MyColors.borderColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(q.options[i], style: mediumTextStyle(fontSize: 14.0, color:isSelected?MyColors.appTheme: MyColors.darkText)),
                          ),

                            Icon(isSelected ?Icons.check_circle: Icons.circle_outlined, color:isSelected ?  isCorrect ? Colors.green : MyColors.appTheme:MyColors.borderColor, size: 22),
                        ],
                      ),
                    ),
                  );
                }),
                // Spacer(),
                SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.appTheme,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (quizProvider.currentIndex < total -1 ) {
                          quizProvider.nextQuestion();
                        } else {
                          quizProvider.nextQuestion();
                          quizProvider.submitQuiz(onPassed: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => CommonSuccessDialog(
                                image: SvgPicture.asset(MyAssetsPaths.congratulation, height: 120, width: 120),
                                title: 'Congratulations!',
                                subtitle: "You've passed the quiz and earned your certification badge. More job opportunities are now unlocked.",
                                buttonText: 'Explore Jobs',
                                onButtonTap: () {
                                  Navigator.of(context).pop();
                                  context.go(AppRouter.dashboard);
                                },
                              ),
                            );
                          });
                        }
                      },
                      child: Text(
                        quizProvider.currentIndex   == total  - 1 ? 'Submit Quiz' : 'Next',
                        style: boldTextStyle(fontSize: 16.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
                hsized10,
              ],
            ),
          );
        },
      ),
    );
  }
} 