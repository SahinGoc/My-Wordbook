import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:my_wordbook/models/store.dart';
import 'package:my_wordbook/providers/theme_operations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:my_wordbook/widgets/cheat_alert.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/store_operations.dart';
import '../utils/color_utils.dart';
import '../utils/info_utils.dart';
import 'colors_picker_alert.dart';

class StoreScreenWidgets extends StatefulWidget {
  const StoreScreenWidgets({super.key});

  @override
  State<StoreScreenWidgets> createState() => _StoreScreenWidgetsState();
}

class _StoreScreenWidgetsState extends State<StoreScreenWidgets>
    with SingleTickerProviderStateMixin {
  late final StoreOperations storeOperations;
  int selectedCategoryIndex = 0;
  bool isShowDescriptions = true;
  final ScrollController _scrollController = ScrollController();
  int selectedSubCategoryId = -1;
  late Future<List<Subcategory>> _subcategoriesFuture;
  late Future<bool> _fontsFuture;
  late Future<bool> _colorsFuture;
  late bool isDarkTheme;
  bool isPhone = true;

  @override
  void initState() {
    super.initState();
    Provider.of<ThemeOperations>(context, listen: false).attachTicker(this);
    storeOperations = Provider.of<StoreOperations>(context, listen: false);
    storeOperations.insertMainCategories();
    storeOperations.insertColors();
    storeOperations.loadSubcategories(1);
    storeOperations.updateSubcategories(1);
    _subcategoriesFuture = storeOperations.loadSubcategories(1);
    _fontsFuture = storeOperations.loadFontsItems();
    storeOperations.loadInitialDarkIndex();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeOps = Provider.of<ThemeOperations>(context, listen: false);
      themeOps.loadInitialThemeMode(context).then((_) {
        setState(() {
          isDarkTheme = themeOps.themeMode == ThemeMode.dark;
        });
      });
      isPhone = MediaQuery.of(context).size.width < 600;
    });
  }

  void onCardTap(int categoryIndex) async {
    // Açıklamayı gizle
    setState(() {
      isShowDescriptions = false;
    });

    await storeOperations.insertFonts();
    await storeOperations.loadFontsItems();
    await storeOperations.loadSubcategories(1);
    storeOperations.updateSubcategories(1);

    // Kartı seç
    setState(() {
      selectedCategoryIndex = categoryIndex;
      if (selectedCategoryIndex == 1) {
        selectedSubCategoryId = -1;
      }
    });

    double screenWidth = 0;
    // Kartın animasyonlu olarak merkeze gelmesi
    if (mounted) {
      screenWidth = MediaQuery.of(context).size.width;
    }
    double cardWidth = screenWidth * 0.7; // Seçili kart genişliği
    double spacing = 16; // Kartlar arasındaki boşluk

    // Hedef kaydırma pozisyonunu hesapla
    double offset = (categoryIndex * (screenWidth * 0.5 + spacing)) -
        (screenWidth / 2 - cardWidth / 2);

    // Pozisyon sıfırın altına düşmemeli veya maksimum kaydırma değerini aşmamalı
    offset = offset.clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );

    // Kaydırma işlemini gerçekleştir
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    // Animasyon tamamlandıktan sonra açıklamayı göster
    await Future.delayed(const Duration(milliseconds: 450));
    setState(() {
      isShowDescriptions = true;
    });
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
        child: viewStore());
  }

  viewStore() {
    return Consumer<StoreOperations>(
      builder: (context, storeOperations, child) {
        return Padding(
          padding: EdgeInsets.only(
              top: 20.0.h, left: 16.0.w, right: 16.0.w, bottom: 1.0.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bakiye
              amountOfMoneyWidgets(),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: headLineStoreWidgets(),
                    ),
                    // Kategoriler
                    Expanded(
                      flex: 4,
                      child: categoriesWidgets(),
                    ),
                    // Alt Kategoriler veya Fontlar
                    Expanded(
                      flex: 14,
                      child: selectedCategoryIndex == 0
                          ? subcategoriesWidgets(selectedSubCategoryId)
                          : fontsWidgets(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  //Bakiye
  amountOfMoneyWidgets() {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h, top: 12.0.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          backScreenButton(),
          Row(
            children: [
              coins(),
              resetColorsButton(context),
              themeChangerButton(context)
            ],
          )
        ],
      ),
    );
  }

  backScreenButton() {
    return IconButton(
        onPressed: () {
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        icon: PhosphorIcon(
          PhosphorIconsBold.caretLeft,
          size: 28.sp,
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).scaffoldBackgroundColor),
        ));
  }

  coins() {
    return GestureDetector(
      onDoubleTap: () {
        showDialog(context: context, builder: (context) => CheatAlert());
      },
      child: Row(
        children: [
          PhosphorIcon(
            PhosphorIconsRegular.coins,
            size: 24.sp,
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor),
          ),
          SizedBox(
            width: 8.0.w,
          ),
          Text(
            storeOperations.totalMoney.toString(),
            style: TextStyle(
                fontSize: 16.sp,
                color: ColorUtils.getOptimalTextColor(
                    context, Theme.of(context).scaffoldBackgroundColor)),
          ),
        ],
      ),
    );
  }

  resetColorsButton(BuildContext context) {
    return IconButton(
        onPressed: () {
          AnalyticsService.logButtonClick('store_reset');
          _showSnackBar();
        },
        icon: PhosphorIcon(PhosphorIconsBold.arrowCounterClockwise,
            size: 22.sp,
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor)));
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
            AnalyticsService.logThemeChange(isDarkTheme);
          },
          child: Padding(
            padding: EdgeInsets.only(right: 4.0.w),
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

  headLineStoreWidgets() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.all(8.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AutoSizeText(
              'TASARIM',
              style: TextStyle(
                  fontSize: 24.0.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
            ),
            AutoSizeText(
              'ATÖLYESİ',
              style: TextStyle(
                  fontSize: 34.0.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorUtils.getOptimalTextColor(
                      context, Theme.of(context).scaffoldBackgroundColor)),
            ),
          ],
        ),
      ),
    );
  }

  //Kategoriler
  categoriesWidgets() {
    return SizedBox(
      height: 150.h,
      child: ListView.builder(
        controller: _scrollController,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: storeOperations.categories.length,
        itemBuilder: (context, categoryIndex) {
          final isSelected = selectedCategoryIndex == categoryIndex;
          final category = storeOperations.categories[categoryIndex];
          return GestureDetector(
            onTap: () => onCardTap(categoryIndex),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              margin: EdgeInsets.symmetric(
                horizontal: isSelected ? 16.w : 8.w,
                vertical: isSelected ? 8.h : 32.h,
              ),
              width: isSelected
                  ? MediaQuery.of(context).size.width * 0.7
                  : MediaQuery.of(context).size.width * 0.5,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).scaffoldBackgroundColor,
                border: isSelected
                    ? null
                    : Border.all(color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  if (isSelected)
                    const BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                ],
              ),
              child: categoryCards(category, categoryIndex, isSelected),
            ),
          );
        },
      ),
    );
  }

  categoryCards(Category category, int categoryIndex, bool isSelected) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.0.h, horizontal: 16.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          categoryTitles(category, categoryIndex),
          if (isSelected && isShowDescriptions)
            categoryDescriptions(categoryIndex, isSelected)
        ],
      ),
    );
  }

  categoryTitles(Category category, int categoryIndex) {
    return Text(
      category.name,
      style: TextStyle(
          fontSize: isPhone ? 18.sp : 32.sp,
          fontWeight: FontWeight.bold,
          color: ColorUtils.getOptimalTextColor(
              context,
              selectedCategoryIndex == categoryIndex
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).scaffoldBackgroundColor)),
      textAlign: TextAlign.start,
    );
  }

  categoryDescriptions(int categoryIndex, bool isSelected) {
    List<String> list = [
      'Farklı renkler kullanarak uygulamanızı '
          'özelleştirmek mi? HEMEN DENE!',
      'Yazı fontlarından sıkıldın mı? '
          'Hemen yeni bir tane SATIN AL!'
    ];
    return AutoSizeText(
      list[categoryIndex],
      maxLines: 4,
      minFontSize: isPhone ? 8 : 13,
      maxFontSize: isPhone ? 13 : 18,
      style: TextStyle(
        color: ColorUtils.getOptimalTextColor(
            context,
            selectedCategoryIndex == categoryIndex
                ? Theme.of(context).primaryColor
                : Theme.of(context).scaffoldBackgroundColor),
      ),
    );
  }

  //Alt Kategoriler
  subcategoriesWidgets(int subcategoryId) {
    return FutureBuilder(
      future: _subcategoriesFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError == true) {
          return const Center(
            child: Text("Hata ile karşılaşıldı."),
          );
        }
        if (snapshot.hasData) {
          if (subcategoryId == -1) {
            return SizedBox(
                height: MediaQuery.of(context).size.height * 0.575,
                child: GridView.custom(
                  physics: BouncingScrollPhysics(),
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      QuiltedGridTile(3, 2),
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(1, 1),
                      QuiltedGridTile(2, 2),
                    ],
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    childCount: storeOperations.subcategories.length,
                    (context, index) {
                      final subCategories =
                          storeOperations.subcategories[index];
                      return GestureDetector(
                          onTap: () {
                            selectedSubCategoryId = index + 1;
                            _colorsFuture = storeOperations
                                .loadColorsItems(selectedSubCategoryId);
                          },
                          child: subcategoryContainers(subCategories, index));
                    },
                  ),
                ));
          } else {
            return colorsWidgets(subcategoryId);
          }
        }
        return Center(child: Lottie.asset('assets/animations/circular.json'));
      },
    );
  }

  subcategoryContainers(Subcategory subCategories, int index) {
    return Container(
        decoration: BoxDecoration(
          border:
              Border.all(color: Theme.of(context).primaryColor, width: 2.0.r),
          borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
          gradient: SweepGradient(colors: [
            ColorUtils.generateColorFromIndex(
                Theme.of(context).primaryColor, index.toDouble()),
            ColorUtils.generateColorFromIndex(
                Theme.of(context).primaryColor, index + 2.0),
          ], stops: const [
            0.20,
            0.99
          ]),
          boxShadow: const [
            BoxShadow(
              color: Colors.white10,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: subCategoryName(subCategories, index));
  }

  subCategoryName(Subcategory subCategories, int index) {
    return Padding(
      padding: EdgeInsets.all(12.0.r),
      child: Center(
          child: AutoSizeText(
        subCategories.name.toString().toUpperCase(),
        maxLines: 2,
        minFontSize: 8,
        maxFontSize: 30,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            color: ColorUtils.getContrastingTextColor(
                ColorUtils.generateColorFromIndex(
                    Theme.of(context).primaryColor, index.toDouble()))),
      )),
    );
  }

  //Renkler
  colorsWidgets(int subcategoryId) {
    return FutureBuilder(
      future: _colorsFuture,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.hasError == true) {
          return const Center(
            child: Text("Hata ile karşılaşıldı."),
          );
        }
        if (snapshot.hasData) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.575,
            child: GridView.builder(
              itemCount: storeOperations.itemsColors.length + 2,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14.h,
                mainAxisSpacing: 14.w,
              ),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return backButtonColors();
                }
                if (index == 1) {
                  return colorsPicker(subcategoryId, index - 1);
                }
                final items = storeOperations.itemsColors[index - 2];
                return colorsContainer(index - 1, subcategoryId, items);
              },
            ),
          );
        }
        return Center(
            child: Lottie.asset('assets/animations/circular.json',
                width: 50.w, height: 50.h));
      },
    );
  }

  backButtonColors() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedSubCategoryId = -1;
        });
      },
      child: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
          border: Border.all(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
              width: 2.0.r),
          borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: PhosphorIcon(
          PhosphorIconsBold.arrowFatLineLeft,
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).scaffoldBackgroundColor),
          size: 40.0.sp,
        ),
      ),
    );
  }

  colorsPicker(int subCategoryId, int index) {
    return GestureDetector(
      onTap: () async {
        showDialog<Color>(
          context: context,
          builder: (context) =>
              ColorsPickerAlert(subCategoryId: subCategoryId, index: index),
        );
      },
      child: Container(
        width: 100.w,
        height: 100.h,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(150),
          border: Border.all(
              color: (storeOperations.itemControl(
                      subCategoryId, index, isDarkTheme))
                  ? Theme.of(context).primaryColor
                  : ColorUtils.adjustColor(
                      Theme.of(context).primaryColor, 0.5, false),
              width: (storeOperations.itemControl(
                      subCategoryId, index, isDarkTheme))
                  ? 2.0.r
                  : 4.0.r),
          borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: PhosphorIcon(
          PhosphorIconsRegular.palette,
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).scaffoldBackgroundColor),
          size: 65.0.sp,
        ),
      ),
    );
  }

  colorsContainer(int index, int subCategoryId, Item items) {
    return Container(
        decoration: BoxDecoration(
          color: Color(items.code!),
          border: Border.all(
              color: (storeOperations.itemControl(
                      items.subcategoryId, index, isDarkTheme))
                  ? Theme.of(context).primaryColor
                  : ColorUtils.adjustColor(
                      Theme.of(context).primaryColor, 0.5, false),
              width: (storeOperations.itemControl(
                      items.subcategoryId, index, isDarkTheme))
                  ? 2.5.r
                  : 4.0.r),
          borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: colorsColumn(index, subCategoryId, items));
  }

  colorsColumn(int index, int subCategoryId, Item items) {
    return Stack(
      children: [
        colorsName(items, index),
        if (!items.isPurchased) colorsPrice(index, subCategoryId, items),
        if (items.isPurchased &&
            (storeOperations.itemControl(
                items.subcategoryId, index, isDarkTheme)))
          colorsSelectButton(index, items)
      ],
    );
  }

  colorsName(Item items, int index) {
    return Align(
        alignment: Alignment.topLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.0.w),
          constraints: BoxConstraints(minWidth: 60.w, maxWidth: 100.w),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withAlpha(155),
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20.0.r),
                topLeft: Radius.circular(16.0.r)),
            border: Border(
              right: BorderSide(
                  color: (storeOperations.itemControl(
                          items.subcategoryId, index, isDarkTheme))
                      ? Theme.of(context).primaryColor
                      : ColorUtils.adjustColor(
                          Theme.of(context).primaryColor, 0.5, false),
                  width: 1.5.r),
              bottom: BorderSide(
                  color: (storeOperations.itemControl(
                          items.subcategoryId, index, isDarkTheme))
                      ? Theme.of(context).primaryColor
                      : ColorUtils.adjustColor(
                          Theme.of(context).primaryColor, 0.5, false),
                  width: 1.5.r),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(2.r),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                items.name,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorUtils.getContrastingTextColor(Theme.of(context)
                        .scaffoldBackgroundColor
                        .withAlpha(155)),
                    fontSize: 12.sp *
                        Provider.of<ThemeOperations>(context)
                            .getTextScaleFactor(context)),
              ),
            ),
          ),
        ));
  }

  colorsPrice(int index, int subCategoryId, Item items) {
    return GestureDetector(
        onTap: () async {
          final control = await storeOperations.purchaseItem(
              items.id!, subCategoryId, index);
          if (!control) {
            InfoUtils.showToast("Puanınız Yetersiz!");
          } else {
            AnalyticsService.logItemPurchase(items.subcategoryId, items.name);
          }
        },
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: EdgeInsets.all(2.0.r),
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor.withAlpha(180),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0.r),
                    bottomRight: Radius.circular(17.0.r)),
                border: Border(
                    left: BorderSide(
                        color: Theme.of(context).primaryColor, width: 3.0.r),
                    top: BorderSide(
                        color: Theme.of(context).primaryColor, width: 3.0.r))),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  items.price.toString().toUpperCase(),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17.sp,
                      color: ColorUtils.getContrastingTextColor(
                          Theme.of(context).scaffoldBackgroundColor)),
                ),
              ),
            ),
          ),
        ));
  }

  colorsSelectButton(int index, Item items) {
    return GestureDetector(
        onTap: () {
          storeOperations.setControl(
              items.subcategoryId, items.code!, index, isDarkTheme);
          AnalyticsService.logItemChange(items.subcategoryId, items.name);
        },
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
                color: ColorUtils.getContainerColor(
                    Theme.of(context).scaffoldBackgroundColor, context),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0.r),
                    bottomRight: Radius.circular(17.0.r)),
                border: Border(
                    left: BorderSide(
                        color: Theme.of(context).primaryColor, width: 3.0.r),
                    top: BorderSide(
                        color: Theme.of(context).primaryColor, width: 3.0.r))),
            child: Center(
              child: PhosphorIcon(PhosphorIconsBold.check,
                  color: ColorUtils.getContrastingTextColor(
                      Theme.of(context).scaffoldBackgroundColor)),
            ),
          ),
        ));
  }

  //Fontlsr
  fontsWidgets() {
    return FutureBuilder(
      future: _fontsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError == true) {
          return const Center(
            child: Text("Hata ile karşılaşıldı."),
          );
        }
        if (snapshot.hasData) {
          return Padding(
              padding: EdgeInsets.only(top: 8.0.h),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.565,
                child: GridView.custom(
                  gridDelegate: SliverQuiltedGridDelegate(
                    crossAxisCount: 4,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    repeatPattern: QuiltedGridRepeatPattern.inverted,
                    pattern: [
                      QuiltedGridTile(2, 2),
                      QuiltedGridTile(1, 2),
                      QuiltedGridTile(1, 2),
                    ],
                  ),
                  childrenDelegate: SliverChildBuilderDelegate(
                    childCount: storeOperations.itemsFonts.length,
                    (context, index) {
                      final items = storeOperations.itemsFonts[index];
                      return fontsContainer(index, items);
                    },
                  ),
                ),
              ));
        }
        return Center(child: Lottie.asset('assets/animations/circular.json'));
      },
    );
  }

  fontsContainer(int index, Item items) {
    return Container(
        decoration: BoxDecoration(
          color: isDarkTheme
              ? Theme.of(context).scaffoldBackgroundColor.withAlpha(100)
              : Theme.of(context).primaryColor.withAlpha(90),
          border: Border.all(
              color: isDarkTheme
                  ? storeOperations.selectedFontDarkIndex == index
                      ? Theme.of(context).primaryColor
                      : ColorUtils.adjustColor(
                          Theme.of(context).primaryColor, 0.5, false)
                  : storeOperations.selectedFontLightIndex == index
                      ? Theme.of(context).primaryColor
                      : ColorUtils.adjustColor(
                          Theme.of(context).primaryColor, 0.5, false),
              width: isDarkTheme
                  ? storeOperations.selectedFontDarkIndex == index
                      ? 4.0.r
                      : 2.0.r
                  : storeOperations.selectedFontLightIndex == index
                      ? 4.0.r
                      : 2.0.r),
          borderRadius: BorderRadius.all(Radius.circular(20.0.r)),
          boxShadow: const [
            BoxShadow(
              color: Colors.white10,
              blurRadius: 20,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: fontsColumn(index, items));
  }

  fontsColumn(int index, Item items) {
    return Padding(
      padding: EdgeInsets.only(top: 12.0.h),
      child: Stack(
        children: [
          fontsName(items),
          if (!items.isPurchased) fontsPrice(index, items),
          if (items.isPurchased &&
              (isDarkTheme
                  ? storeOperations.selectedFontDarkIndex != index
                  : storeOperations.selectedFontLightIndex != index))
            fontsSelectButton(index, items)
        ],
      ),
    );
  }

  fontsName(Item items) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6.0.w),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          items.name,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: GoogleFonts.getFont(items.name,
              fontSize: 20.sp,
              color: ColorUtils.getContrastingTextColor(isDarkTheme
                  ? Theme.of(context).scaffoldBackgroundColor.withAlpha(100)
                  : Theme.of(context).primaryColor.withAlpha(90))),
        ),
      ),
    );
  }

  fontsPrice(int index, Item items) {
    return GestureDetector(
      onTap: () {
        storeOperations.purchaseItem(items.id!, items.subcategoryId, index);
        storeOperations.loadFontsItems();
        AnalyticsService.logFontPurchase(items.name);
      },
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
            height: 50.h,
            width: 50.w,
            decoration: BoxDecoration(
              color: Provider.of<ThemeOperations>(context).themeMode ==
                      ThemeMode.dark
                  ? Theme.of(context).scaffoldBackgroundColor.withAlpha(128)
                  : Theme.of(context).primaryColor.withAlpha(128),
              border: Border(
                  left: BorderSide(
                      color: isDarkTheme
                          ? storeOperations.selectedFontDarkIndex == index
                              ? Theme.of(context).primaryColor
                              : ColorUtils.adjustColor(
                                  Theme.of(context).primaryColor, 0.5, false)
                          : storeOperations.selectedFontLightIndex == index
                              ? Theme.of(context).primaryColor
                              : ColorUtils.adjustColor(
                                  Theme.of(context).primaryColor, 0.5, false)),
                  top: BorderSide(
                      color: isDarkTheme
                          ? storeOperations.selectedFontDarkIndex == index
                              ? Theme.of(context).primaryColor
                              : ColorUtils.adjustColor(
                                  Theme.of(context).primaryColor, 0.5, false)
                          : storeOperations.selectedFontLightIndex == index
                              ? Theme.of(context).primaryColor
                              : ColorUtils.adjustColor(
                                  Theme.of(context).primaryColor, 0.5, false))),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0.r),
                  bottomRight: Radius.circular(20.0.r)),
            ),
            child: fontsPurchaseButton(index, items)),
      ),
    );
  }

  fontsPurchaseButton(int index, Item items) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          items.price.toString(),
          style: GoogleFonts.getFont(items.name, fontSize: 16.sp),
        ),
      ),
    );
  }

  fontsSelectButton(int index, Item items) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Container(
        height: 50.h,
        width: 50.h,
        decoration: BoxDecoration(
          color:
              Provider.of<ThemeOperations>(context).themeMode == ThemeMode.dark
                  ? Theme.of(context).scaffoldBackgroundColor.withAlpha(128)
                  : Theme.of(context).primaryColor.withAlpha(128),
          border: Border(
              left: BorderSide(
                  color: isDarkTheme
                      ? storeOperations.selectedFontDarkIndex == index
                          ? Theme.of(context).primaryColor
                          : ColorUtils.adjustColor(
                              Theme.of(context).primaryColor, 0.5, false)
                      : storeOperations.selectedFontLightIndex == index
                          ? Theme.of(context).primaryColor
                          : ColorUtils.adjustColor(
                              Theme.of(context).primaryColor, 0.5, false)),
              top: BorderSide(
                  color: isDarkTheme
                      ? storeOperations.selectedFontDarkIndex == index
                          ? Theme.of(context).primaryColor
                          : ColorUtils.adjustColor(
                              Theme.of(context).primaryColor, 0.5, false)
                      : storeOperations.selectedFontLightIndex == index
                          ? Theme.of(context).primaryColor
                          : ColorUtils.adjustColor(
                              Theme.of(context).primaryColor, 0.5, false))),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0.r),
              bottomRight: Radius.circular(20.0.r)),
        ),
        child: GestureDetector(
          onTap: () {
            if (isDarkTheme) {
              storeOperations.setFontDarkIndex(index);
              storeOperations.setFontDarkTheme(items.name);
              storeOperations.loadInitialFont();
              storeOperations.loadFontsItems();
              storeOperations.loadInitialDarkIndex();
              AnalyticsService.logFontChange(items.name);
            } else {
              storeOperations.setFontLightIndex(index);
              storeOperations.setFontLightTheme(items.name);
              storeOperations.loadInitialFont();
              storeOperations.loadFontsItems();
              storeOperations.loadInitialLightIndex();
              AnalyticsService.logFontChange(items.name);
            }
          },
          child: PhosphorIcon(PhosphorIconsBold.check,
              color: ColorUtils.getOptimalTextColor(
                  context,
                  Provider.of<ThemeOperations>(context).themeMode ==
                          ThemeMode.dark
                      ? Theme.of(context).scaffoldBackgroundColor.withAlpha(128)
                      : Theme.of(context).primaryColor.withAlpha(128))),
        ),
      ),
    );
  }

  _showSnackBar() {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tüm renkler sıfırlansın mı?',
          style: TextStyle(color: ColorUtils.getSnackBarTextColor(context)),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Evet',
          onPressed: () {
            storeOperations.setDefault();
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
        backgroundColor: ColorUtils.getContrastingTextColor(
            Theme.of(context).scaffoldBackgroundColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
      ),
    );
  }
}
