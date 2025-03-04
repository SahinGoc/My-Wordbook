import 'package:my_wordbook/db/dictionary_helper.dart';
import '../models/dictionary.dart';

class DictionaryRepository {
  final DictionaryHelper _dictionaryHelper = DictionaryHelper();

  // Sözlük ekleme (Create)
  Future<int> addDictionary(Dictionary dictionary) async {
    return await _dictionaryHelper.addDictionary(dictionary);
  }

  // Tüm sözlükleri getirme (Read)
  Future<List<Dictionary>> getAllDictionaries() async {
    return await _dictionaryHelper.getAllDictionaries();
  }

  // Sözlük güncelleme (Update)
  Future<void> updateDictionary(Dictionary dictionary) async {
    await _dictionaryHelper.updateDictionary(dictionary);
  }

  //Kelime sayısını 1 arttırır
  Future<void> incrementTotalNumber(int dictionaryId) async {
    await _dictionaryHelper.incrementTotalNumber(dictionaryId);
  }

  //Kelime sayısını 1 azaltır
  Future<void> decreaseTotalNumber(int dictionaryId) async {
    await _dictionaryHelper.decreaseTotalNumber(dictionaryId);
  }

  //Şuan ki toplam kelime
  Future<int> getTotalNumber(int dictionaryId) async {
    return await _dictionaryHelper.getTotalNumber(dictionaryId);
  }

  //Rekoru getirir
  Future<int> getRecord(int dictionaryId) async {
    return await _dictionaryHelper.getRecord(dictionaryId);
  }

  //Rekoru güncelle
  Future<void> setRecord(int id, int record) async {
    await _dictionaryHelper.setRecord(id, record);
  }

  // Sözlük silme (Delete)
  Future<void> deleteDictionary(int id) async {
    await _dictionaryHelper.deleteDictionary(id);
  }
}