import 'package:my_wordbook/db/word_helper.dart';

import '../models/word.dart';

class WordRepository {

  final WordHelper _wordHelper = WordHelper();

  // Kelime ekleme (Create)
  Future<void> addWord(int dictionaryId, String word1, String word2) async {
    await _wordHelper.addWord(dictionaryId, word1, word2);
  }

  // Kelimeleri getirme (Read)
  Future<List<Word>> getWords(int dictionaryId) async {
    return await _wordHelper.getWords(dictionaryId);
  }

  // Kelime güncelleme (Update)
  Future<void> updateWord(int id, String newWord1, String newWord2) async {
    await _wordHelper.updateWord(id, newWord1, newWord2);
  }

  // Kelime silme (Delete)
  Future<void> deleteWord(int id) async {
    await _wordHelper.deleteWord(id);
  }

  //Dil isimlerini getirme
  Future<List<String>> getLanguagesNames(int dictionaryID) async {
    return await _wordHelper.getLanguagesNames(dictionaryID);
  }

  //Kelime bulmak için arama yapma
  Future<List<Word>> getSearchWord(int dictionaryId, String word) async {
    return await _wordHelper.getSearchWord(dictionaryId, word);
  }

  //Anlamına göre arama yapma
  Future<List<Word>> getSearchWordMeaning(int dictionaryId, String mean) async {
    return await _wordHelper.getSearchWordMeaning(dictionaryId, mean);
  }

  //Kelimeye göre arama yapma
  Future<List<Word>> getSearchMeanByWords(int dictionaryId, String word) async {
    return await _wordHelper.getSearchMeanByWords(dictionaryId, word);
  }
}