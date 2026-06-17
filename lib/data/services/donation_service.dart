import '../../core/network/dio_client.dart';

class DonationService {
  final DioClient _dioClient;

  DonationService(this._dioClient);

  Future<Map<String, dynamic>> createBill(double amount, {String? name, String? email, String? phone}) async {
    final response = await _dioClient.dio.post('/donations/create-bill', data: {
      'amount': amount,
      'name': name,
      'email': email,
      'phone': phone,
    });
    return response.data as Map<String, dynamic>;
  }
}
