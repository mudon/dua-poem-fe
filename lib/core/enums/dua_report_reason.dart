enum DuaReportReason {
  wrongArabicText('wrong_arabic_text'),
  wrongTransliteration('wrong_transliteration'),
  wrongTranslation('wrong_translation'),
  wrongSource('wrong_source'),
  inappropriateContent('inappropriate_content'),
  duplicateDua('duplicate_dua'),
  other('other');

  final String value;
  const DuaReportReason(this.value);

  String get displayName {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  static DuaReportReason fromValue(String value) {
    return DuaReportReason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => DuaReportReason.other,
    );
  }
}
