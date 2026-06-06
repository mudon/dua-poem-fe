class DuaContentUpdateModel {
  final String id;
  final String title;
  final String? arabicText;
  final String? transliteration;
  final String? translation;
  final String? description;
  final String? whenToRecite;
  final String? occasion;
  final int repetitionCount;
  final String updatedAt;

  DuaContentUpdateModel({
    required this.id,
    required this.title,
    this.arabicText,
    this.transliteration,
    this.translation,
    this.description,
    this.whenToRecite,
    this.occasion,
    required this.repetitionCount,
    required this.updatedAt,
  });

  factory DuaContentUpdateModel.fromJson(Map<String, dynamic> json) {
    return DuaContentUpdateModel(
      id: json['duaId'].toString(),
      title: json['title'] ?? '',
      arabicText: json['arabicText'] as String?,
      transliteration: json['transliteration'] as String?,
      translation: json['translation'] as String?,
      description: json['description'] as String?,
      whenToRecite: json['whenToRecite'] as String?,
      occasion: json['occasion'] as String?,
      repetitionCount: json['repetitionCount'] ?? 0,
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}
