import 'package:flutter/material.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/fonts_utils.dart';

class ThemeOperations with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  late AnimationController animationController;

  void initController(TickerProvider vsync) {
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    animationFirstPosition();
  }

  void animationFirstPosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (themeMode == ThemeMode.dark) {
        animationController.value = 1.0;
      } else {
        animationController.value = 0.0;
      }
      notifyListeners();
    });
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    if (_themeMode == ThemeMode.dark) {
      animationController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    } else {
      animationController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    }

    notifyListeners();

    // Tema modunu kaydet
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  void attachTicker(TickerProvider vsync) {
    animationController.dispose();
    animationController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 500),
    );
    animationFirstPosition();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future<void> loadInitialThemeMode(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDarkMode = prefs.getBool('isDarkMode');

    if (isDarkMode == null) {
      // Cihazın sistem temasını al
      if (context.mounted) {
        var brightness = MediaQuery.of(context).platformBrightness;
        _themeMode =
            brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
      }
    } else {
      // Kaydedilen tema modunu yükle
      _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }

    animationController.value = _themeMode == ThemeMode.dark ? 1.0 : 0.0;
    notifyListeners();
  }

  double getTextScaleFactor(BuildContext context) {
    final storeOperations =
        Provider.of<StoreOperations>(context, listen: false);

    return FontsUtils.getFontScaleFactor(
      themeMode == ThemeMode.dark
          ? storeOperations.fontStyleDark
          : storeOperations.fontStyleLight,
    );
  }

  //Layout değiştirme

  bool _isGridView = false;

  bool get isGridView => _isGridView;

  Future<void> toggleViewMode() async {
    _isGridView = !_isGridView;
    notifyListeners();
    await _saveViewMode();
  }

  Future<void> _saveViewMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', _isGridView);
  }

  Future<void> loadViewMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isGridView = prefs.getBool('isGridView') ?? false;
    notifyListeners();
  }
}
