import 'dart:async';
import 'package:my_wordbook/repositories/dictionary_repository.dart';
import 'package:flutter/material.dart';
import 'package:my_wordbook/models/dictionary.dart';

class DictionaryOperations extends ChangeNotifier {
  final DictionaryRepository _repository = DictionaryRepository();

  // Sözlük ekleme (Create)
  Future<int> addDictionary(Dictionary dictionary) async {
    final resultID = await _repository.addDictionary(dictionary);
    notifyListeners();
    return resultID;
  }

  // Tüm sözlükleri getirme (Read)
  Future<List<Dictionary>> getAllDictionaries() async {
    return await _repository.getAllDictionaries();
  }

  // Sözlük güncelleme (Update)
  Future<void> updateDictionary(Dictionary dictionary) async {
    await _repository.updateDictionary(dictionary);
    notifyListeners();
  }

  //Kelime sayısını 1 arttırır
  Future<void> incrementTotalNumber(int dictionaryId) async {
    await _repository.incrementTotalNumber(dictionaryId);
  }

  //Kelime sayısını 1 azaltır
  Future<void> decreaseTotalNumber(int dictionaryId) async {
    await _repository.decreaseTotalNumber(dictionaryId);
  }

  //Şuan ki toplam kelime
  Future<int> getTotalNumber(int dictionaryId) async {
    return await _repository.getTotalNumber(dictionaryId);
  }

  //Rekoru getirir
  Future<int> getRecord(int dictionaryId) async {
    final record = await _repository.getRecord(dictionaryId);
    notifyListeners();
    return record;
  }

  //Rekoru güncelle
  void setRecord(int id, int record) async {
    await _repository.setRecord(id, record);
  }

  // Sözlük silme (Delete)
  void deleteDictionary(int id) async {
    await _repository.deleteDictionary(id);
  }


}
