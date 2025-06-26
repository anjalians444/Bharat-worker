import 'package:flutter/material.dart';
import '../models/training_model.dart';
import '../constants/assets_paths.dart';

class TrainingProvider extends ChangeNotifier {
  final List<TrainingModel> _trainings = [
    TrainingModel(
      title: 'Customer Service Basics',
      subtitle: '',
      imagePath: MyAssetsPaths.trainingImage1,
      duration: '2 mins 30 secs',
    ),
    TrainingModel(
      title: 'Safety & Work Guidelines',
      subtitle: '',
      imagePath: MyAssetsPaths.trainingImage2,
      duration: '2 mins 30 secs',
    ),
  ];

  List<TrainingModel> get trainings => _trainings;
} 