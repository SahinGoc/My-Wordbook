import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:provider/provider.dart';
import '../models/dictionary.dart';
import '../providers/dictionary_operations.dart';
import '../providers/store_operations.dart';
import '../providers/theme_operations.dart';
import '../utils/color_utils.dart';
import '../utils/fonts_utils.dart';

class EditDictionaryAlert extends StatefulWidget {
  final Dictionary dict;
  const EditDictionaryAlert({super.key, required this.dict});

  @override
  State<EditDictionaryAlert> createState() => _EditDictionaryAlertState();
}

class _EditDictionaryAlertState extends State<EditDictionaryAlert> {
  late Dictionary _dict;
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

  Future<List<String>> getLanguages() async {
    return allLanguages;
  }

  Future<List<String>> getFilteredLanguages() async {
    return allLanguages.where((lang) => lang != selectedLanguage1).toList();
  }

  @override
  void initState() {
    super.initState();
    _dict = widget.dict;
    wordbookTextEditingController.text = _dict.language1Name;

    isDarkTheme = ThemeMode.dark ==
        Provider.of<ThemeOperations>(context, listen: false).themeMode;
    storeOperations = Provider.of<StoreOperations>(context, listen: false);
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
          'Sözlüğü düzenle',
          style: TextStyle(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            optionsTitleRow(),
            SizedBox(height: 16.h),
            if (selectedButton == 0) dictionaryArea() else wordbookArea()
          ],
        ),
      ),
      actions: <Widget>[
        cancelButton(),
        editButton(),
      ],
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
                fontSize: 18.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  wordbookOptionsButton() {
    return SizedBox(
      width: 120.w,
      height: 50.h,
      child: TextButton(
        onPressed: () {
          setState(() {
            selectedButton = 1;
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
                fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
                fontWeight: FontWeight.bold),
          ),
        ),
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
      selectedItem: _dict.language1Name,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16.sp *
                    Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
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
        baseStyle: TextStyle(fontSize: 9.sp),
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
      selectedItem: _dict.language2Name,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        itemBuilder: (context, item, isDisabled, isSelected) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 8.0.h),
            child: Text(
              item,
              style: TextStyle(
                fontSize: 16.sp *
                    Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'İptal',
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ),
      onPressed: () {
        AnalyticsService.logButtonClick('edit_dict_cancel');
        Navigator.of(context).pop();
      },
    );
  }

  editButton() {
    return TextButton(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Güncelle',
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ),
      onPressed: () async {
        if (selectedButton == 0) {
          editDictionary();
        } else {
          editWordBook();
        }
      },
    );
  }

  editDictionary() async {
    if (selectedLanguage1 != null && selectedLanguage2 != null) {
      _dict.language1Name = selectedLanguage1!;
      _dict.language2Name = selectedLanguage2!;

      if (context.mounted) {
        Provider.of<DictionaryOperations>(context, listen: false)
            .updateDictionary(_dict);
        AnalyticsService.logButtonClick('edit_dict_update');
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Alanları doldurunuz!')));
    }
  }

  editWordBook() async {
    if (wordbookTextEditingController.text.isNotEmpty) {
      _dict.language1Name = wordbookTextEditingController.text;
      _dict.language2Name = '';

      if (context.mounted) {
        Provider.of<DictionaryOperations>(context, listen: false)
            .updateDictionary(_dict);
        AnalyticsService.logButtonClick('edit_dict_update');
      }
      if (context.mounted) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Başlık alanı boş bırakılamaz!')));
    }
  }
}
