class CreateBillResponse {
  final String donationId;
  final String paymentUrl;
  final String billCode;

  CreateBillResponse({
    required this.donationId,
    required this.paymentUrl,
    required this.billCode,
  });

  factory CreateBillResponse.fromJson(Map<String, dynamic> json) {
    return CreateBillResponse(
      donationId: json['donationId'].toString(),
      paymentUrl: json['paymentUrl'] as String,
      billCode: json['billCode'] as String,
    );
  }
}
