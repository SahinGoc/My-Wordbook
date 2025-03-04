import '../models/word.dart';
import 'db_helper.dart';

class WordHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Kelime ekleme (Create)
  Future<void> addWord(int dictionaryId, String word1, String word2) async {
    final db = await _dbHelper.database;
    await db.insert('words', {
      'dictionary_id': dictionaryId,
      'word_in_language_1': word1,
      'word_in_language_2': word2,
    });
  }

  // Kelimeleri getirme (Read)
  Future<List<Word>> getWords(int dictionaryId) async {
    final db = await _dbHelper.database;
    final result = await db
        .query('words', where: 'dictionary_id = ?', whereArgs: [dictionaryId]);

    return result.map((map) => Word.fromMap(map)).toList();
  }

  // Kelime güncelleme (Update)
  Future<void> updateWord(int id, String newWord1, String newWord2) async {
    final db = await _dbHelper.database;
    await db.update(
      'words',
      {
        'word_in_language_1': newWord1,
        'word_in_language_2': newWord2,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Kelime silme (Delete)
  Future<void> deleteWord(int id) async {
    final db = await _dbHelper.database;
    await db.delete('words', where: 'id = ?', whereArgs: [id]);
  }

  //Dil isimlerini getirme
  Future<List<String>> getLanguagesNames(int dictionaryID) async {
    final db = await _dbHelper.database;
    final result = await db.query('dictionaries',
        columns: ['language_1_name', 'language_2_name'],
        where: 'id = ?',
        whereArgs: [dictionaryID]);

    if (result.isNotEmpty) {
      return [
        result[0]['language_1_name'] as String,
        result[0]['language_2_name'] as String
      ];
    } else {
      throw Exception('No languages found for this dictionary.');
    }
  }

  //Kelimeye göre arama yapma
  Future<List<Word>> getSearchWord(int dictionaryId, String word) async {
    final db = await _dbHelper.database;
    final result = await db.query('words',
        where: 'dictionary_id = ? and word_in_language_1 LIKE ?',
        whereArgs: [dictionaryId, '%$word%']);

    return result.map((map) => Word.fromMap(map)).toList();
  }

  //Anlamına göre arama yapma
  Future<List<Word>> getSearchWordMeaning(int dictionaryId, String mean) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'words',
      where:
      'dictionary_id = ? AND (word_in_language_2 = ? OR word_in_language_2 LIKE ? OR word_in_language_2 LIKE ? OR word_in_language_2 LIKE ?)',
      whereArgs: [
        dictionaryId,
        mean, // Tam eşleşme
        '$mean,%', // Kelimenin başında ve sonunda virgül
        '%,$mean,%', // Ortada, iki virgül arasında
        '%, $mean', // Sondaki kelime
      ],
    );

    return result.map((map) => Word.fromMap(map)).toList();
  }

  Future<List<Word>> getSearchMeanByWords(int dictionaryId, String word) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'words',
      where:
      'dictionary_id = ? AND (word_in_language_1 = ? OR word_in_language_1 LIKE ? OR word_in_language_1 LIKE ? OR word_in_language_1 LIKE ?)',
      whereArgs: [
        dictionaryId,
        word, // Tam eşleşme
        '$word,%', // Kelimenin başında ve sonunda virgül
        '%,$word,%', // Ortada, iki virgül arasında
        '%, $word', // Sondaki kelime
      ],
    );

    return result.map((map) => Word.fromMap(map)).toList();
  }

}