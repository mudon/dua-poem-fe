import '../../core/errors/error_helper.dart';
import '../../core/network/api_result.dart';
import '../models/donation_model.dart';
import '../services/donation_service.dart';

class DonationRepository {
  final DonationService _donationService;

  DonationRepository(this._donationService);

  Future<ApiResult<CreateBillResponse>> createBill(double amount, {String? name, String? email, String? phone}) async {
    try {
      final data = await _donationService.createBill(amount, name: name, email: email, phone: phone);
      return ApiResult.success(CreateBillResponse.fromJson(data));
    } catch (e) {
      return ApiResult.failure(e.userMessage);
    }
  }
}
