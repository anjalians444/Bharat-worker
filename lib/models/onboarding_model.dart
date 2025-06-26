import 'package:bharat_worker/constants/assets_paths.dart';

class OnboardingModel {
  final String titleKey;
  final String descriptionKey;
  final String imagePath;

  OnboardingModel({
    required this.titleKey,
    required this.descriptionKey,
    required this.imagePath,
  });
}

final List<OnboardingModel> pages = [
  OnboardingModel(
    titleKey: 'onboarding_title_1',
    descriptionKey: 'onboarding_desc_1',
    imagePath: MyAssetsPaths.onboardingImage1,
  ),
  OnboardingModel(
    titleKey: 'onboarding_title_2',
    descriptionKey: 'onboarding_desc_2',
    imagePath: MyAssetsPaths.onboardingImage2,
  ),
  OnboardingModel(
    titleKey: 'onboarding_title_3',
    descriptionKey: 'onboarding_desc_3',
    imagePath: MyAssetsPaths.onboardingImage3,
  ),
  OnboardingModel(
    titleKey: 'onboarding_title_4',
    descriptionKey: 'onboarding_desc_4',
    imagePath: MyAssetsPaths.onboardingImage4,
  ),
];