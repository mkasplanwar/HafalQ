// Model Ayat untuk data detail surah dari API Qur'an
class Ayat {
  final int number;
  final String arab;
  final String latin;
  final String translation;
  final String audioUrl;

  Ayat({
    required this.number,
    required this.arab,
    required this.latin,
    required this.translation,
    required this.audioUrl,
  });

  // Factory untuk parsing dari api.quran.sutanlab.id
  factory Ayat.fromSutanlab(Map<String, dynamic> json) {
    return Ayat(
      number: json['number']['inSurah'] ?? 0,
      arab: json['text']['arab'] ?? '',
      latin: json['text']['transliteration']?['id'] ?? '',
      translation: json['translation']['id'] ?? '',
      audioUrl: json['audio']['primary'] ?? '',
    );
  }

  factory Ayat.fromJson(Map<String, dynamic> json) {
    String latin = '';
    final translit = json['text']['transliteration'];
    if (translit != null && translit['id'] != null && translit['id'] is String) {
      latin = translit['id'];
    }
    return Ayat(
      number: json['number']['inSurah'],
      arab: json['text']['arab'] ?? '',
      latin: latin,
      translation: json['translation']['id'] ?? '',
      audioUrl: json['audio']['primary'] ?? '',
    );
  }
}
