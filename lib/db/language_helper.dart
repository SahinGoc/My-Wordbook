import '../models/language.dart';
import 'db_helper.dart';

class LanguageHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  //Dil ekleme (Create)
  Future<int> addLanguage(Language lang) async {
    final db = await _dbHelper.database;
    return await db.insert('languages', lang.toMap());
  }

  //Tüm dilleri getirme (Read)
  Future<List<Language>> getAllLanguages() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('languages');
    return List.generate(maps.length, (i) {
      return Language.fromMap(maps[i]);
    });
  }

  //Dili güncelleme (Update)
  Future<void> updateLanguages(Language language) async {
    final db = await _dbHelper.database;
    await db.update('languages', language.toMap(),
        where: 'id = ?', whereArgs: [language.id]);
  }

  //Dil silme (Delete)
  Future<void> deleteLanguages(int id) async {
    final db = await _dbHelper.database;
    await db.delete('languages', where: 'id = ?', whereArgs: [id]);
  }
}