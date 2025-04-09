import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:translator/translator.dart';

import '../providers/theme_operations.dart';
import '../utils/color_utils.dart';
import '../utils/info_utils.dart';

class OnlineTranslatorWidgets extends StatefulWidget {
  const OnlineTranslatorWidgets({super.key});

  @override
  State<OnlineTranslatorWidgets> createState() =>
      _OnlineTranslatorWidgetsState();
}

class _OnlineTranslatorWidgetsState extends State<OnlineTranslatorWidgets>
    with SingleTickerProviderStateMixin {
  String sourceLanguage = 'English';
  String fromLang = 'en';
  String targetLanguage = 'Turkish';
  String toLang = 'tr';
  String translationResult = '';
  List<Map<String, dynamic>> langList = [];
  List<Map<String, dynamic>> filteredLangList = [];
  TextEditingController searchController = TextEditingController();
  bool isSearch = false;
  String searchWord = '';
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    fetchSupportedLanguages();
    filteredLangList = langList;

    Provider.of<ThemeOperations>(context, listen: false).attachTicker(this);
  }

  @override
  Widget build(BuildContext context) {
    return viewWidget();
  }

  // Çeviri fonksiyonu
  Future<void> translateText(String text, String from, String to) async {
    final translation = await translator.translate(text, from: from, to: to);
    setState(() {
      translationResult = translation.text;
    });
  }

  //Dil Listesi
  void fetchSupportedLanguages() async {
    final response =
        await http.get(Uri.parse('https://libretranslate.com/languages'));

    if (response.statusCode == 200) {
      List<dynamic> languages = json.decode(response.body);
      langList = languages
          .map((lang) => {"name": lang["name"], "code": lang["code"]})
          .toList();
      filteredLangList = langList;
    } else {
      debugPrint('Hata: ${response.statusCode}');
      throw Exception("Failed to load languages");
    }
  }

  // Arama işlevi
  void filterLanguages(String query) {
    final filtered = langList.where((lang) {
      final langName = lang["name"].toLowerCase();
      final searchQuery = query.toLowerCase();
      return langName.contains(searchQuery);
    }).toList();

    setState(() {
      filteredLangList = filtered;
    });
  }

  // Dilleri değiştirme fonksiyonu
  void swapLanguages() {
    setState(() {
      final temp = sourceLanguage;
      sourceLanguage = targetLanguage;
      targetLanguage = temp;
      translationResult = "";
      final temp2 = fromLang;
      fromLang = toLang;
      toLang = temp2;
    });
  }

  // Dil seçme işlemi için BottomSheet açan fonksiyon
  void selectLanguage(bool isSource) {
    if (filteredLangList.isEmpty) {
      debugPrint("Dil listesi boş.");
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(children: [
          searchBar(),
           SizedBox(
            height: 10.h,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredLangList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  textColor: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor),
                  title: Text(
                    filteredLangList[index]["name"],
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp * Provider.of<ThemeOperations>(context)
                        .getTextScaleFactor(context)),
                  ),
                  onTap: () {
                    setState(() {
                      isSource
                          ? sourceLanguage = filteredLangList[index]["name"]
                          : targetLanguage = filteredLangList[index]["name"];
                      isSource
                          ? fromLang = filteredLangList[index]["code"]
                          : toLang = filteredLangList[index]["code"];
                    });

                    Navigator.pop(context);
                    resetSearch();
                  },
                );
              },
            ),
          ),
        ]);
      },
    ).whenComplete(
      () {
        resetSearch();
      },
    );
  }

  //Dil arama
  searchBar() {
    return Padding(
      padding:  EdgeInsets.only(top: 20.0.h, left: 18.0.w, right: 18.0.w),
      child: TextField(
        maxLines: 1,
        autofocus: isSearch,
        controller: searchController,
        cursorColor: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).scaffoldBackgroundColor),
        decoration: InputDecoration(
          prefixIcon: PhosphorIcon(PhosphorIconsRegular.magnifyingGlass,
              size: 22.sp,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
          fillColor:
          ColorUtils.getOptimalTextColor(context, Theme.of(context).primaryColor),
          filled: true,
          hintText: 'Dil ara',
          hintStyle: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              fontWeight: FontWeight.bold,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
          //Arama kapatma butonu
          suffixIcon: Visibility(
              visible: isSearch,
              child: IconButton(
                  onPressed: resetSearch,
                  icon: PhosphorIcon(
                    PhosphorIconsRegular.x,
                    size: 22.sp,
                    color: ColorUtils.getOptimalTextColor(
                        context, Theme.of(context).scaffoldBackgroundColor),
                  ))),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              isSearch = false;
            });
          } else {
            setState(() {
              isSearch = true;
              filterLanguages(value);
            });
          }
        },
      ),
    );
  }

  // Arama durumunu sıfırlama
  void resetSearch() {
    setState(() {
      isSearch = false;
      searchController.clear();
      filteredLangList = langList;
      FocusScope.of(context).unfocus();
    });
  }

  viewWidget() {
    return Padding(
      padding:  EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 30.0.h),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buttonsRow(),
            headlinesColumn(),
             SizedBox(height: 40.h),
            // Dil seçme butonları ve dilleri değiştirme ikonu
            languagesRow(),
             SizedBox(height: 30.h),
            // Metin girişi
            translatorContainer(),
             SizedBox(height: 20.h),
            // Çeviri sonucu
            resultContainer()
          ],
        ),
      ),
    );
  }

  buttonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        backButton(),
        themeChangerButton(context),
      ],
    );
  }

  backButton() {
    return IconButton(
        onPressed: () {
          Navigator.pop(context);
          FocusScope.of(context).unfocus();
        },
        icon: PhosphorIcon(PhosphorIconsBold.arrowLeft,
            size: 28.sp,
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor)
        )
    );
  }

  themeChangerButton(BuildContext context) {
    return Consumer<ThemeOperations>(
      builder: (context, themeOps, child) {
        return GestureDetector(
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 300));

            await themeOps.toggleTheme(!(themeOps.themeMode == ThemeMode.dark));

            AnalyticsService.logThemeChange(themeOps.themeMode == ThemeMode.dark);
          },
          child: Lottie.asset(
            'assets/animations/day-night.json',
            width: 50.w,
            controller: themeOps.animationController,
            repeat: false,
          ),
        );
      },
    );
  }

  headlinesColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            PhosphorIcon(PhosphorIconsBold.translate,
                size: 40.sp, color: Theme.of(context).primaryColor),
            Text(
              " Translate",
              style: TextStyle(
                  fontSize: 28.sp * Provider.of<ThemeOperations>(context)
                      .getTextScaleFactor(context),
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
            ),
          ],
        ),
         SizedBox(height: 8.h),
        Text(
          "Metinleri diller arasında çevirin",
          style: TextStyle(
              fontSize: 16.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)
                  .withAlpha(180)),
        ),
      ],
    );
  }

  languagesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        sourceLanguageBox(),
        swapLanguagesButton(),
        targetLanguageBox()
      ],
    );
  }

  sourceLanguageBox() {
    return SizedBox(
      width: 150.w,
      height: 60.h,
      child: ElevatedButton(
        onPressed: () => selectLanguage(true),
        style: ElevatedButton.styleFrom(
            padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            elevation: 12.r),
        child: AutoSizeText(
          sourceLanguage,
          maxLines: 1,
          style: TextStyle(
              fontSize: 16.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ),
    );
  }

  swapLanguagesButton() {
    return IconButton(
      icon: PhosphorIcon(
        PhosphorIconsFill.swap,
        size: 40.sp,
        color: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).scaffoldBackgroundColor),
      ),
      onPressed: swapLanguages,
    );
  }

  targetLanguageBox() {
    return SizedBox(
      width: 150.w,
      height: 60.h,
      child: ElevatedButton(
        onPressed: () => selectLanguage(false),
        style: ElevatedButton.styleFrom(
            padding:  EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            elevation: 12.r),
        child: AutoSizeText(
          targetLanguage,
          maxLines: 1,
          style: TextStyle(
              fontSize: 16.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ),
    );
  }

  translatorContainer() {
    return TextField(
      minLines: 3,
      maxLines: 5,
      cursorColor: ColorUtils.getOptimalTextColor(
          context, Theme.of(context).scaffoldBackgroundColor),
      onChanged: (value) async {
        try {
          translateText(value.toLowerCase(), fromLang, toLang);
          if (value.isEmpty) {
            translationResult = '';
          }
        } catch (e) {
          debugPrint("kelime: $value, dil1: $fromLang, dil2: $toLang");
          debugPrint("Çeviri işlemi sırasında hata oluştu: $e");
        }
      },
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25.0.r),
              borderSide:  BorderSide(width: 2.0.r))),
      style: TextStyle(
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).scaffoldBackgroundColor)),
    );
  }

  resultContainer() {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0.r),
        borderSide: BorderSide(
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).scaffoldBackgroundColor),
          width: 2.0.r,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding:
                 EdgeInsets.symmetric(vertical: 10.0.h, horizontal: 15.0.w),
            child: Text(
              translationResult.isEmpty ? "Çeviri..." : translationResult,
              style: TextStyle(fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                  .getTextScaleFactor(context),
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor),
              ),
              textAlign: TextAlign.left,
            ),
          ),
          copyTextButton(),
        ],
      ),
    );
  }

  copyTextButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          icon: PhosphorIcon(PhosphorIconsRegular.copy,
              size: 28.sp,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
          onPressed: () {
            if (translationResult.isNotEmpty) {
              Clipboard.setData(ClipboardData(text: translationResult));
              AnalyticsService.logButtonClick('translator_result_copy');
              InfoUtils.showToast('Kopyalandı');
            }
          },
        ),
      ],
    );
  }
}
