import 'package:my_wordbook/models/language.dart';
import 'package:my_wordbook/repositories/language_repository.dart';
import 'package:flutter/material.dart';

class LanguageOperations extends ChangeNotifier {
  final LanguageRepository _repository = LanguageRepository();

  //Dil ekleme (Create)
  Future<int> addLanguage(Language lang) async {
    return await _repository.addLanguage(lang);
  }

  //Tüm dilleri getirme (Read)
  Future<List<Language>> getAllLanguages() async {
    return await _repository.getAllLanguages();
  }

  //Dili güncelleme (Update)
  Future<void> updateLanguages(Language language) async {
    await _repository.updateLanguages(language);
    notifyListeners();
  }

  //Dil silme (Delete)
  Future<void> deleteLanguages(int id) async {
    await _repository.deleteLanguages(id);
    notifyListeners();
  }
}
