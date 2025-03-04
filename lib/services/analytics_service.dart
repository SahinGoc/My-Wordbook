import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Buton tıklama event'i loglama
  static Future<void> logButtonClick(String buttonName) async {
    await _analytics.logEvent(
      name: 'button_click',
      parameters: {'button_name': buttonName},
    );
  }

  /// Sayfa görüntüleme event'i loglama
  static Future<void> logScreenView(String screenName) async {
    await _analytics.logEvent(
      name: 'screen_view',
      parameters: {'screen_name': screenName},
    );
  }

  /// Quiz cevabı loglama
  static Future<void> logQuizAnswer(
      String question, String answer, bool isCorrect) async {
    await _analytics.logEvent(
      name: 'quiz_answer',
      parameters: {
        'question': question,
        'answer': answer,
        'is_correct': isCorrect ? "true" : "false",
      },
    );
  }

  /// Tema değişikliğini loglama
  static Future<void> logThemeChange(bool isDarkMode) async {
    await _analytics.logEvent(
      name: 'theme_change',
      parameters: {'theme': isDarkMode ? "dark" : "light"},
    );
  }

  /// İtem satın alma loglama
  static Future<void> logItemPurchase(
      int subcategoryId, String colorName) async {
    List<String> subcategories = [
      'Tema Renkleri',
      'Arkaplan Renkleri',
      'Yazı Renkleri',
      'İkon Renkleri',
      'Sol Kart Renkleri',
      'Sağ Kart Renkleri',
      'FAB Renkleri',
      'FAB İkon Renkleri'
    ];
    await _analytics.logEvent(
      name: 'item_purchase',
      parameters: {
        'subcategory_id': subcategoryId,
        'subcategory_name': subcategories[subcategoryId - 1],
        'color_name': colorName
      },
    );
  }

  /// İtem değiştirme loglama
  static Future<void> logItemChange(
      int subcategoryId, String colorName) async {
    List<String> subcategories = [
      'Tema Renkleri',
      'Arkaplan Renkleri',
      'Yazı Renkleri',
      'İkon Renkleri',
      'Sol Kart Renkleri',
      'Sağ Kart Renkleri',
      'FAB Renkleri',
      'FAB İkon Renkleri'
    ];
    await _analytics.logEvent(
      name: 'item_change',
      parameters: {
        'subcategory_id': subcategoryId,
        'subcategory_name': subcategories[subcategoryId - 1],
        'color_name': colorName
      },
    );
  }

  /// Font satın alma loglama
  static Future<void> logFontPurchase(String fontName) async {
    await _analytics.logEvent(
      name: 'font_purchase',
      parameters: {'font_name': fontName},
    );
  }

  /// Font değiştirme loglama
  static Future<void> logFontChange(String fontName) async {
    await _analytics.logEvent(
      name: 'font_change',
      parameters: {'font_name': fontName},
    );
  }

  /// Quiz tamamlandı loglama
  static Future<void> logQuizCompleted(
      int numberOfTrue, int numberOfFalse, int numberOfRecord) async {
    await _analytics.logEvent(name: 'quiz_completed', parameters: {
      'number_of_true': numberOfTrue.toString(),
      'number_of_false': numberOfFalse.toString(),
      'number_of_record': numberOfRecord.toString
    });
  }

  /// Ödüllü reklam izlendi loglama
  static Future<void> logRewardedAdClicked(int money) async {
    await _analytics.logEvent(
      name: 'rewarded_ad_clicked',
      parameters: {'rewarded_money': money.toString()},
    );
  }
}
