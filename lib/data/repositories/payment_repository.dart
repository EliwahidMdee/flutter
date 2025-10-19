import '../models/payment_model.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_constants.dart';

class PaymentRepository {
  final ApiClient _client;
  
  PaymentRepository(this._client);
  
  Future<List<PaymentModel>> getPayments({
    String? status,
    int? tenantId,
    int? propertyId,
    int page = 1,
    int perPage = 15,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    
    if (status != null) queryParams['status'] = status;
    if (tenantId != null) queryParams['tenant_id'] = tenantId;
    if (propertyId != null) queryParams['property_id'] = propertyId;
    
    final response = await _client.get(
      ApiEndpoints.payments,
      queryParameters: queryParams,
    );
    
    final data = response.data['data'] as List;
    return data.map((json) => PaymentModel.fromJson(json)).toList();
  }
  
  Future<List<PaymentModel>> getPendingPayments() async {
    final response = await _client.get(ApiEndpoints.pendingPayments);
    final data = response.data['data'] as List;
    return data.map((json) => PaymentModel.fromJson(json)).toList();
  }
  
  Future<PaymentModel> getPaymentById(int id) async {
    final response = await _client.get(ApiEndpoints.paymentDetail(id));
    return PaymentModel.fromJson(response.data['data']);
  }
  
  Future<PaymentModel> createPayment({
    required int tenantId,
    required int propertyId,
    required double amount,
    required String paymentDate,
    required String paymentMethod,
    String? notes,
    String? referenceNumber,
  }) async {
    final response = await _client.post(
      ApiEndpoints.payments,
      data: {
        'tenant_id': tenantId,
        'property_id': propertyId,
        'amount': amount,
        'payment_date': paymentDate,
        'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
        if (referenceNumber != null) 'reference_number': referenceNumber,
      },
    );
    
    return PaymentModel.fromJson(response.data['data']);
  }
  
  Future<PaymentModel> verifyPayment(int paymentId) async {
    final response = await _client.post(
      ApiEndpoints.verifyPayment(paymentId),
    );
    
    return PaymentModel.fromJson(response.data['data']);
  }
  
  Future<void> deletePayment(int paymentId) async {
    await _client.delete(ApiEndpoints.paymentDetail(paymentId));
  }
  
  Future<PaymentModel> updatePayment({
    required int paymentId,
    double? amount,
    String? paymentDate,
    String? paymentMethod,
    String? notes,
    String? status,
  }) async {
    final response = await _client.put(
      ApiEndpoints.paymentDetail(paymentId),
      data: {
        if (amount != null) 'amount': amount,
        if (paymentDate != null) 'payment_date': paymentDate,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (notes != null) 'notes': notes,
        if (status != null) 'status': status,
      },
    );
    
    return PaymentModel.fromJson(response.data['data']);
  }
}
