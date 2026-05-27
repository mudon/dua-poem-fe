import '../../../data/models/tag_model.dart';

class TagState {
  final bool isLoading;
  final String? error;
  final List<TagModel> tags;

  TagState({
    this.isLoading = false,
    this.error,
    this.tags = const [],
  });

  TagState copyWith({
    bool? isLoading,
    String? error,
    List<TagModel>? tags,
  }) {
    return TagState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      tags: tags ?? this.tags,
    );
  }
}
