import '../models/property_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class PropertyRepository {
  final ApiClient _client;
  
  PropertyRepository(this._client);
  
  Future<List<PropertyModel>> getProperties({
    int page = 1,
    int perPage = 15,
  }) async {
    final response = await _client.get(
      ApiEndpoints.properties,
      queryParameters: {
        'page': page,
        'per_page': perPage,
      },
    );
    
    final data = response.data['data'] as List;
    return data.map((json) => PropertyModel.fromJson(json)).toList();
  }
  
  Future<PropertyModel> getPropertyById(int id) async {
    final response = await _client.get(ApiEndpoints.propertyDetail(id));
    return PropertyModel.fromJson(response.data['data']);
  }
  
  Future<List<UnitModel>> getPropertyUnits(int propertyId) async {
    final response = await _client.get(ApiEndpoints.propertyUnits(propertyId));
    final data = response.data['data'] as List;
    return data.map((json) => UnitModel.fromJson(json)).toList();
  }
  
  Future<PropertyModel> createProperty({
    required String name,
    required String address,
    required String propertyType,
    required int totalUnits,
    String? description,
  }) async {
    final response = await _client.post(
      ApiEndpoints.properties,
      data: {
        'name': name,
        'address': address,
        'property_type': propertyType,
        'total_units': totalUnits,
        if (description != null) 'description': description,
      },
    );
    
    return PropertyModel.fromJson(response.data['data']);
  }
  
  Future<PropertyModel> updateProperty({
    required int propertyId,
    String? name,
    String? address,
    String? propertyType,
    int? totalUnits,
    String? description,
  }) async {
    final response = await _client.put(
      ApiEndpoints.propertyDetail(propertyId),
      data: {
        if (name != null) 'name': name,
        if (address != null) 'address': address,
        if (propertyType != null) 'property_type': propertyType,
        if (totalUnits != null) 'total_units': totalUnits,
        if (description != null) 'description': description,
      },
    );
    
    return PropertyModel.fromJson(response.data['data']);
  }
  
  Future<void> deleteProperty(int propertyId) async {
    await _client.delete(ApiEndpoints.propertyDetail(propertyId));
  }
}
