import 'package:my_wordbook/models/word.dart';
import 'package:flutter/material.dart';
import '../repositories/word_repository.dart';

class WordOperations extends ChangeNotifier {
  final WordRepository _repository = WordRepository();

  // Kelime ekleme (Create)
  Future<void> addWord(int dictionaryId, String word1, String word2) async {
    await _repository.addWord(dictionaryId, word1, word2);
    notifyListeners();
  }

  // Kelimeleri getirme (Read)
  Future<List<Word>> getWords(int dictionaryId) async {
    return await _repository.getWords(dictionaryId);
  }

  // Kelime güncelleme (Update)
  Future<void> updateWord(int id, String newWord1, String newWord2) async {
    await _repository.updateWord(id, newWord1, newWord2);
    notifyListeners();
  }

  // Kelime silme (Delete)
  Future<void> deleteWord(int id) async {
    await _repository.deleteWord(id);
    notifyListeners();
  }

  //Dil isimlerini getirme
  Future<List<String>> getLanguagesNames(int dictionaryID) async {
    return await _repository.getLanguagesNames(dictionaryID);
  }

  //Kelime bulmak için arama yapma
  Future<List<Word>> getSearchWord(int dictionaryId, String word) async {
    return await _repository.getSearchWord(dictionaryId, word);
  }

  //Anlamına göre arama yapma
  Future<List<Word>> getSearchWordMeaning(int dictionaryId, String mean) async {
    return await _repository.getSearchWordMeaning(dictionaryId, mean);
  }

  //Anlamına göre arama yapma
  Future<List<Word>> getSearchMeanByWords(int dictionaryId, String word) async {
    return await _repository.getSearchMeanByWords(dictionaryId, word);
  }
}
