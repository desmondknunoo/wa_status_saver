import 'package:flutter/material.dart';
import '../models/status_model.dart';
import '../services/whatsapp_service.dart';
import '../services/file_service.dart';
import '../services/permission_service.dart';

class StatusProvider extends ChangeNotifier {
  final WhatsAppService _whatsappService = WhatsAppService();
  final FileService _fileService = FileService();
  final PermissionService _permissionService = PermissionService();

  List<StatusModel> _whatsappStatuses = [];
  List<StatusModel> _businessStatuses = [];
  List<StatusModel> _savedStatuses = [];

  bool _isLoading = false;
  bool _hasPermission = false;
  String? _errorMessage;
  DateTime? _lastRefresh;

  // Getters
  List<StatusModel> get whatsappStatuses => _whatsappStatuses;
  List<StatusModel> get businessStatuses => _businessStatuses;
  List<StatusModel> get savedStatuses => _savedStatuses;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermission;
  String? get errorMessage => _errorMessage;
  DateTime? get lastRefresh => _lastRefresh;

  int get whatsappCount => _whatsappStatuses.length;
  int get businessCount => _businessStatuses.length;
  int get savedCount => _savedStatuses.length;

  /// Initializes the provider by checking storage permissions.
  ///
  /// If permission is already granted, automatically fetches all statuses.
  /// Should be called once when the app starts.
  Future<void> initialize() async {
    _hasPermission = await _permissionService.checkPermission();
    if (_hasPermission) {
      await refreshAllStatuses();
    }
    notifyListeners();
  }

  /// Request storage permission
  Future<bool> requestPermission() async {
    _hasPermission = await _permissionService.requestStoragePermission();
    if (_hasPermission) {
      await refreshAllStatuses();
    }
    notifyListeners();
    return _hasPermission;
  }

  /// Refreshes all status lists from WhatsApp directories.
  ///
  /// Concurrently fetches:
  /// - WhatsApp statuses
  /// - WhatsApp Business statuses
  /// - Previously saved statuses
  ///
  /// Updates loading state and notifies listeners on completion.
  Future<void> refreshAllStatuses() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _whatsappStatuses = await _whatsappService.fetchStatuses(
        WhatsAppType.whatsapp,
      );
      _businessStatuses = await _whatsappService.fetchStatuses(
        WhatsAppType.whatsappBusiness,
      );
      _savedStatuses = await _fileService.getSavedStatuses();
      _lastRefresh = DateTime.now();
    } catch (e) {
      _errorMessage = 'Failed to load statuses: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Save a status
  Future<bool> saveStatus(StatusModel status) async {
    try {
      final success = await _fileService.saveStatus(status);
      if (success) {
        _savedStatuses = await _fileService.getSavedStatuses();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to save status: $e';
      notifyListeners();
      return false;
    }
  }

  /// Delete a saved status
  Future<bool> deleteStatus(StatusModel status) async {
    try {
      final success = await _fileService.deleteStatus(status);
      if (success) {
        _savedStatuses = await _fileService.getSavedStatuses();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to delete status: $e';
      notifyListeners();
      return false;
    }
  }

  /// Check if status is saved
  Future<bool> isStatusSaved(StatusModel status) async {
    return await _fileService.isStatusSaved(status);
  }
}
