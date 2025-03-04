class Dictionary {
  int? id;
  int language1Id;
  int language2Id;
  String language1Name;
  String language2Name;
  int totalNumber;
  int record;

  Dictionary(
      {this.id,
      required this.language1Id,
      required this.language2Id,
      required this.language1Name,
      required this.language2Name,
      required this.totalNumber,
      required this.record});

  // Veritabanından Map olarak veri aldığımızda bu sınıfa çevirme
  factory Dictionary.fromMap(Map<String, dynamic> json) {
    return Dictionary(
      id: json['id'],
      language1Id: json['language_1_id'],
      language2Id: json['language_2_id'],
      language1Name: json['language_1_name'],
      language2Name: json['language_2_name'],
      totalNumber: json['total_number'],
      record: json['record']
    );
  }

  // Veriyi Map'e çevirerek veritabanına ekleme/güncelleme işlemleri için kullanma
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language_1_id': language1Id,
      'language_2_id': language2Id,
      'language_1_name': language1Name,
      'language_2_name': language2Name,
      'total_number' : totalNumber,
      'record' : record
    };
  }
}
