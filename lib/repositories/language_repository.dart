import 'package:my_wordbook/db/language_helper.dart';

import '../models/language.dart';

class LanguageRepository {
  final LanguageHelper _languageHelper = LanguageHelper();

  //Dil ekleme (Create)
  Future<int> addLanguage(Language lang) async {
    return await _languageHelper.addLanguage(lang);
  }

  //Tüm dilleri getirme (Read)
  Future<List<Language>> getAllLanguages() async {
    return await _languageHelper.getAllLanguages();
  }

  //Dili güncelleme (Update)
  Future<void> updateLanguages(Language language) async {
    await _languageHelper.updateLanguages(language);
  }

  //Dil silme (Delete)
  Future<void> deleteLanguages(int id) async {
    await _languageHelper.deleteLanguages(id);
  }
}