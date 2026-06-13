enum PoemReportReason {
  wrongTransliteration('wrong_transliteration'),
  wrongTranslation('wrong_translation'),
  wrongAuthor('wrong_author'),
  inappropriateContent('inappropriate_content'),
  duplicatePoem('duplicate_poem'),
  copyrightViolation('copyright_violation'),
  other('other');

  final String value;
  const PoemReportReason(this.value);

  String get displayName {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  static PoemReportReason fromValue(String value) {
    return PoemReportReason.values.firstWhere(
      (e) => e.value == value,
      orElse: () => PoemReportReason.other,
    );
  }
}
