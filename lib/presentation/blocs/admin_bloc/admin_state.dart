import '../../../data/models/admin/pending_revision_model.dart';

class AdminState {
  final List<PendingRevisionModel> revisions;
  final bool isLoading;
  final String? error;
  final bool isReviewing;
  final String? reviewSuccess;

  AdminState({
    this.revisions = const [],
    this.isLoading = false,
    this.error,
    this.isReviewing = false,
    this.reviewSuccess,
  });

  AdminState copyWith({
    List<PendingRevisionModel>? revisions,
    bool? isLoading,
    String? error,
    bool? isReviewing,
    String? reviewSuccess,
    bool clearError = false,
    bool clearReviewSuccess = false,
  }) {
    return AdminState(
      revisions: revisions ?? this.revisions,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
      isReviewing: isReviewing ?? this.isReviewing,
      reviewSuccess: clearReviewSuccess ? null : reviewSuccess ?? this.reviewSuccess,
    );
  }
}
