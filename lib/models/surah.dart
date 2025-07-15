// Model Surah untuk data dari API Qur'an
class Surah {
  final int number;
  final String name;
  final String translation;
  final int ayahCount;

  Surah({
    required this.number,
    required this.name,
    required this.translation,
    required this.ayahCount,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'],
      name: json['name']['transliteration']['id'],
      translation: json['name']['translation']['id'],
      ayahCount: json['numberOfVerses'],
    );
  }
}
