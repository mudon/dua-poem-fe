import '../../../core/enums/content_type.dart';

abstract class AdminEvent {}

class LoadPendingRevisions extends AdminEvent {}

class ReviewRevision extends AdminEvent {
  final String revisionId;
  final ContentType contentType;
  final Map<String, String> actions;

  ReviewRevision({
    required this.revisionId,
    required this.contentType,
    required this.actions,
  });
}
