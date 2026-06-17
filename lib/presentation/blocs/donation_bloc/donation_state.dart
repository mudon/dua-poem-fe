part of 'donation_bloc.dart';

abstract class DonationState {}

class DonationInitial extends DonationState {}

class DonationLoading extends DonationState {}

class DonationSuccess extends DonationState {
  final String paymentUrl;

  DonationSuccess({required this.paymentUrl});
}

class DonationError extends DonationState {
  final String message;

  DonationError({required this.message});
}
