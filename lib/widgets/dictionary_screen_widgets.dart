import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/providers/dictionary_operations.dart';
import 'package:my_wordbook/providers/theme_operations.dart';
import 'package:my_wordbook/providers/word_operations.dart';
import 'package:my_wordbook/models/word.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:my_wordbook/services/ad_service.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/store_operations.dart';
import '../utils/color_utils.dart';
import '../utils/fonts_utils.dart';
import '../utils/info_utils.dart';

class DictionaryScreenWidgets extends StatefulWidget {
  final int id;
  const DictionaryScreenWidgets({super.key, required this.id});

  @override
  State<DictionaryScreenWidgets> createState() =>
      _DictionaryScreenWidgetsState();
}

class _DictionaryScreenWidgetsState extends State<DictionaryScreenWidgets>
    with SingleTickerProviderStateMixin {
  List<String>? languageNameString;
  late int id;
  late ScrollController _controller;
  bool sliverCollapsed = false;
  bool isSearch = false;
  String searchWord = '';
  TextEditingController searchController = TextEditingController();
  TextEditingController word1Controller = TextEditingController();
  TextEditingController word2Controller = TextEditingController();
  bool isMenuOpened = false;
  bool isDelete = false;
  bool isDeleteReady = false;
  List<bool> isDeleteReadyList = [];
  bool isUpdate = false;
  int currentUpdatedWordId = 0;
  late bool isDarkTheme;
  late final StoreOperations storeOperations;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    _fetchLanguages();
    _controller = ScrollController();

    storeOperations = Provider.of<StoreOperations>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeOps = Provider.of<ThemeOperations>(context, listen: false);
      themeOps.loadInitialThemeMode(context).then((_) {
        setState(() {
          isDarkTheme = themeOps.themeMode == ThemeMode.dark;
        });
      });
    });

    _controller.addListener(() {
      if (_controller.offset > 70.h && !_controller.position.outOfRange) {
        if (!sliverCollapsed) {
          sliverCollapsed = true;
        }
      }

      if (_controller.offset <= 70.h && !_controller.position.outOfRange) {
        if (sliverCollapsed) {
          sliverCollapsed = false;
        }
      }
    });

    Provider.of<ThemeOperations>(context, listen: false).attachTicker(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    Provider.of<ThemeOperations>(context).loadViewMode();
  }

  @override
  void dispose() {
    searchController.dispose();
    word1Controller.dispose();
    word2Controller.dispose();
    super.dispose();
  }

  void _fetchLanguages() async {
    try {
      List<String> fetchedLanguages =
          await Provider.of<WordOperations>(context, listen: false)
              .getLanguagesNames(id);
      languageNameString = fetchedLanguages;
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            Future.microtask(() {
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                    context, '/', (route) => false);
              }
            });
          }
        },
        child: viewWidget(widget.id));
  }

  Widget viewWidget(int id) {
    return Consumer<WordOperations>(
      builder: (BuildContext context, value, Widget? child) {
        return FutureBuilder(
          future: isSearch == true
              ? value.getSearchWord(id, searchWord)
              : value.getWords(id),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError == true) {
              return const Center(
                child: Text("Hata ile karşılaşıldı."),
              );
            }
            if (snapshot.hasData) {
              List<Word> list1 = snapshot.data;
              List<Word> list = list1.reversed.toList();
              if (isDeleteReadyList.length != list.length) {
                isDeleteReadyList = List<bool>.filled(list.length, false);
              }
              return CustomScrollView(controller: _controller, slivers: [
                SliverAppBar(
                  pinned: true,
                  stretch: true,
                  expandedHeight: 280.0.h,
                  titleSpacing: 0.0,
                  title: languageNameString == null
                      ? Lottie.asset('assets/animations/circular.json')
                      : titleRow(),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(20.r),
                        bottomRight: Radius.circular(20.r)),
                  ),
                  flexibleSpace: spaceBar(),
                  actions: [
                    // Silme butonu
                    if (isMenuOpened) deleteButton(list),
                    //Online sözlük butonu
                    if (isMenuOpened) onlineDictionaryButton(),
                    //Layout butonu
                    layoutChangerButton(context),
                    //Menü açma butonu
                    openToMenu(),
                    //Tema butonu
                    themeChangerButton(context),
                  ],
                ),
                SliverPadding(padding: EdgeInsets.only(top: 8.0.h)),
                Provider.of<ThemeOperations>(context).isGridView == true
                    ? _sliverGrid(list, isDeleteReadyList)
                    : SliverPadding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                        sliver: _sliverList(list, isDeleteReadyList),
                      )
              ]);
            }
            return Center(
                child: Lottie.asset('assets/animations/circular.json'));
          },
        );
      },
    );
  }

  titleRow() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            languageNameString![0],
            maxLines: 2,
            style: TextStyle(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).primaryColor),
            ),
          ),
          if (languageNameString![1] != '')
            Text(
              ' - ${languageNameString![1]}',
              maxLines: 2,
              style: TextStyle(
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).primaryColor),
              ),
            ),
        ],
      ),
    );
  }

  deleteButton(List<Word> list) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDelete == true ? Colors.grey.shade400 : Colors.transparent),
      child: IconButton(
          onPressed: () {
            setState(() {
              isDelete = !isDelete;
              if (!isDelete) {
                isDeleteReadyList = List<bool>.filled(list.length, false);
              }
            });
          },
          icon: PhosphorIcon(
            PhosphorIconsRegular.eraser,
            size: 28.sp,
            color: Theme.of(context).iconTheme.color,
          )),
    );
  }

  onlineDictionaryButton() {
    return IconButton(
        onPressed: () {
          AnalyticsService.logButtonClick('online_translator');
          InfoUtils.checkConnection(context);
          Provider.of<AdService>(context, listen: false).showInterstitialAd();
        },
        icon: PhosphorIcon(PhosphorIconsRegular.translate,
            size: 28.sp, color: Theme.of(context).iconTheme.color));
  }

  openToMenu() {
    return IconButton(
        onPressed: () {
          setState(() {
            isMenuOpened = !isMenuOpened;
          });
        },
        icon: isMenuOpened == true
            ? PhosphorIcon(PhosphorIconsRegular.caretRight,
                size: 22.sp, color: Theme.of(context).iconTheme.color)
            : PhosphorIcon(PhosphorIconsRegular.dotsThreeOutlineVertical,
                size: 22.sp, color: Theme.of(context).iconTheme.color));
  }

  themeChangerButton(BuildContext context) {
    return Consumer<ThemeOperations>(
      builder: (context, themeOps, child) {
        return GestureDetector(
          onTap: () async {
            await Future.delayed(const Duration(milliseconds: 300));

            await themeOps.toggleTheme(!(themeOps.themeMode == ThemeMode.dark));

            setState(() {
              isDarkTheme = themeOps.themeMode == ThemeMode.dark;
            });

            AnalyticsService.logThemeChange(
                themeOps.themeMode == ThemeMode.dark);
          },
          child: Padding(
            padding: EdgeInsets.only(right: 8.0.w),
            child: Lottie.asset(
              'assets/animations/day-night.json',
              controller: themeOps.animationController,
              repeat: false,
              width: 50.w,
            ),
          ),
        );
      },
    );
  }

  layoutChangerButton(BuildContext context) {
    var themeProvider = Provider.of<ThemeOperations>(context);
    return IconButton(
        onPressed: () {
          themeProvider.toggleViewMode();
          AnalyticsService.logButtonClick('layout_change');
        },
        icon: PhosphorIcon(
            themeProvider.isGridView == true
                ? PhosphorIconsRegular.squaresFour
                : PhosphorIconsRegular.rows,
            color: Theme.of(context).iconTheme.color,
            size: 27.sp));
  }

  _sliverList(List<Word> list, List<bool> isDeleteReadyList) {
    if (list.isEmpty) {
      return listEmpty();
    }
    return SliverList(
      delegate:
          SliverChildBuilderDelegate(childCount: list.length, (context, index) {
        return GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(9.0.r),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [leftCard(list, index), rightCard(list, index)],
                ),
              ),
            ),
            onTap: () {
              if (isDelete) {
                if (isDeleteReadyList[index]) {
                  Provider.of<DictionaryOperations>(context, listen: false)
                      .decreaseTotalNumber(list[index].dictionaryId);
                  Provider.of<WordOperations>(context, listen: false)
                      .deleteWord(list[index].id!);
                  AnalyticsService.logButtonClick('delete_word');
                  setState(() {
                    isDeleteReadyList[index] = false;
                  });
                } else {
                  setState(() {
                    isDeleteReadyList[index] = true;
                  });
                }
              } else {
                setState(() {
                  isUpdate = true;
                  word1Controller.text = list[index].wordInLanguage1;
                  word2Controller.text = list[index].wordInLanguage2;
                  currentUpdatedWordId = list[index].id!;
                });
              }
            });
      }),
    );
  }

  listEmpty() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(10.0.r),
        child: Card(
          elevation: 10.h,
          child: Padding(
            padding: EdgeInsets.all(8.0.r),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Center(
                child: isSearch == true
                    ? const Text(
                        'Aradığınız kelime bulunamadı!',
                        textAlign: TextAlign.center,
                      )
                    : const Text(
                        'Lütfen kelime ekleyiniz!',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  leftCard(List<Word> list, int index) {
    return Expanded(
        flex: 4,
        child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0.r),
                    bottomLeft: Radius.circular(16.0.r))),
            margin: const EdgeInsets.all(0),
            color: isDeleteReadyList[index] == false
                ? Theme.of(context).cardTheme.surfaceTintColor
                : Colors.red[500],
            child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    list[index].wordInLanguage1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.sp *
                            Provider.of<ThemeOperations>(context)
                                .getTextScaleFactor(context)),
                  )),
            )));
  }

  rightCard(List<Word> list, int index) {
    return Expanded(
        flex: 4,
        child: Card(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16.0.r),
                    bottomRight: Radius.circular(16.0.r))),
            margin: const EdgeInsets.only(right: 0),
            color: isDeleteReadyList[index] == false
                ? Theme.of(context).cardTheme.color
                : Colors.red[400],
            child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Text(
                    list[index].wordInLanguage2,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.sp *
                            Provider.of<ThemeOperations>(context)
                                .getTextScaleFactor(context)),
                  )),
            )));
  }

  _sliverGrid(List<Word> list, List<bool> isDeleteReadyList) {
    if (list.isEmpty) {
      return gridEmpty();
    }
    return SliverMasonryGrid(
      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2),
      delegate:
          SliverChildBuilderDelegate(childCount: list.length, (context, index) {
        return GestureDetector(
            child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Column(
                children: [
                  upCard(list, index),
                  downCard(list, index),
                ],
              ),
            ),
            onTap: () {
              if (isDelete) {
                if (isDeleteReadyList[index]) {
                  Provider.of<DictionaryOperations>(context, listen: false)
                      .decreaseTotalNumber(list[index].dictionaryId);
                  Provider.of<WordOperations>(context, listen: false)
                      .deleteWord(list[index].id!);
                  AnalyticsService.logButtonClick('delete_word');
                  setState(() {
                    isDeleteReadyList[index] = false;
                  });
                } else {
                  setState(() {
                    isDeleteReadyList[index] = true;
                  });
                }
              } else {
                setState(() {
                  isUpdate = true;
                  word1Controller.text = list[index].wordInLanguage1;
                  word2Controller.text = list[index].wordInLanguage2;
                  currentUpdatedWordId = list[index].id!;
                });
              }
            });
      }),
    );
  }

  gridEmpty() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(10.0.r),
        child: Card(
          elevation: 4,
          child: Padding(
            padding: EdgeInsets.all(8.0.r),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Center(
                child: isSearch == true
                    ? const Text(
                        'Aradığınız kelime bulunamadı!',
                        textAlign: TextAlign.center,
                      )
                    : const Text(
                        'Lütfen kelime ekleyiniz!',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  upCard(List<Word> list, int index) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0.r),
              topRight: Radius.circular(15.0.r))),
      margin: const EdgeInsets.all(0),
      color: isDeleteReadyList[index] == false
          ? Theme.of(context).cardTheme.surfaceTintColor
          : Colors.red[500],
      child: Padding(
        padding: EdgeInsets.all(12.0.r),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            list[index].wordInLanguage1,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.sp *
                    Provider.of<ThemeOperations>(context)
                        .getTextScaleFactor(context)),
          ),
        ),
      ),
    );
  }

  downCard(List<Word> list, int index) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(15.0.r),
              bottomRight: Radius.circular(15.0.r))),
      margin: const EdgeInsets.only(right: 0),
      color: isDeleteReadyList[index] == false
          ? Theme.of(context).cardTheme.color
          : Colors.red[400],
      child: Padding(
        padding: EdgeInsets.all(12.0.r),
        child: Align(
          alignment: Alignment.topCenter,
          child: Text(
            list[index].wordInLanguage2,
            overflow: TextOverflow.visible,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 14.sp *
                    Provider.of<ThemeOperations>(context)
                        .getTextScaleFactor(context)),
          ),
        ),
      ),
    );
  }

  //App bar
  spaceBar() {
    return Visibility(
      visible: !sliverCollapsed,
      child: Padding(
        padding: EdgeInsets.only(
            bottom: 5.0.r, right: 5.0.r, left: 5.0.r, top: 24.0.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              flex: 8,
              child: searchBar(),
            ),
            Flexible(flex: 9, child: addNewWordArea()),
          ],
        ),
      ),
    );
  }

  //Arama barı
  searchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0.h, horizontal: 8.0.w),
      child: TextField(
        maxLines: 1,
        autofocus: isSearch,
        controller: searchController,
        cursorColor: Theme.of(context).primaryColor,
        style: TextStyle(
            fontSize: 14.sp *
                (FontsUtils.getFontScaleFactor(isDarkTheme
                    ? storeOperations.fontStyleDark
                    : storeOperations.fontStyleLight)),
            color: ColorUtils.getContrastingTextColor(
                    Theme.of(context).scaffoldBackgroundColor)
                .withAlpha(220)),
        decoration: InputDecoration(
          prefixIcon: PhosphorIcon(
            PhosphorIconsRegular.magnifyingGlass,
            size: 24.sp,
            color: ColorUtils.getContrastingTextColor(
                    Theme.of(context).scaffoldBackgroundColor)
                .withAlpha(180),
          ),
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          filled: true,
          hintText: 'Kelime ara',
          hintStyle: TextStyle(
              fontSize: 12.sp *
                  (FontsUtils.getFontScaleFactor(isDarkTheme
                      ? storeOperations.fontStyleDark
                      : storeOperations.fontStyleLight)),
              fontWeight: FontWeight.bold,
              color: ColorUtils.getContrastingTextColor(
                      Theme.of(context).scaffoldBackgroundColor)
                  .withAlpha(180)),
          //Arama kapatma butonu
          suffixIcon: Visibility(
              visible: isSearch,
              child: IconButton(
                  onPressed: resetSearch,
                  icon: PhosphorIcon(PhosphorIconsRegular.x,
                      size: 24.sp,
                      color: ColorUtils.getOptimalTextColor(context,
                          Theme.of(context).scaffoldBackgroundColor)))),
        ),
        onChanged: (value) {
          if (value.isEmpty) {
            setState(() {
              isSearch = false;
            });
          } else {
            setState(() {
              isSearch = true;
              searchWord = value.toLowerCase();
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
      FocusScope.of(context).unfocus();
    });
  }

  addNewWordArea() {
    return Padding(
      padding: EdgeInsets.all(8.0.r),
      child: Card(
        shape: OutlineInputBorder(
            borderSide: BorderSide(
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).primaryColor),
                width: 1.0.r),
            borderRadius: BorderRadius.circular(20.0.r)),
        elevation: 2.r,
        color: Theme.of(context).primaryColor,
        surfaceTintColor: Theme.of(context).primaryColor,
        child: Padding(
          padding: EdgeInsets.all(8.0.r),
          child: Row(
            children: [
              Flexible(
                flex: 7,
                child: textFieldColumn(word1Controller, word2Controller),
              ),
              Flexible(
                flex: 1,
                child: addIconButton(word1Controller, word2Controller),
              )
            ],
          ),
        ),
      ),
    );
  }

  textFieldColumn(
      TextEditingController w1Controller, TextEditingController w2Controller) {
    return Padding(
      padding: EdgeInsets.only(left: 6.0.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textField1(w1Controller),
          Container(
            height: 1,
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).primaryColor),
          ),
          textField2(w2Controller),
        ],
      ),
    );
  }

  textField1(TextEditingController w1Controller) {
    return Flexible(
      flex: 1,
      child: TextField(
        maxLines: 1,
        controller: w1Controller,
        cursorColor: Theme.of(context).scaffoldBackgroundColor,
        decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintText: 'Kelime',
            hintStyle: TextStyle(
                fontSize: 14.sp *
                    (FontsUtils.getFontScaleFactor(isDarkTheme
                        ? storeOperations.fontStyleDark
                        : storeOperations.fontStyleLight)),
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).primaryColor)),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0.h)),
        style: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 14.sp *
                (FontsUtils.getFontScaleFactor(isDarkTheme
                    ? storeOperations.fontStyleDark
                    : storeOperations.fontStyleLight))),
      ),
    );
  }

  textField2(TextEditingController w2Controller) {
    return Flexible(
      flex: 1,
      child: TextField(
        maxLines: 1,
        controller: w2Controller,
        autofocus: false,
        cursorColor: Theme.of(context).scaffoldBackgroundColor,
        decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            hintText: 'Anlam',
            hintStyle: TextStyle(
                fontSize: 14.sp *
                    (FontsUtils.getFontScaleFactor(isDarkTheme
                        ? storeOperations.fontStyleDark
                        : storeOperations.fontStyleLight)),
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).primaryColor)),
            isCollapsed: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8.0.h)),
        style: TextStyle(
            color: Theme.of(context).scaffoldBackgroundColor,
            fontSize: 14.sp *
                (FontsUtils.getFontScaleFactor(isDarkTheme
                    ? storeOperations.fontStyleDark
                    : storeOperations.fontStyleLight))),
      ),
    );
  }

  addIconButton(
      TextEditingController w1Controller, TextEditingController w2Controller) {
    return IconButton(
        onPressed: () => isUpdate == true
            ? updateWord(w1Controller, w2Controller)
            : addWord(w1Controller, w2Controller),
        icon: PhosphorIcon(
          PhosphorIconsLight.checkFat,
          size: 26.sp,
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).primaryColor),
        ));
  }

  addWord(
      TextEditingController w1Controller, TextEditingController w2Controller) {
    {
      if (w1Controller.text.isNotEmpty && w2Controller.text.isNotEmpty) {
        Provider.of<WordOperations>(context, listen: false)
            .addWord(id, w1Controller.text, w2Controller.text);
        Provider.of<DictionaryOperations>(context, listen: false)
            .incrementTotalNumber(id);
        FocusScope.of(context).unfocus();
        w1Controller.clear();
        w2Controller.clear();
        AnalyticsService.logButtonClick('add_new_word');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Kelime ve anlamını eksiksiz doldurunuz!')));
      }
    }
  }

  updateWord(
      TextEditingController w1Controller, TextEditingController w2Controller) {
    {
      if (w1Controller.text.isNotEmpty && w2Controller.text.isNotEmpty) {
        Provider.of<WordOperations>(context, listen: false).updateWord(
            currentUpdatedWordId, w1Controller.text, w2Controller.text);
        FocusScope.of(context).unfocus();
        w1Controller.clear();
        w2Controller.clear();
        isUpdate = false;
        AnalyticsService.logButtonClick('update_word');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Kelime ve anlamını eksiksiz doldurunuz!')));
      }
    }
  }
}
