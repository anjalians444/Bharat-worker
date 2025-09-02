import 'package:bharat_worker/models/job_model.dart';
import 'package:flutter/material.dart';
import '../models/booking_job_model.dart';
import '../services/api_service.dart';
import '../services/api_paths.dart';

class BookingJobsProvider extends ChangeNotifier {
  List<BookingJob> _bookingJobs = [];
  BookingJob _jobModel = BookingJob();
  Bid? _bidModel;
  bool _isLoading = false;
  String? _errorMessage;

  List<BookingJob> get bookingJobs => _bookingJobs;
  BookingJob get jobModel => _jobModel;
  Bid? get bidModel => _bidModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchBookingJobs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get(ApiPaths.getActiveJobs);

      if (response['success'] == true) {
        final bookingJobResponse = BookingJobResponse.fromJson(response);
        _bookingJobs = bookingJobResponse.data.activeJobs;
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch booking jobs';
      }
    } catch (e) {
      _errorMessage = 'Error fetching booking jobs: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBookingJobsSilently() async {
    // Don't set loading state, just fetch data silently
    try {
      final response = await ApiService().get(ApiPaths.getActiveJobs);

      if (response['success'] == true) {
        final bookingJobResponse = BookingJobResponse.fromJson(response);
        _bookingJobs = bookingJobResponse.data.activeJobs;
        // Only notify listeners to update UI with new data, no loading state
        notifyListeners();
      }
    } catch (e) {
      // Silently handle errors without showing them to user
      print('Silent refresh error: $e');
    }
  }

  Future<void> fetchJobDetail(String jobID) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService().get("${ApiPaths.getJobDetail}$jobID");
      
      // Debug: Print the response to see the actual structure
      print("Job Detail API Response: $response");

      if (response['success'] == true) {
        try {
          // First try with the new structure
          final jobDetailResponse = JobDetailResponse.fromJson(response);
          _jobModel = jobDetailResponse.data.job;
          _bidModel = jobDetailResponse.data.bid;
        } catch (parseError) {
          print("Parse Error with new structure: $parseError");
          
          // Fallback: Try to parse just the job data directly
          try {
            if (response['data'] != null && response['data']['job'] != null) {
              _jobModel = BookingJob.fromJson(response['data']['job']);
              if (response['data']['bid'] != null) {
                _bidModel = Bid.fromJson(response['data']['bid']);
              }
            } else {
              _errorMessage = 'Invalid response structure';
            }
          } catch (fallbackError) {
            print("Fallback parse error: $fallbackError");
            _errorMessage = 'Error parsing job details: $fallbackError';
          }
        }
      } else {
        _errorMessage = response['message'] ?? 'Failed to fetch job details';
      }
    } catch (e) {
      print("API Error: $e");
      _errorMessage = 'Error fetching job details: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearJobs() {
    _bookingJobs = [];
    notifyListeners();
  }

  void clearJobDetail() {
    _jobModel = BookingJob();
    _bidModel = null;
    notifyListeners();
  }

  Future<bool> addJobBid({
    required String jobId,
    required String price,
    required String message,
    required String availableTime,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        "jobId": jobId,
        "price": price,
        "message": message,
        "availableTime": availableTime,
      };

      final response = await ApiService().post(
        ApiPaths.addJobBid,
        body: payload,
      );

      if (response['success'] == true) {
        // Refresh job details after successful bid
        await fetchJobDetail(jobId);
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to add bid';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding bid: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bidCancel({
    required String bidId,
    required String reasonForCancel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payload = {
        "bidId": bidId,
        "reson_for_cancel": reasonForCancel,
      };

      final response = await ApiService().post(
        ApiPaths.bidCancel,
        body: payload,
      );

      if (response['success'] == true) {
        // Refresh job details after successful cancellation
        await fetchJobDetail(_jobModel.id.toString());
        return true;
      } else {
        _errorMessage = response['message'] ?? 'Failed to cancel bid';
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error cancelling bid: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
