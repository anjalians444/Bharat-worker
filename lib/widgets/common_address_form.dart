import 'package:flutter/material.dart';
import 'package:bharat_worker/provider/work_address_provider.dart';
import 'package:bharat_worker/provider/language_provider.dart';
import 'package:bharat_worker/constants/font_style.dart';
import 'package:bharat_worker/constants/my_colors.dart';
import 'package:bharat_worker/widgets/common_text_field.dart';

class CommonAddressForm extends StatelessWidget {
  final WorkAddressProvider workAddressProvider;
  final LanguageProvider languageProvider;
  final EdgeInsets? padding;
  const CommonAddressForm({
    Key? key,
    required this.workAddressProvider,
    required this.languageProvider,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Text(languageProvider.translate('address'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
              const SizedBox(height: 10),
              CommonTextField(
                controller: workAddressProvider.addressController,
                hintText: languageProvider.translate('enter_address'),
                suffixIcon: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageProvider.translate('country'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        const SizedBox(height: 10),
                        CommonTextField(
                          controller: workAddressProvider.countryController,
                          hintText: "",
                          readOnly: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageProvider.translate('state'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        const SizedBox(height: 10),
                        CommonTextField(
                          controller: workAddressProvider.stateController,
                          hintText: languageProvider.translate('select_state'),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageProvider.translate('city_town'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        const SizedBox(height: 10),
                        CommonTextField(
                          controller: workAddressProvider.cityController,
                          hintText: languageProvider.translate('enter_city'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(languageProvider.translate('pin_code'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
                        const SizedBox(height: 10),
                        CommonTextField(
                          controller: workAddressProvider.pinCodeController,
                          hintText: languageProvider.translate('enter_pin'),
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

            ],
          ),
        ),
        Padding(
          padding: padding ?? EdgeInsets.zero,
          child: Text(languageProvider.translate('service_areas_distance'), style: mediumTextStyle(fontSize: 14.0, color: MyColors.blackColor)),
        ),
       // const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 7.0,
                  thumbShape: const _CustomSliderThumbShape(thumbRadius: 10.0),
                  activeTrackColor: MyColors.appTheme,
                  inactiveTrackColor: MyColors.borderColor,
                  thumbColor: MyColors.appTheme,
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
                ),
                child: Slider(
                  value: workAddressProvider.distance,
                  min: 0,
                  max: 40,
                  divisions: 40,
                  label: '${workAddressProvider.distance.round()} km',
                  onChanged: (double value) {
                    workAddressProvider.setDistance(value);
                  },
                ),
              ),
            ),
            Text('${workAddressProvider.distance.round()} km', style: mediumTextStyle(fontSize: 14.0, color: MyColors.lightText)),

          SizedBox(width: 20,)
          ],
        ),
      ],
    );
  }
}

class _CustomSliderThumbShape extends SliderComponentShape {
  final double thumbRadius;

  const _CustomSliderThumbShape({this.thumbRadius = 10.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double>? activationAnimation,
    Animation<double>? enableAnimation,
    bool? isDiscrete,
    TextPainter? labelPainter,
    RenderBox? parentBox,
    SliderThemeData? sliderTheme,
    TextDirection? textDirection,
    double? value,
    double? textScaleFactor,
    Size? sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final Paint outerPaint = Paint()..color = sliderTheme?.thumbColor ?? Colors.blue;
    canvas.drawCircle(center, thumbRadius, outerPaint);

    final Paint innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, thumbRadius / 2.5, innerPaint);
  }
} 