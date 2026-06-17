import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/donation_repository.dart';

part 'donation_event.dart';
part 'donation_state.dart';

class DonationBloc extends Bloc<DonationEvent, DonationState> {
  final DonationRepository _donationRepository;

  DonationBloc(this._donationRepository) : super(DonationInitial()) {
    on<CreateBill>(_onCreateBill);
    on<ResetDonation>(_onReset);
  }

  Future<void> _onCreateBill(CreateBill event, Emitter<DonationState> emit) async {
    emit(DonationLoading());
    final result = await _donationRepository.createBill(
      event.amount,
      name: event.name,
      email: event.email,
      phone: event.phone,
    );
    if (result.isSuccess) {
      emit(DonationSuccess(paymentUrl: result.data!.paymentUrl));
    } else {
      emit(DonationError(message: result.error ?? 'Ralat berlaku'));
    }
  }

  void _onReset(ResetDonation event, Emitter<DonationState> emit) {
    emit(DonationInitial());
  }
}
