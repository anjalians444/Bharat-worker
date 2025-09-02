import 'package:flutter/material.dart';
import '../models/active_job_model.dart';
import '../services/api_service.dart';
import '../services/api_paths.dart';

class ActiveJobsProvider extends ChangeNotifier {
  List<JobModel> _activeJobs = [];
  JobModel jobModel = JobModel();
  bool _isLoading = false;
  String? _errorMessage;

  List<JobModel> get activeJobs => _activeJobs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchActiveJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get(ApiPaths.getActiveJobs);

      if (response['success'] == true) {
        final activeJobResponse = ActiveJobResponse.fromJson(response);
        _activeJobs = activeJobResponse.data.activeJobs;
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch active jobs';
      }
    } catch (e) {
      _errorMessage = 'Error fetching active jobs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchJobDetail(String jobID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get("${ApiPaths.getJobDetail}$jobID");

      if (response['success'] == true) {
        jobModel = JobModel.fromJson(response['data']['job']);
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch active jobs';
      }
    } catch (e) {
      _errorMessage = 'Error fetching active jobs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearJobs() {
    _activeJobs = [];
    notifyListeners();
  }
}
