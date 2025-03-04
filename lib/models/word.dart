class Word {
  int? id;
  int dictionaryId;
  String wordInLanguage1;
  String wordInLanguage2;

  Word({this.id, required this.dictionaryId, required this.wordInLanguage1, required this.wordInLanguage2});

  // Veritabanından Map olarak veri aldığımızda bu sınıfa çevirme
  factory Word.fromMap(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      dictionaryId: json['dictionary_id'],
      wordInLanguage1: json['word_in_language_1'],
      wordInLanguage2: json['word_in_language_2'],
    );
  }

  // Veriyi Map'e çevirerek veritabanına ekleme/güncelleme işlemleri için kullanma
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dictionary_id': dictionaryId,
      'word_in_language_1': wordInLanguage1,
      'word_in_language_2': wordInLanguage2,
    };
  }
}