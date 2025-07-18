import 'package:bharat_worker/provider/subscription_provider.dart';
import 'package:flutter/material.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/constants/sized_box.dart';
import 'package:bharat_worker/widgets/common_button.dart';
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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subscription Plan',
                  style: boldTextStyle(fontSize:26.0, color: MyColors.blackColor, height: 1.2, latterSpace: 0.2, overflow: TextOverflow.ellipsis),
                ),
                hsized5,
                Text(
                  'Choose a plan that fits your goals. Get more job visibility, instant payouts, priority support, and exclusive bonuses.',
                  style: regularTextStyle(fontSize: 14.0, color: MyColors.lightText, height: 1.5, overflow: TextOverflow.ellipsis),
                ),
                hsized20,
                Row(
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
                ),
                hsized25,
                if (subProvider.isLoading)
                  Center(child: CircularProgressIndicator()),
                if (subProvider.error != null)
                  Center(child: Text(subProvider.error!, style: TextStyle(color: Colors.red))),
                if (!subProvider.isLoading && subProvider.error == null && subProvider.plans.isNotEmpty)
                  SizedBox(
                    height: 390,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: subProvider.plans.length,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, int index) {
                        var plan = subProvider.plans[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: MyColors.appTheme,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (index == 0)
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: MyColors.yellowColor,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Most Popular',
                                        style: semiBoldTextStyle(fontSize: 12.0, color: MyColors.blackColor),
                                      ),
                                    ),
                                  ],
                                ),
                              if (index == 0) hsized10,
                              Text(
                                plan.name,
                                style: semiBoldTextStyle(fontSize: 20.0, color: MyColors.whiteColor),
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
                                        style: regularTextStyle(fontSize: 20.0, color: MyColors.colorE7E9EE.withOpacity(0.5)).copyWith(decoration: TextDecoration.lineThrough),
                                      ),
                                    ),
                                  wsized10,
                                  Text(
                                    '₹${plan.price}',
                                    style: boldTextStyle(fontSize: 35.0, color: MyColors.whiteColor),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom:8.0),
                                    child: Text(
                                      plan.priceType == 'yearly' ? '/year' : '/month',
                                      style: regularTextStyle(fontSize: 16.0, color: MyColors.whiteColor),
                                    ),
                                  ),
                                ],
                              ),
                              if (plan.description != null && plan.description!.isNotEmpty)
                                Text(
                                  plan.description!,
                                  style: regularTextStyle(fontSize: 14.0, color: MyColors.borderColor),
                                ),
                              if (plan.description == null || plan.description!.isEmpty)
                                Text(
                                  'Ideal for growing partners',
                                  style: regularTextStyle(fontSize: 14.0, color: MyColors.borderColor),
                                ),
                              hsized12,
                              Divider(color: MyColors.lightGreyColor.withOpacity(0.3)),
                              hsized12,
                              Text(
                                'Features include:',
                                style: regularTextStyle(fontSize: 16.0, color: MyColors.whiteColor),
                              ),
                              hsized15,
                              ...plan.features.map((f) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _featureRow(f),
                              )),
                              hsized10,
                              CommonButton(
                                text: 'Choose ${plan.name}',
                                onTap: () {},
                                backgroundColor: MyColors.whiteColor,
                                textColor: MyColors.appTheme,
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

  Widget _featureRow(String text) {
    return Row(
      children: [
        Icon(Icons.check, color: MyColors.whiteColor, size:17),
        wsized10,
        Expanded(
          child: Text(
            text,
            style: regularTextStyle(fontSize: 14.0, color: MyColors.whiteColor, height: 1.2, overflow: TextOverflow.ellipsis),
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
        color: isActive ? MyColors.appTheme : MyColors.lightGreyColor,
        shape: BoxShape.circle,
      ),
    );
  }
} 