import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:my_wordbook/utils/color_utils.dart';
import 'package:provider/provider.dart';
import '../models/dictionary.dart';
import '../models/language.dart';
import '../providers/dictionary_operations.dart';
import '../providers/language_operations.dart';
import '../providers/store_operations.dart';
import '../providers/theme_operations.dart';
import '../utils/fonts_utils.dart';

class AddDictionaryAlert extends StatefulWidget {
  const AddDictionaryAlert({super.key});

  @override
  State<AddDictionaryAlert> createState() => _AddDictionaryAlertState();
}

class _AddDictionaryAlertState extends State<AddDictionaryAlert> {
  TextEditingController wordbookTextEditingController = TextEditingController();

  int selectedButton = 0;
  late bool isDarkTheme;
  late final StoreOperations storeOperations;

  final List<String> allLanguages = [
    'Türkçe',
    'İngilizce',
    'Almanca',
    'Fransızca',
    'İspanyolca',
    'İtalyanca',
    'Rusça',
    'Arapça',
    'Çince',
    'Japonca',
    'Korece',
    'Hintçe',
    'Portekizce',
    'Fince',
    'İsveççe',
    'Lehçe',
    'Ukraynaca',
    'Çekçe',
    'Yunanca',
    'Hollandaca',
    'Danca',
    'Norveççe'
  ];

  String? selectedLanguage1;
  String? selectedLanguage2;

  @override
  void initState() {
    isDarkTheme = ThemeMode.dark ==
        Provider.of<ThemeOperations>(context, listen: false).themeMode;
    storeOperations = Provider.of<StoreOperations>(context, listen: false);
    super.initState();
  }

  Future<List<String>> getLanguages() async {
    return allLanguages;
  }

  Future<List<String>> getFilteredLanguages() async {
    return allLanguages.where((lang) => lang != selectedLanguage1).toList();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: alertDialog(),
    );
  }

  alertDialog() {
    return AlertDialog(
      title: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Yeni Sözlük Ekle',
          style: TextStyle(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            optionsTitleRow(),
            SizedBox(height: 8.h),
            if (selectedButton == 0) dictionaryArea() else wordbookArea()
          ],
        ),
      ),
      actions: <Widget>[cancelButton(), addButton()],
    );
  }

  optionsTitleRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        dictionaryOptionsButton(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
          child: Container(
            width: 2.w,
            height: 60.h,
            color: ColorUtils.getOptimalTextColor(
              context,
              Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
        wordbookOptionsButton()
      ],
    );
  }

  dictionaryOptionsButton() {
    return SizedBox(
      width: 120.w,
      height: 50.h,
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedButton = 0;
          });
        },
        style: TextButton.styleFrom(
            side: BorderSide(
              color: selectedButton == 0
                  ? ColorUtils.getOptimalTextColor(
                      context,
                      Theme.of(context).scaffoldBackgroundColor,
                    )
                  : Colors.transparent,
              width: selectedButton == 0 ? 2.0.r : 1.0.r,
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r))),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "SÖZLÜK",
            maxLines: 1,
            style: TextStyle(
                color: ColorUtils.getOptimalTextColor(
                  context,
                  Theme.of(context).scaffoldBackgroundColor,
                ),
                fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  wordbookOptionsButton() {
    return Padding(
      padding: EdgeInsets.all(4.0.r),
      child: SizedBox(
        width: 120.w,
        height: 50.h,
        child: TextButton(
            onPressed: () {
              setState(() {
                selectedButton = 1;
                selectedLanguage1 = null;
                selectedLanguage2 = null;
              });
            },
            style: TextButton.styleFrom(
                side: BorderSide(
                  color: selectedButton == 1
                      ? ColorUtils.getOptimalTextColor(
                          context,
                          Theme.of(context).scaffoldBackgroundColor,
                        )
                      : Colors.transparent,
                  width: selectedButton == 1 ? 2.0.r : 1.0.r,
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r))),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "KELİME DEFTERİ",
                style: TextStyle(
                    color: ColorUtils.getOptimalTextColor(
                      context,
                      Theme.of(context).scaffoldBackgroundColor,
                    ),
                    fontSize: 18.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
                    fontWeight: FontWeight.bold),
              ),
            )),
      ),
    );
  }

  dictionaryArea() {
    return Column(children: [
      SizedBox(height: 8.h),
      lang1List(),
      SizedBox(height: 24.h),
      lang2List()
    ]);
  }

  lang1List() {
    return DropdownSearch<String>(
      items: (filter, loadProps) => getLanguages(),
      selectedItem: selectedLanguage1,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16.sp *
                    Provider.of<ThemeOperations>(context)
                        .getTextScaleFactor(context),
              ),
            ),
          );
        },
        searchFieldProps: TextFieldProps(
          style: TextStyle(
              fontSize: 12.sp *
                  (FontsUtils.getFontScaleFactor(isDarkTheme
                      ? storeOperations.fontStyleDark
                      : storeOperations.fontStyleLight))),
          decoration: InputDecoration(
            labelText: "Ara...",
            border: OutlineInputBorder(),
          ),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyle(
            fontSize: 12.sp *
                (FontsUtils.getFontScaleFactor(isDarkTheme
                    ? storeOperations.fontStyleDark
                    : storeOperations.fontStyleLight))),
        decoration: InputDecoration(
          labelText: "Birinci Dili Seçin",
          labelStyle: TextStyle(
              fontSize: 12.sp *
                  (FontsUtils.getFontScaleFactor(isDarkTheme
                      ? storeOperations.fontStyleDark
                      : storeOperations.fontStyleLight))),
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.arrow_drop_down),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              borderRadius: BorderRadius.all(Radius.circular(10.r))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              borderRadius: BorderRadius.all(Radius.circular(10.r))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              borderRadius: BorderRadius.all(Radius.circular(10.r))),
        ),
      ),
      onChanged: (value) {
        setState(() {
          selectedLanguage1 = value;
          if (selectedLanguage1 == selectedLanguage2) {
            selectedLanguage2 = null;
          }
        });
      },
    );
  }

  lang2List() {
    return DropdownSearch<String>(
      items: (filter, loadProps) => getFilteredLanguages(),
      selectedItem: selectedLanguage2,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16.sp *
                    Provider.of<ThemeOperations>(context)
                        .getTextScaleFactor(context),
              ),
            ),
          );
        },
        searchFieldProps: TextFieldProps(
          style: TextStyle(
              fontSize: 12.sp *
                  (FontsUtils.getFontScaleFactor(isDarkTheme
                      ? storeOperations.fontStyleDark
                      : storeOperations.fontStyleLight))),
          decoration: InputDecoration(
            labelText: "Ara...",
            border: OutlineInputBorder(),
          ),
        ),
      ),
      decoratorProps: DropDownDecoratorProps(
        baseStyle: TextStyle(
            fontSize: 12.sp *
                (FontsUtils.getFontScaleFactor(isDarkTheme
                    ? storeOperations.fontStyleDark
                    : storeOperations.fontStyleLight))),
        decoration: InputDecoration(
          labelText: "İkinci Dili Seçin",
          labelStyle: TextStyle(
              fontSize: 12.sp *
                  (FontsUtils.getFontScaleFactor(isDarkTheme
                      ? storeOperations.fontStyleDark
                      : storeOperations.fontStyleLight))),
          border: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              borderRadius: BorderRadius.all(Radius.circular(10.r))),
          disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              borderRadius: BorderRadius.all(Radius.circular(10.r))),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              borderRadius: BorderRadius.all(Radius.circular(10.r))),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
              borderRadius: BorderRadius.all(Radius.circular(10.r))),
          suffixIcon: Icon(Icons.arrow_drop_down),
        ),
      ),
      onChanged: (value) {
        setState(() {
          selectedLanguage2 = value;
        });
      },
    );
  }

  wordbookArea() {
    return Column(children: [
      wordbookTextField(),
    ]);
  }

  wordbookTextField() {
    return Padding(
      padding: EdgeInsets.all(8.0.r),
      child: TextField(
        enableInteractiveSelection: true,
        selectionControls: null,
        controller: wordbookTextEditingController,
        autofocus: true,
        cursorColor: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).scaffoldBackgroundColor),
        decoration: InputDecoration(
            labelText: "Başlık",
            labelStyle: TextStyle(
              fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor))),
        style: TextStyle(
          fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor)),
      ),
    );
  }

  cancelButton() {
    return TextButton(
      child: Text(
        'İptal',
        style: TextStyle(
          fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor)),
      ),
      onPressed: () {
        AnalyticsService.logButtonClick('add_wordbook_cancel');
        Navigator.of(context).pop();
      },
    );
  }

  addButton() {
    return TextButton(
      child: Text('Ekle',
          style: TextStyle(
              fontSize: 14.sp *
                  Provider.of<ThemeOperations>(context)
                      .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor))),
      onPressed: () async {
        if (selectedButton == 0) {
          addDictionary();
        } else {
          addWordBook();
        }
      },
    );
  }

  addDictionary() async {
    if (selectedLanguage1 != null && selectedLanguage2 != null) {
      Language lang1 = Language(languageName: selectedLanguage1!);
      Language lang2 = Language(languageName: selectedLanguage2!);

      final id1 = await Provider.of<LanguageOperations>(context, listen: false)
          .addLanguage(lang1);

      if (mounted) {
        final id2 =
            await Provider.of<LanguageOperations>(context, listen: false)
                .addLanguage(lang2);

        Dictionary dict = Dictionary(
            language1Id: id1,
            language2Id: id2,
            language1Name: lang1.languageName,
            language2Name: lang2.languageName,
            totalNumber: 0,
            record: 0);
        int? addedID;
        if (mounted) {
          addedID =
              await Provider.of<DictionaryOperations>(context, listen: false)
                  .addDictionary(dict);
        }
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/dictionary', arguments: addedID);
          AnalyticsService.logButtonClick('add_wordbook');
        }
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Alanları doldurunuz!')));
    }
  }

  addWordBook() async {
    if (wordbookTextEditingController.text.isNotEmpty) {
      Language lang1 =
          Language(languageName: wordbookTextEditingController.text);
      Language lang2 = Language(languageName: '');

      final id1 = await Provider.of<LanguageOperations>(context, listen: false)
          .addLanguage(lang1);

      if (mounted) {
        final id2 =
            await Provider.of<LanguageOperations>(context, listen: false)
                .addLanguage(lang2);

        Dictionary dict = Dictionary(
            language1Id: id1,
            language2Id: id2,
            language1Name: lang1.languageName,
            language2Name: lang2.languageName,
            totalNumber: 0,
            record: 0);
        int? addedID;
        if (mounted) {
          addedID =
              await Provider.of<DictionaryOperations>(context, listen: false)
                  .addDictionary(dict);
        }
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(context, '/dictionary', arguments: addedID);
          AnalyticsService.logButtonClick('add_wordbook');
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başlık alanı boş bırakılamaz!')));
    }
  }
}
