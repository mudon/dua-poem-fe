class PoemContentUpdateModel {
  final String id;
  final String title;
  final String? content;
  final String? transliteration;
  final String? translation;
  final String? description;
  final String? author;
  final String updatedAt;

  PoemContentUpdateModel({
    required this.id,
    required this.title,
    this.content,
    this.transliteration,
    this.translation,
    this.description,
    this.author,
    required this.updatedAt,
  });

  factory PoemContentUpdateModel.fromJson(Map<String, dynamic> json) {
    return PoemContentUpdateModel(
      id: json['poemId'].toString(),
      title: json['title'] ?? '',
      content: json['content'] as String?,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      description: json['description'] as String?,
      author: json['author'] as String?,
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
