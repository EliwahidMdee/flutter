import 'package:flutter/foundation.dart';
import '../../../data/models/payment_model.dart';
import '../../../data/repositories/payment_repository.dart';

enum PaymentViewStatus { initial, loading, loaded, error }

class PaymentProvider with ChangeNotifier {
  final PaymentRepository _repository;
  
  PaymentViewStatus _status = PaymentViewStatus.initial;
  List<PaymentModel> _payments = [];
  List<PaymentModel> _pendingPayments = [];
  PaymentModel? _selectedPayment;
  String? _error;
  
  PaymentProvider(this._repository);
  
  // Getters
  PaymentViewStatus get status => _status;
  List<PaymentModel> get payments => _payments;
  List<PaymentModel> get pendingPayments => _pendingPayments;
  PaymentModel? get selectedPayment => _selectedPayment;
  String? get error => _error;
  bool get isLoading => _status == PaymentViewStatus.loading;
  
  // Fetch all payments
  Future<void> fetchPayments({
    String? status,
    int? tenantId,
    int? propertyId,
  }) async {
    _status = PaymentViewStatus.loading;
    notifyListeners();
    
    try {
      _payments = await _repository.getPayments(
        status: status,
        tenantId: tenantId,
        propertyId: propertyId,
      );
      _status = PaymentViewStatus.loaded;
      _error = null;
    } catch (e) {
      _status = PaymentViewStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Fetch pending payments
  Future<void> fetchPendingPayments() async {
    try {
      _pendingPayments = await _repository.getPendingPayments();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
  
  // Get payment by ID
  Future<void> fetchPaymentById(int id) async {
    _status = PaymentViewStatus.loading;
    notifyListeners();
    
    try {
      _selectedPayment = await _repository.getPaymentById(id);
      _status = PaymentViewStatus.loaded;
      _error = null;
    } catch (e) {
      _status = PaymentViewStatus.error;
      _error = e.toString();
    }
    
    notifyListeners();
  }
  
  // Approve payment
  Future<bool> approvePayment(int paymentId) async {
    try {
      await _repository.verifyPayment(paymentId);
      
      // Refresh lists
      await Future.wait([
        fetchPayments(),
        fetchPendingPayments(),
      ]);
      
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Create payment
  Future<bool> createPayment({
    required int tenantId,
    required int propertyId,
    required double amount,
    required String paymentDate,
    required String paymentMethod,
    String? notes,
    String? referenceNumber,
  }) async {
    try {
      await _repository.createPayment(
        tenantId: tenantId,
        propertyId: propertyId,
        amount: amount,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        notes: notes,
        referenceNumber: referenceNumber,
      );
      
      await fetchPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Update payment
  Future<bool> updatePayment({
    required int paymentId,
    double? amount,
    String? paymentDate,
    String? paymentMethod,
    String? notes,
  }) async {
    try {
      await _repository.updatePayment(
        paymentId: paymentId,
        amount: amount,
        paymentDate: paymentDate,
        paymentMethod: paymentMethod,
        notes: notes,
      );
      
      await fetchPayments();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  // Delete payment
  Future<bool> deletePayment(int paymentId) async {
    try {
      await _repository.deletePayment(paymentId);
      await fetchPayments();
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
  
  void clearSelectedPayment() {
    _selectedPayment = null;
    notifyListeners();
  }
}
