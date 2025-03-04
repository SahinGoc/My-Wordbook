import 'package:flutter/material.dart';

import '../models/dictionary.dart';
import 'db_helper.dart';

class DictionaryHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  // Sözlük ekleme (Create)
  Future<int> addDictionary(Dictionary dictionary) async {
    final db = await _dbHelper.database;
    var result = await db.insert('dictionaries', dictionary.toMap());
    return result;
  }

  // Tüm sözlükleri getirme (Read)
  Future<List<Dictionary>> getAllDictionaries() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('dictionaries');

    return List.generate(maps.length, (i) {
      return Dictionary.fromMap(maps[i]);
    });
  }

  // Sözlük güncelleme (Update)
  Future<void> updateDictionary(Dictionary dictionary) async {
    final db = await _dbHelper.database;
    await db.update(
      'dictionaries',
      dictionary.toMap(),
      where: 'id = ?',
      whereArgs: [dictionary.id],
    );
  }

  //Kelime sayısını 1 arttırır
  Future<void> incrementTotalNumber(int dictionaryId) async {
    final db = await _dbHelper.database;
    await db.update(
      'dictionaries',
      {'total_number': (await getTotalNumber(dictionaryId)) + 1},
      where: 'id = ?',
      whereArgs: [dictionaryId],
    );
  }

  //Kelime sayısını 1 azaltır
  Future<void> decreaseTotalNumber(int dictionaryId) async {
    final db = await _dbHelper.database;
    await db.update(
      'dictionaries',
      {'total_number': (await getTotalNumber(dictionaryId)) - 1},
      where: 'id = ?',
      whereArgs: [dictionaryId],
    );
  }

  //Şuan ki toplam kelime
  Future<int> getTotalNumber(int dictionaryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'dictionaries',
      columns: ['total_number'],
      where: 'id = ?',
      whereArgs: [dictionaryId],
    );

    // Eğer sonuç varsa, total_number değerini döndür
    if (result.isNotEmpty) {
      int? number = result.first['total_number'] as int;
      return number ?? 0;
    }

    return 0;
  }

  //Rekoru getirir
  Future<int> getRecord(int dictionaryId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'dictionaries',
      columns: ['record'],
      where: 'id = ?',
      whereArgs: [dictionaryId],
    );

    // Eğer sonuç varsa, record değerini döndür
    if (result.isNotEmpty) {
      int? record = result.first['record'] as int;
      return record ?? 0;
    }
    return 0;
  }

  //Rekoru güncelle
  Future<void> setRecord(int id, int record) async {
    try {
      final db = await _dbHelper.database;
      final result = await db.update(
          'dictionaries',
          {'record': record},
          where: 'id = ?',
          whereArgs: [id]
      );
      if (result > 0) {
        debugPrint(result.toString());
      } else {
        debugPrint("No rows updated");
      }
    } catch (e) {
      debugPrint("Error updating record: $e");
    }
  }

  // Sözlük silme (Delete)
  Future<void> deleteDictionary(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      'dictionaries',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}