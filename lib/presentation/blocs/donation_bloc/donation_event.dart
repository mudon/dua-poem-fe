part of 'donation_bloc.dart';

abstract class DonationEvent {}

class CreateBill extends DonationEvent {
  final double amount;
  final String? name;
  final String? email;
  final String? phone;

  CreateBill({required this.amount, this.name, this.email, this.phone});
}

class ResetDonation extends DonationEvent {}
