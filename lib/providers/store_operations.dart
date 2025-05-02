import 'package:my_wordbook/models/store.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repositories/store_repository.dart';

class StoreOperations extends ChangeNotifier {
  //Başlık değiştirme
  String _title = "KELİME DEFTERİM";
  String get title => _title;

  Future<void> loadTitle() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _title = prefs.getString('title') ?? "KELİME DEFTERİM";
  }

  Future<void> setTitle(String title) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('title', title);
    _title = title;
    notifyListeners();
  }


  //PARA İŞLEMLERİ
  int _totalMoney = 500;
  int get totalMoney => _totalMoney;

  //Parayı yükleme
  Future<void> loadTotalMoney() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _totalMoney = prefs.getInt('money') ?? 500;
  }

  //Parayı artırma veya azaltma
  Future<bool> calculateMoney(int money) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int currentMoney = prefs.getInt('money') ?? 500;

    if (currentMoney + money >= 0) {
      int updatedMoney = currentMoney + money;

      // Yeni bakiyeyi kaydet
      await prefs.setInt('money', updatedMoney);
      _totalMoney = updatedMoney;

      // Dinleyicileri bilgilendir
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }


  //STORE İŞLEMLERİ
  List<Category> categories = [];
  List<Subcategory> subcategories = [];
  List<Item> itemsColors = [];
  List<Item> itemsFonts = [];

  final StoreRepository _repository = StoreRepository();

  Future<List<Subcategory>> loadSubcategories(int categoryId) async {
    return await _repository.getSubcategories(categoryId);
  }

  void updateSubcategories(int categoryId) async {
    subcategories = await _repository.getSubcategories(categoryId);
    notifyListeners();
  }


  Future<bool> loadColorsItems(int subcategoryId) async {
    itemsColors = await _repository.getColorsItems(subcategoryId);
    notifyListeners();
    return true;
  }

  Future<bool> loadFontsItems() async {
    itemsFonts = await _repository.getFontsItems();
    notifyListeners();
    return true;
  }

  Future<bool> purchaseItem(int itemId, int subcategoryId, int index) async {

    bool result = await calculateMoney(subcategoryId == -1
        ? itemsFonts[index].price * -1
        : itemsColors[index - 1].price * -1);

    if (result) {
      await _repository.purchaseItem(itemId, subcategoryId);

      if (subcategoryId == -1) {
        itemsFonts[index].isPurchased = true;
      } else {
        itemsColors[index - 1].isPurchased = true;
      }

      notifyListeners();
      return true;
    }

    return false;
  }



  Future<void> insertMainCategories() async {
    await _repository.insertMainCategories();
    categories = await _repository.getCategories();
    notifyListeners();
  }

  Future<void> insertColors() async {
    await _repository.insertColors();
    notifyListeners();
  }

  Future<void> insertFonts() async {
    await _repository.insertFonts();
    notifyListeners();
  }

  //FONT DEĞİŞTİRME İŞLEMLERİ

  //Dark Theme Font
  int _selectedFontDarkIndex = 0;

  int get selectedFontDarkIndex => _selectedFontDarkIndex;

  String _fontStyleDark = 'Roboto';
  String get fontStyleDark => _fontStyleDark;

  Future<void> loadInitialDarkIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('fontStyleDarkIndex') ?? 0;
    _selectedFontDarkIndex = index;
    notifyListeners();
  }

  Future<void> setFontDarkIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('fontStyleDarkIndex', index);
    _selectedFontDarkIndex = index;
    notifyListeners();
  }

  Future<void> setFontDarkTheme(String font) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fontStyleDark', font);
    notifyListeners();
  }

  Future<void> loadInitialFont() async {
    SharedPreferences prefsDark = await SharedPreferences.getInstance();
    String fontDark = prefsDark.getString('fontStyleDark') ?? 'Roboto';
    _fontStyleDark = fontDark;

    SharedPreferences prefsLight = await SharedPreferences.getInstance();
    String fontLight = prefsLight.getString('fontStyleLight') ?? 'Roboto';
    _fontStyleLight = fontLight;
    notifyListeners();
  }

  //Light Theme Font
  int _selectedFontLightIndex = 0;

  int get selectedFontLightIndex => _selectedFontLightIndex;

  String _fontStyleLight = 'Roboto';
  String get fontStyleLight => _fontStyleLight;

  Future<void> loadInitialLightIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int index = prefs.getInt('fontStyleLightIndex') ?? 0;
    _selectedFontLightIndex = index;
    notifyListeners();
  }

  Future<void> setFontLightIndex(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('fontStyleLightIndex', index);
    _selectedFontLightIndex = index;
    notifyListeners();
  }

  Future<void> setFontLightTheme(String font) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('fontStyleLight', font);
    notifyListeners();
  }

  //ANA RENK DEĞİŞTİRME İŞLEMLERİ

  //Dark Main Color
  int _selectedDarkMainColorIndex = 0;

  int get selectedDarkMainColorIndex => _selectedDarkMainColorIndex;

  int defaultDarkMainColorValue = 0xFFBB86FC;

  int _darkMainColorValue = 0xFFBB86FC;

  int get darkMainColorValue => _darkMainColorValue;

  Future<void> loadInitialDarkMainColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkMainColor') ?? 0xFFBB86FC;
    _darkMainColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkMainColorIndex') ?? 0;
    _selectedDarkMainColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkMainColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkMainColor', value);
    _darkMainColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkMainColorIndex', index);
    _selectedDarkMainColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkMainColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkMainColor', defaultDarkMainColorValue);
    _darkMainColorValue = defaultDarkMainColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkMainColorIndex', 0);
    _selectedDarkMainColorIndex = 0;
    notifyListeners();
  }

  //Light Main Color
  int _selectedLightMainColorIndex = 0;

  int get selectedLightMainColorIndex => _selectedLightMainColorIndex;

  int defaultLightMainColorValue = 0xFF009688;

  int _lightMainColorValue = 0xFF009688;

  int get lightMainColorValue => _lightMainColorValue;

  Future<void> loadInitialLightMainColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightMainColor') ?? 0xFF009688;
    _lightMainColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightMainColorIndex') ?? 0;
    _selectedLightMainColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightMainColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightMainColor', value);
    _lightMainColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightMainColorIndex', index);
    _selectedLightMainColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightMainColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightMainColor', defaultLightMainColorValue);
    _lightMainColorValue = defaultLightMainColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightMainColorIndex', 0);
    _selectedLightMainColorIndex = 0;
    notifyListeners();
  }

  //ARKAPLAN RENKLERİ

  //Dark bacground color

  int _selectedDarkBackGColorIndex = 0;

  int get selectedDarkBackGColorIndex => _selectedDarkBackGColorIndex;

  int defaultDarkBackGColorValue = 0xFF121212;

  int _darkBackGColorValue = 0xFF121212;

  int get darkBackGColorValue => _darkBackGColorValue;

  Future<void> loadInitialDarkBackGColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkBackGColor') ?? 0xFF121212;
    _darkBackGColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkBackGColorIndex') ?? 0;
    _selectedDarkBackGColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkBackGColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkBackGColor', value);
    _darkBackGColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkBackGColorIndex', index);
    _selectedDarkBackGColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkBackGColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkBackGColor', defaultDarkBackGColorValue);
    _darkBackGColorValue = defaultDarkBackGColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkBackGColorIndex', 0);
    _selectedDarkBackGColorIndex = 0;
    notifyListeners();
  }

  //Light background color

  int _selectedLightBackGColorIndex = 0;

  int get selectedLightBackGColorIndex => _selectedLightBackGColorIndex;

  int defaultLightBackGColorValue = 0xFFFFFFFF;

  int _lightBackGColorValue = 0xFFFFFFFF;

  int get lightBackGColorValue => _lightBackGColorValue;

  Future<void> loadInitialLightBackGColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightBackGColor') ?? 0xFFFFFFFF;
    _lightBackGColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightBackGColorIndex') ?? 0;
    _selectedLightBackGColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightBackGColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightBackGColor', value);
    _lightBackGColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightBackGColorIndex', index);
    _selectedLightBackGColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightBackGColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightBackGColor', defaultLightBackGColorValue);
    _lightBackGColorValue = defaultLightBackGColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightBackGColorIndex', 0);
    _selectedLightBackGColorIndex = 0;
    notifyListeners();
  }

  //YAZI RENKLERİ

  //Dark text color

  int _selectedDarkTextColorIndex = 0;

  int get selectedDarkTextColorIndex => _selectedDarkTextColorIndex;

  int defaultDarkTextColorValue = 0xFFCFCFCF;

  int _darkTextColorValue = 0xFFCFCFCF;

  int get darkTextColorValue => _darkTextColorValue;

  Future<void> loadInitialDarkTextColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkTextColor') ?? 0xFFCFCFCF;
    _darkTextColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkTextColorIndex') ?? 0;
    _selectedDarkTextColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkTextColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkTextColor', value);
    _darkTextColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkTextColorIndex', index);
    _selectedDarkTextColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkTextColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkTextColor', defaultDarkTextColorValue);
    _darkTextColorValue = defaultDarkTextColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkTextColorIndex', 0);
    _selectedDarkTextColorIndex = 0;
    notifyListeners();
  }

  //Light text color

  int _selectedLightTextColorIndex = 0;

  int get selectedLightTextColorIndex => _selectedLightTextColorIndex;

  int defaultLightTextColorValue = 0xFF009688;

  int _lightTextColorValue = 0xFF009688;

  int get lightTextColorValue => _lightTextColorValue;

  Future<void> loadInitialLightTextColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightTextColor') ?? 0xFF009688;
    _lightTextColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightTextColorIndex') ?? 0;
    _selectedLightTextColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightTextColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightTextColor', value);
    _lightTextColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightTextColorIndex', index);
    _selectedLightTextColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightTextColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightTextColor', defaultLightTextColorValue);
    _lightTextColorValue = defaultLightTextColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightTextColorIndex', 0);
    _selectedLightTextColorIndex = 0;
    notifyListeners();
  }

  //İKON RENKLERİ

  //Dark Icon color

  int _selectedDarkIconColorIndex = 0;

  int get selectedDarkIconColorIndex => _selectedDarkIconColorIndex;

  int defaultDarkIconColorValue = 0xFF121212;

  int _darkIconColorValue = 0xFF121212;

  int get darkIconColorValue => _darkIconColorValue;

  Future<void> loadInitialDarkIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkIconColor') ?? 0xFF121212;
    _darkIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkIconColorIndex') ?? 0;
    _selectedDarkIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkIconColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkIconColor', value);
    _darkIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkIconColorIndex', index);
    _selectedDarkIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkIconColor', defaultDarkIconColorValue);
    _darkIconColorValue = defaultDarkIconColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkIconColorIndex', 0);
    _selectedDarkIconColorIndex = 0;
    notifyListeners();
  }

//Light Icon color

  int _selectedLightIconColorIndex = 0;

  int get selectedLightIconColorIndex => _selectedLightIconColorIndex;

  int defaultLightIconColorValue = 0xFFFFFFFF;

  int _lightIconColorValue = 0xFFFFFFFF;

  int get lightIconColorValue => _lightIconColorValue;

  Future<void> loadInitialLightIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightIconColor') ?? 0xFFFFFFFF;
    _lightIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightIconColorIndex') ?? 0;
    _selectedLightIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightIconColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightIconColor', value);
    _lightIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightIconColorIndex', index);
    _selectedLightIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightIconColor', defaultLightIconColorValue);
    _lightIconColorValue = defaultLightIconColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightIconColorIndex', 0);
    _selectedLightIconColorIndex = 0;
    notifyListeners();
  }

  //SOL KART RENKLERİ

  //Dark LeftCard color

  int _selectedDarkLeftCardColorIndex = 0;

  int get selectedDarkLeftCardColorIndex => _selectedDarkLeftCardColorIndex;

  int defaultDarkLeftCardColorValue = 0xFF1E1E1E;

  int _darkLeftCardColorValue = 0xFF1E1E1E;

  int get darkLeftCardColorValue => _darkLeftCardColorValue;

  Future<void> loadInitialDarkLeftCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkLeftCardColor') ?? 0xFF1E1E1E;
    _darkLeftCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkLeftCardColorIndex') ?? 0;
    _selectedDarkLeftCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkLeftCardColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkLeftCardColor', value);
    _darkLeftCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkLeftCardColorIndex', index);
    _selectedDarkLeftCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkLeftCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkLeftCardColor', defaultDarkLeftCardColorValue);
    _darkLeftCardColorValue = defaultDarkLeftCardColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkLeftCardColorIndex', 0);
    _selectedDarkLeftCardColorIndex = 0;
    notifyListeners();
  }

//Light LeftCard color

  int _selectedLightLeftCardColorIndex = 0;

  int get selectedLightLeftCardColorIndex => _selectedLightLeftCardColorIndex;

  int defaultLightLeftCardColorValue = 0xFFB2DFDB;

  int _lightLeftCardColorValue = 0xFFB2DFDB;

  int get lightLeftCardColorValue => _lightLeftCardColorValue;

  Future<void> loadInitialLightLeftCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightLeftCardColor') ?? 0xFFB2DFDB;
    _lightLeftCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightLeftCardColorIndex') ?? 0;
    _selectedLightLeftCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightLeftCardColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightLeftCardColor', value);
    _lightLeftCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightLeftCardColorIndex', index);
    _selectedLightLeftCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightLeftCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightLeftCardColor', defaultLightLeftCardColorValue);
    _lightLeftCardColorValue = defaultLightLeftCardColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightLeftCardColorIndex', 0);
    _selectedLightLeftCardColorIndex = 0;
    notifyListeners();
  }

  //SAĞ KART RENKLERİ

  //Dark RightCard color

  int _selectedDarkRightCardColorIndex = 0;

  int get selectedDarkRightCardColorIndex => _selectedDarkRightCardColorIndex;

  int defaultDarkRightCardColorValue = 0xFF2A2A2A;

  int _darkRightCardColorValue = 0xFF2A2A2A;

  int get darkRightCardColorValue => _darkRightCardColorValue;

  Future<void> loadInitialDarkRightCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkRightCardColor') ?? 0xFF2A2A2A;
    _darkRightCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkRightCardColorIndex') ?? 0;
    _selectedDarkRightCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkRightCardColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkRightCardColor', value);
    _darkRightCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkRightCardColorIndex', index);
    _selectedDarkRightCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkRightCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkRightCardColor', defaultDarkRightCardColorValue);
    _darkRightCardColorValue = defaultDarkRightCardColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkRightCardColorIndex', 0);
    _selectedDarkRightCardColorIndex = 0;
    notifyListeners();
  }

//Light RightCard color

  int _selectedLightRightCardColorIndex = 0;

  int get selectedLightRightCardColorIndex => _selectedLightRightCardColorIndex;

  int defaultLightRightCardColorValue = 0xFFFAFAFA;

  int _lightRightCardColorValue = 0xFFFAFAFA;

  int get lightRightCardColorValue => _lightRightCardColorValue;

  Future<void> loadInitialLightRightCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightRightCardColor') ?? 0xFFFAFAFA;
    _lightRightCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightRightCardColorIndex') ?? 0;
    _selectedLightRightCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightRightCardColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightRightCardColor', value);
    _lightRightCardColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightRightCardColorIndex', index);
    _selectedLightRightCardColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightRightCardColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightRightCardColor', defaultLightRightCardColorValue);
    _lightRightCardColorValue = defaultLightRightCardColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightRightCardColorIndex', 0);
    _selectedLightRightCardColorIndex = 0;
    notifyListeners();
  }

  //FAB RENKLERİ

  //Dark FAB color

  int _selectedDarkFABColorIndex = 0;

  int get selectedDarkFABColorIndex => _selectedDarkFABColorIndex;

  int defaultDarkFABColorValue = 0xFFBB86FC;

  int _darkFABColorValue = 0xFFBB86FC;

  int get darkFABColorValue => _darkFABColorValue;

  Future<void> loadInitialDarkFABColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkFABColor') ?? 0xFFBB86FC;
    _darkFABColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkFABColorIndex') ?? 0;
    _selectedDarkFABColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkFABColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkFABColor', value);
    _darkFABColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkFABColorIndex', index);
    _selectedDarkFABColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkFABColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkFABColor', defaultDarkFABColorValue);
    _darkFABColorValue = defaultDarkFABColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkFABColorIndex', 0);
    _selectedDarkFABColorIndex = 0;
    notifyListeners();
  }

//Light FAB color

  int _selectedLightFABColorIndex = 0;

  int get selectedLightFABColorIndex => _selectedLightFABColorIndex;

  int defaultLightFABColorValue = 0xFF009688;

  int _lightFABColorValue = 0xFF009688;

  int get lightFABColorValue => _lightFABColorValue;

  Future<void> loadInitialLightFABColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightFABColor') ?? 0xFF009688;
    _lightFABColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightFABColorIndex') ?? 0;
    _selectedLightFABColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightFABColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightFABColor', value);
    _lightFABColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightFABColorIndex', index);
    _selectedLightFABColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightFABColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightFABColor', defaultLightFABColorValue);
    _lightFABColorValue = defaultLightFABColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightFABColorIndex', 0);
    _selectedLightFABColorIndex = 0;
    notifyListeners();
  }

  //FAB İKON RENKLERİ

  //Dark FABIcon color

  int _selectedDarkFABIconColorIndex = 0;

  int get selectedDarkFABIconColorIndex => _selectedDarkFABIconColorIndex;

  int defaultDarkFABIconColorValue = 0xFF121212;

  int _darkFABIconColorValue = 0xFF121212;

  int get darkFABIconColorValue => _darkFABIconColorValue;

  Future<void> loadInitialDarkFABIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('darkFABIconColor') ?? 0xFF121212;
    _darkFABIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('darkFABIconColorIndex') ?? 0;
    _selectedDarkFABIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setDarkFABIconColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkFABIconColor', value);
    _darkFABIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkFABIconColorIndex', index);
    _selectedDarkFABIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultDarkFABIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('darkFABIconColor', defaultDarkFABIconColorValue);
    _darkFABIconColorValue = defaultDarkFABIconColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('darkFABIconColorIndex', 0);
    _selectedDarkFABIconColorIndex = 0;
    notifyListeners();
  }

//Light FABIcon color

  int _selectedLightFABIconColorIndex = 0;

  int get selectedLightFABIconColorIndex => _selectedLightFABIconColorIndex;

  int defaultLightFABIconColorValue = 0xFFFFFFFF;

  int _lightFABIconColorValue = 0xFFFFFFFF;

  int get lightFABIconColorValue => _lightFABIconColorValue;

  Future<void> loadInitialLightFABIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int value = prefs.getInt('lightFABIconColor') ?? 0xFFFFFFFF;
    _lightFABIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    int index = indexPrefs.getInt('lightFABIconColorIndex') ?? 0;
    _selectedLightFABIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setLightFABIconColor(int value, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightFABIconColor', value);
    _lightFABIconColorValue = value;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightFABIconColorIndex', index);
    _selectedLightFABIconColorIndex = index;
    notifyListeners();
  }

  Future<void> setDefaultLightFABIconColor() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('lightFABIconColor', defaultLightFABIconColorValue);
    _lightFABIconColorValue = defaultLightFABIconColorValue;

    SharedPreferences indexPrefs = await SharedPreferences.getInstance();
    indexPrefs.setInt('lightFABIconColorIndex', 0);
    _selectedLightFABIconColorIndex = 0;
    notifyListeners();
  }

  //ORTAK İŞLEMLER

  //Seçilen rengin uygulanma tuş kontrolü
  bool itemControl(int subcategoryId, int index, bool isDark) {
    List<int> listDark = [
      _selectedDarkMainColorIndex,
      _selectedDarkBackGColorIndex,
      _selectedDarkTextColorIndex,
      _selectedDarkIconColorIndex,
      _selectedDarkLeftCardColorIndex,
      _selectedDarkRightCardColorIndex,
      _selectedDarkFABColorIndex,
      _selectedDarkFABIconColorIndex
    ];
    List<int> listLight = [
      _selectedLightMainColorIndex,
      _selectedLightBackGColorIndex,
      _selectedLightTextColorIndex,
      _selectedLightIconColorIndex,
      _selectedLightLeftCardColorIndex,
      _selectedLightRightCardColorIndex,
      _selectedLightFABColorIndex,
      _selectedLightFABIconColorIndex
    ];
    if (isDark) {
      if (index == listDark[subcategoryId - 1]) {
        return false;
      } else {
        return true;
      }
    } else {
      if (index == listLight[subcategoryId - 1]) {
        return false;
      } else {
        return true;
      }
    }
  }

  //Uygulamanın değiştirilmek istenen yerini kontrol etme
  Future<void> setControl(
      int subcategoryId, int value, int index, bool isDark) async {
    List<Function> listDark = [
          () => setDarkMainColor(value, index),
          () => setDarkBackGColor(value, index),
          () => setDarkTextColor(value, index),
          () => setDarkIconColor(value, index),
          () => setDarkLeftCardColor(value, index),
          () => setDarkRightCardColor(value, index),
          () => setDarkFABColor(value, index),
          () => setDarkFABIconColor(value, index)
    ];
    List<Function> listLight = [
          () => setLightMainColor(value, index),
          () => setLightBackGColor(value, index),
          () => setLightTextColor(value, index),
          () => setLightIconColor(value, index),
          () => setLightLeftCardColor(value, index),
          () => setLightRightCardColor(value, index),
          () => setLightFABColor(value, index),
          () => setLightFABIconColor(value, index)
    ];
    debugPrint("$subcategoryId, $index, $isDark");
    if (isDark) {
      await listDark[subcategoryId-1]();
    } else {
      listLight[subcategoryId-1]();
    }
    debugPrint("${listLight[subcategoryId - 1]}");
  }

  Future<void> setDefault() async {
    setDefaultLightMainColor();
    setDefaultDarkMainColor();
    setDefaultLightBackGColor();
    setDefaultDarkBackGColor();
    setDefaultLightTextColor();
    setDefaultDarkTextColor();
    setDefaultLightIconColor();
    setDefaultDarkIconColor();
    setDefaultLightLeftCardColor();
    setDefaultDarkLeftCardColor();
    setDefaultLightRightCardColor();
    setDefaultDarkRightCardColor();
    setDefaultLightFABColor();
    setDefaultDarkFABColor();
    setDefaultLightFABIconColor();
    setDefaultDarkFABIconColor();
    notifyListeners();
  }

  Future<void> loadInitialAll() async {
    loadTitle();
    loadTotalMoney();
    loadInitialFont();
    loadInitialDarkIndex();
    loadInitialLightIndex();
    loadInitialDarkMainColor();
    loadInitialLightMainColor();
    loadInitialDarkBackGColor();
    loadInitialLightBackGColor();
    loadInitialDarkTextColor();
    loadInitialLightTextColor();
    loadInitialDarkIconColor();
    loadInitialLightIconColor();
    loadInitialDarkLeftCardColor();
    loadInitialLightLeftCardColor();
    loadInitialDarkRightCardColor();
    loadInitialLightRightCardColor();
    loadInitialDarkFABColor();
    loadInitialLightFABColor();
    loadInitialDarkFABIconColor();
    loadInitialLightFABIconColor();
  }
}
