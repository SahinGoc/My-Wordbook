class Language {
  int? id;
  String languageName;

  Language({this.id, required this.languageName});

  // Veritabanından Map olarak veri aldığımızda bu sınıfa çevirme
  factory Language.fromMap(Map<String, dynamic> json) {

    return Language(
      id: json['id'],
      languageName: json['language_name'],
    );
  }

  // Veriyi Map'e çevirerek veritabanına ekleme/güncelleme işlemleri için kullanma
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language_name': languageName,
    };
  }
}