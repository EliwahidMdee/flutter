import 'package:flutter/foundation.dart';
import '../../../data/models/dashboard_model.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_constants.dart';

enum DashboardStatus { initial, loading, loaded, error }

class DashboardProvider with ChangeNotifier {
  final ApiClient _client;
  
  DashboardStatus _status = DashboardStatus.initial;
  DashboardStatsModel? _stats;
  String? _error;
  
  DashboardProvider(this._client);
  
  // Getters
  DashboardStatus get status => _status;
  DashboardStatsModel? get stats => _stats;
  String? get error => _error;
  bool get isLoading => _status == DashboardStatus.loading;
  
  // Fetch dashboard data
  Future<void> fetchDashboardData() async {
    _status = DashboardStatus.loading;
    notifyListeners();
    
    try {
      final response = await _client.get(ApiEndpoints.dashboard);
      _stats = DashboardStatsModel.fromJson(response.data['data']);
      _status = DashboardStatus.loaded;
      _error = null;
    } catch (e) {
      _status = DashboardStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Fetch dashboard stats
  Future<void> fetchDashboardStats() async {
    try {
      final response = await _client.get(ApiEndpoints.dashboardStats);
      _stats = DashboardStatsModel.fromJson(response.data['data']);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
