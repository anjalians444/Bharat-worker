import 'package:bharat_worker/helper/router.dart';
import 'package:bharat_worker/provider/subscription_provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/widgets/common_button.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SubscriptionPlanView extends StatefulWidget {
  const SubscriptionPlanView({Key? key}) : super(key: key);

  @override
  State<SubscriptionPlanView> createState() => _SubscriptionPlanViewState();
}

class _SubscriptionPlanViewState extends State<SubscriptionPlanView> {
  bool isMonthly = true;
  int _currentPage = 0;
  final PageController _pageController = PageController(viewportFraction: 0.95);

  @override
  void initState() {
    super.initState();
    // Refresh data when screen is focused
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final subProvider = Provider.of<SubscriptionProvider>(context, listen: false);
      if (subProvider.error != null && subProvider.plans.isEmpty) {
        subProvider.fetchSubscriptionPlans();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subProvider = Provider.of<SubscriptionProvider>(context);
    return Scaffold(
      backgroundColor: MyColors.whiteColor,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: MyColors.whiteColor,
        elevation: 0,
        leadingWidth: 80,
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: MyColors.lightGreyColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
            ),
          ),
        ),
        actions: [
          // Add refresh button in app bar
          if (subProvider.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => subProvider.fetchSubscriptionPlans(),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: MyColors.lightGreyColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.refresh, color: Colors.black, size: 22),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await subProvider.fetchSubscriptionPlans();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: Text(
                    'Subscription Plan',
                    style: boldTextStyle(fontSize:26.0, color: MyColors.blackColor,),
                  ),
                ),
                hsized5,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal:20.0),
                  child: Text(
                    'Choose a plan that fits your goals. Get more job visibility, instant payouts, priority support, and exclusive bonuses.',
                    style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText,),
                  ),
                ),
                hsized20,
               /* Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _planToggle(),
                    SizedBox(width: 12,),
                    if (subProvider.plans.isNotEmpty && subProvider.plans[_currentPage].percentageDiscount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MyColors.appTheme,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${subProvider.plans[_currentPage].percentageDiscount.toStringAsFixed(0)}% OFF',
                          style: boldTextStyle(fontSize: 12.0, color: MyColors.whiteColor, height: 1.2, latterSpace: 0.2, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                  ],
                ),*/
              //  hsized25,
                if (subProvider.isLoading)
                  Container(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                if (subProvider.error != null && !subProvider.isLoading)
                  Container(
                    height: 200,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off,
                            size: 48,
                            color: MyColors.color838383,
                          ),
                          hsized15,
                          Text(
                            'Network Error',
                            style: regularTextStyle(fontSize: 18.0, color: MyColors.color838383),
                          ),
                          hsized10,
                          // Text(
                          //   subProvider.error!,
                          //   style: regularTextStyle(fontSize: 14.0, color: MyColors.color838383),
                          //   textAlign: TextAlign.center,
                          // ),
                           hsized20,
                          CommonButton(
                            text: 'Retry',
                            onTap: () => subProvider.fetchSubscriptionPlans(),
                            backgroundColor: MyColors.appTheme,
                            textColor: MyColors.whiteColor,
                            borderColor: Colors.transparent,
                            width: 120,
                            fontSize: 14.0,
                            borderRadius: 25,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            margin: const EdgeInsets.all(0),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!subProvider.isLoading && subProvider.error == null && subProvider.plans.isNotEmpty)
                  Container(
                    height: 390,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: subProvider.plans.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, int index) {
                        var plan = subProvider.plans[index];
                        bool isActive = _currentPage == index ;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color:
                           // isActive? MyColors.appTheme:
                            Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(color: MyColors.borderColor,blurRadius: 10)
                            ]
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // if (index == 0)
                                  //   Row(
                                  //     children: [
                                  //       Container(
                                  //         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  //         decoration: BoxDecoration(
                                  //           color: MyColors.yellowColor,
                                  //           borderRadius: BorderRadius.circular(8),
                                  //         ),
                                  //         child: Text(
                                  //           'Most Popular',
                                  //           style: semiBoldTextStyle(fontSize: 12.0, color: MyColors.blackColor),
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // if (index == 0) hsized10,
                                  Text(
                                    plan.name,
                                    style: semiBoldTextStyle(fontSize: 20.0, color:
                                  //  isActive?MyColors.whiteColor:
                                    MyColors.blackColor),
                                  ),
                                  hsized10,
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      if (plan.mrp > plan.price)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom:8.0),
                                          child: Text(
                                            '₹${plan.mrp}',
                                            style: regularTextStyle(fontSize: 20.0, color:
                                            // isActive?MyColors.whiteColor.withOpacity(0.5):
                                            MyColors.blackColor.withOpacity(0.5)).copyWith(decoration: TextDecoration.lineThrough),
                                          ),
                                        ),
                                      wsized10,
                                      Text(
                                        '₹${plan.price}',
                                        style: boldTextStyle(fontSize: 35.0, color:
                                        // isActive?MyColors.whiteColor:
                                        MyColors.blackColor),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom:8.0),
                                        child: Text(
                                          plan.priceType == 'yearly' ? '/year' : '/month',
                                          style: regularTextStyle(fontSize: 16.0, color:
                                          // isActive?MyColors.whiteColor:
                                          MyColors.blackColor),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (plan.description != null && plan.description!.isNotEmpty)
                                    Text(
                                      plan.description!,
                                      style: regularTextStyle(fontSize: 14.0, color:
                                      // !isActive?
                                      MyColors.color838383)
                                          // : MyColors.borderColor),
                                    ),
                                  if (plan.description == null || plan.description!.isEmpty)
                                    Text(
                                      'Ideal for growing partners',
                                      style: regularTextStyle(fontSize: 14.0, color: MyColors.borderColor),
                                    ),
                                  hsized12,


                        DottedBorder(
                        dashPattern: [3, 3],
                        strokeWidth: 1,
                        color:
                        // !isActive ?
                        MyColors.color838383.withOpacity(0.5),
                            // : MyColors.lightGreyColor.withOpacity(0.3),
                        customPath: (size) => Path()
                        ..moveTo(0, 0)
                        ..lineTo(size.width, 0), // only top line
                        child: SizedBox(
                        width: double.infinity,
                        height: 1, // 1 pixel dotted line
                        ),
                        ),


                        hsized12,
                                  Text(
                                    'Features include:',
                                    style: regularTextStyle(fontSize: 16.0, color:
                                    // isActive?MyColors.whiteColor:
                                    MyColors.blackColor),
                                  ),
                                  hsized15,
                                  ...plan.features.map((f) => Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: _featureRow(f,isActive),
                                  )),

                                ],
                              ),
                              hsized10,
                              CommonButton(
                                text: 'Choose ${plan.name}',
                                onTap: () {
                                  context.push(AppRouter.paymentTransactionDetail,extra: {"plan":plan});
                                },
                                backgroundColor:
                                // isActive?MyColors.whiteColor:
                                MyColors.blackColor,
                                textColor:
                                // isActive?MyColors.appTheme:
                                MyColors.whiteColor,
                                borderColor: Colors.transparent,
                                width: double.infinity,
                                fontSize: 16.0,
                                borderRadius: 32,
                                padding: EdgeInsets.symmetric(vertical: 8),
                                margin: const EdgeInsets.all(0),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                hsized25,
                if (subProvider.plans.length > 1)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(subProvider.plans.length, (int index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: _dot(_currentPage == index),
                        );
                      }),
                    ),
                  ),
                hsized25,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _planToggle() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Monthly',
          style: isMonthly
              ? semiBoldTextStyle(fontSize: 14.0, color: MyColors.blackColor)
              : semiBoldTextStyle(fontSize: 14.0, color: MyColors.color7A849C),
        ),
        wsized10,
        GestureDetector(
          onTap: () => setState(() => isMonthly = !isMonthly),
          child: Container(
            width: 48,
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: MyColors.whiteColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: MyColors.lightGreyColor, width: 2),
            ),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: isMonthly ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: MyColors.appTheme,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        wsized10,
        Text(
          'Yearly',
          style: !isMonthly
              ? boldTextStyle(fontSize: 16.0, color: MyColors.blackColor)
              : regularTextStyle(fontSize: 16.0, color: MyColors.lightText),
        ),
      ],
    );
  }

  Widget _featureRow(String text,bool isActive) {
    return Row(
      children: [
        Icon(Icons.check, color:
        // isActive?Colors.white:
        MyColors.blackColor, size:17),
        wsized10,
        Expanded(
          child: Text(
            text,
            style: regularTextStyle(fontSize: 14.0, color:
            // isActive?MyColors.whiteColor:
            MyColors.blackColor, height: 1.2, overflow: TextOverflow.ellipsis),
          ),
        ),
      ],
    );
  }

  Widget _dot(bool isActive) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color:
        isActive ? MyColors.appTheme :
        MyColors.lightGreyColor,
        shape: BoxShape.circle,
      ),
    );
  }
} 