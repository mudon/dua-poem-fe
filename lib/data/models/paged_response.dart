class PagedResponse<T> {
  final List<T> data;
  final String? nextCursor;
  final bool hasMore;

  PagedResponse({
    required this.data,
    this.nextCursor,
    required this.hasMore,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromItem,
  ) {
    return PagedResponse(
      data: (json['data'] as List)
          .map((e) => fromItem(e as Map<String, dynamic>))
          .toList(),
      nextCursor: json['nextCursor'] as String?,
      hasMore: json['hasMore'] as bool,
    );
  }
}
