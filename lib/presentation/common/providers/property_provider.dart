import 'package:flutter/foundation.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/property_repository.dart';

enum PropertyViewStatus { initial, loading, loaded, error }

class PropertyProvider with ChangeNotifier {
  final PropertyRepository _repository;
  
  PropertyViewStatus _status = PropertyViewStatus.initial;
  List<PropertyModel> _properties = [];
  PropertyModel? _selectedProperty;
  List<UnitModel> _units = [];
  String? _error;
  
  PropertyProvider(this._repository);
  
  // Getters
  PropertyViewStatus get status => _status;
  List<PropertyModel> get properties => _properties;
  PropertyModel? get selectedProperty => _selectedProperty;
  List<UnitModel> get units => _units;
  String? get error => _error;
  bool get isLoading => _status == PropertyViewStatus.loading;
  
  // Fetch all properties
  Future<void> fetchProperties() async {
    _status = PropertyViewStatus.loading;
    notifyListeners();
    
    try {
      _properties = await _repository.getProperties();
      _status = PropertyViewStatus.loaded;
      _error = null;
    } catch (e) {
      _status = PropertyViewStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Get property by ID
  Future<void> fetchPropertyById(int id) async {
    _status = PropertyViewStatus.loading;
    notifyListeners();
    
    try {
      _selectedProperty = await _repository.getPropertyById(id);
      _status = PropertyViewStatus.loaded;
      _error = null;
    } catch (e) {
      _status = PropertyViewStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Fetch property units
  Future<void> fetchPropertyUnits(int propertyId) async {
    try {
      _units = await _repository.getPropertyUnits(propertyId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Create property
  Future<bool> createProperty({
    required String name,
    required String address,
    required String propertyType,
    required int totalUnits,
    String? description,
  }) async {
    try {
      await _repository.createProperty(
        name: name,
        address: address,
        propertyType: propertyType,
        totalUnits: totalUnits,
        description: description,
      );
      
      await fetchProperties();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Update property
  Future<bool> updateProperty({
    required int propertyId,
    String? name,
    String? address,
    String? propertyType,
    int? totalUnits,
    String? description,
  }) async {
    try {
      await _repository.updateProperty(
        propertyId: propertyId,
        name: name,
        address: address,
        propertyType: propertyType,
        totalUnits: totalUnits,
        description: description,
      );
      
      await fetchProperties();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Delete property
  Future<bool> deleteProperty(int propertyId) async {
    try {
      await _repository.deleteProperty(propertyId);
      await fetchProperties();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  void clearSelectedProperty() {
    _selectedProperty = null;
    _units = [];
    notifyListeners();
  }
}
