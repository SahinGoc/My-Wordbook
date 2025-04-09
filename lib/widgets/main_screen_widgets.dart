import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:my_wordbook/widgets/edit_dictionary_alert.dart';
import 'package:my_wordbook/widgets/set_title_alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:lottie/lottie.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/dictionary_operations.dart';
import '../models/dictionary.dart';
import '../providers/theme_operations.dart';
import '../services/analytics_service.dart';
import '../utils/color_utils.dart';

class MainScreenWidgets extends StatefulWidget {
  const MainScreenWidgets({super.key});

  @override
  State<MainScreenWidgets> createState() => _MainScreenWidgetsState();
}

class _MainScreenWidgetsState extends State<MainScreenWidgets>
    with TickerProviderStateMixin {
  bool _isPopupVisible = false;
  Offset _popupPosition = Offset.zero;
  Dictionary? dict;
  bool isVisible = false;
  List<int> totalNumber = [];
  late bool isDarkTheme;
  late final StoreOperations storeOperations;
  late ScrollController _controller;
  ValueNotifier<bool> sliverCollapsedNotifier = ValueNotifier(false);

  final FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    Provider.of<ThemeOperations>(context, listen: false).initController(this);
    storeOperations = Provider.of<StoreOperations>(context, listen: false);

    _controller = ScrollController();

    _controller.addListener(() {
      if (_controller.offset > 100.h && !_controller.position.outOfRange) {
        if (!sliverCollapsedNotifier.value) {
          sliverCollapsedNotifier.value = true;
        }
      }

      if (_controller.offset <= 100.h && !_controller.position.outOfRange) {
        if (sliverCollapsedNotifier.value) {
          sliverCollapsedNotifier.value = false;
        }
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final themeOps = Provider.of<ThemeOperations>(context, listen: false);
      themeOps.loadInitialThemeMode(context).then((_) {
        setState(() {
          isDarkTheme = themeOps.themeMode == ThemeMode.dark;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _viewWidget(),
      onTap: () {
        if (_isPopupVisible) {
          setState(() {
            _isPopupVisible = false;
            FocusScope.of(context).unfocus();
          });
        }
      },
    );
  }

  _viewWidget() {
    return Consumer<DictionaryOperations>(
      builder: (BuildContext context, value, Widget? child) {
        return FutureBuilder(
          future: value.getAllDictionaries(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError == true) {
              return const Center(
                child: Text("Hata ile karşılaşıldı."),
              );
            }
            if (snapshot.hasData) {
              List<Dictionary> list = snapshot.data;
              return Stack(
                children: [
                  _customScrollView(list, context),
                  if (_isPopupVisible) _buildPopup(),
                ],
              );
            }
            return Center(
                child: Lottie.asset('assets/animations/circular.json'));
          },
        );
      },
    );
  }

  _customScrollView(List<Dictionary> list, BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: sliverCollapsedNotifier,
      builder: (context, sliverCollapsed, child) {
        return CustomScrollView(controller: _controller, slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 200.0.h,
            actions: [
              if (!sliverCollapsed) ...[
                storeButton(),
                detailsButton(),
                themeChangerButton(context)
              ]
            ],
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30.r),
                  bottomRight: Radius.circular(30.r)),
            ),
            flexibleSpace: spaceBar(),
          ),
          SliverPadding(
            padding: EdgeInsets.all(8.0.r),
            sliver: _sliverGrid(list),
          )
        ]);
      },
    );
  }

  spaceBar() {
    return FlexibleSpaceBar(
      title: GestureDetector(
        onDoubleTap: () {
          AnalyticsService.logButtonClick('title_doubleTap');
          showDialog(
              context: context, builder: (context) => const SetTitleAlert());
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.0.w),
          child: Text(
            Provider.of<StoreOperations>(context).title.toUpperCase(),
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).primaryColor),
              fontSize: 18.sp *
                  Provider.of<ThemeOperations>(context)
                      .getTextScaleFactor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  themeChangerButton(BuildContext context) {
    final themeOps = Provider.of<ThemeOperations>(context, listen: false);
    return GestureDetector(
      onTap: () async {
        await themeOps.toggleTheme(!(themeOps.themeMode == ThemeMode.dark));
        await Future.delayed(const Duration(milliseconds: 300));
        setState(() {
          isDarkTheme = themeOps.themeMode == ThemeMode.dark;
        });
        AnalyticsService.logThemeChange(themeOps.themeMode == ThemeMode.dark);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w),
        child: Lottie.asset(
          'assets/animations/day-night.json',
          width: 50.w,
          controller: themeOps.animationController,
          repeat: false,
        ),
      ),
    );
  }

  detailsButton() {
    return IconButton(
        onPressed: () {
          setState(() {
            isVisible = !isVisible;
          });
          AnalyticsService.logButtonClick('Details');
        },
        icon: isVisible == false
            ? PhosphorIcon(PhosphorIconsRegular.starFour, size: 28.sp)
            : PhosphorIcon(PhosphorIconsFill.starFour, size: 28.sp),
        color: Theme.of(context).iconTheme.color);
  }

  storeButton() {
    return IconButton(
        onPressed: () {
          AnalyticsService.logScreenView('Store');
          Navigator.pushNamed(context, '/store');
        },
        icon: PhosphorIcon(PhosphorIconsRegular.shoppingBagOpen,
            size: 28.sp, color: Theme.of(context).iconTheme.color));
  }

  _sliverGrid(List<Dictionary> list) {
    return SliverMasonryGrid(
      gridDelegate:
          SliverSimpleGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      delegate: SliverChildBuilderDelegate(
        childCount: list.length,
        (context, index) {
          return dictCard(list, index);
        },
      ),
    );
  }

  dictCard(List<Dictionary> list, int index) {
    return GestureDetector(
      child: SizedBox(
        height: list[index].language2Name == '' ? 100.h : 200.h,
        width: 200.h,
        child: Card(
          elevation: 4.r,
          shape: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.circular(10.0.r))),
          color: Theme.of(context).cardTheme.color,
          child: Padding(
            padding: EdgeInsets.all(8.0.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (!isVisible) ...[
                  cardTitle1(list, index),
                  if (list[index].language2Name.isNotEmpty) ...[
                    cardTitleBracket(),
                    cardTitle2(list, index),
                  ],
                ] else ...[
                  if (list[index].language2Name.isEmpty)
                    cardDetailsRow(list, index)
                  else ...[
                    cardDetailsWord(list, index),
                    cardTitleBracket(),
                    cardDetailsRecord(list, index)
                  ]
                ],
              ],
            ),
          ),
        ),
      ),
      onTap: () {
        AnalyticsService.logScreenView('Dictionary');
        Navigator.pushNamed(context, '/dictionary', arguments: list[index].id);
      },
      onLongPressStart: (details) {
        setState(() {
          AnalyticsService.logButtonClick('card_longPress');
          _isPopupVisible = true;
          _popupPosition = details.globalPosition;
          dict = Dictionary(
              id: list[index].id,
              language1Id: list[index].language1Id,
              language2Id: list[index].language2Id,
              language1Name: list[index].language1Name,
              language2Name: list[index].language2Name,
              totalNumber: list[index].totalNumber,
              record: list[index].record);
        });
      },
    );
  }

  cardTitle1(List<Dictionary> list, int index) {
    return AutoSizeText(
      list[index].language1Name,
      minFontSize: 8,
      maxFontSize: 28,
      overflow: TextOverflow.ellipsis,
      maxLines: list[index].language2Name == '' ? 3 : 1,
      textAlign: TextAlign.center,
    );
  }

  cardTitleBracket() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        color: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).cardColor),
        height: 1.h,
      ),
    );
  }

  cardTitle2(List<Dictionary> list, int index) {
    return AutoSizeText(
      list[index].language2Name,
      minFontSize: 8,
      maxFontSize: 28,
      maxLines: 1,
      textAlign: TextAlign.center,
    );
  }

  cardDetailsWord(List<Dictionary> list, int index) {
    return AutoSizeText(
      'Kelime: ${list[index].totalNumber}',
      maxFontSize: 14,
      minFontSize: 11,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).cardColor),
      ),
    );
  }

  cardDetailsVerticalBracket() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        color: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).cardColor),
        width: 1.h,
        height: 50.h,
      ),
    );
  }

  cardDetailsRecord(List<Dictionary> list, int index) {
    return AutoSizeText(
      'Rekor: ${list[index].record}',
      maxFontSize: 14,
      minFontSize: 11,
      maxLines: 1,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: ColorUtils.getOptimalTextColor(
            context, Theme.of(context).cardColor),
      ),
    );
  }

  cardDetailsRow(List<Dictionary> list, int index) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          cardDetailsWord(list, index),
          cardDetailsVerticalBracket(),
          cardDetailsRecord(list, index)
        ],
      ),
    );
  }

  _buildPopup() {
    return Positioned(
      left: _popupPosition.dx + 70.w > MediaQuery.of(context).size.width
          ? _popupPosition.dx - 60.w
          : _popupPosition.dx,
      top: _popupPosition.dy - 50.h,
      child: Material(
        child: Container(
          padding: EdgeInsets.all(2.0.r),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border:
                Border.all(color: Theme.of(context).primaryColor, width: 0.5.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                child: Text(
                  'DÜZENLE',
                  style: TextStyle(
                      fontSize: 12.sp *
                          Provider.of<ThemeOperations>(context)
                              .getTextScaleFactor(context),
                      color: ColorUtils.getContrastingTextColor(
                          Theme.of(context).scaffoldBackgroundColor)),
                ),
                onPressed: () {
                  AnalyticsService.logButtonClick('wordbook_edit');
                  setState(() {
                    _isPopupVisible = false; // Popup'u gizle
                  });
                  showDialog(
                      context: context,
                      builder: (context) => EditDictionaryAlert(dict: dict!));
                },
              ),
              Container(
                height: 1,
                color: ColorUtils.getContrastingTextColor(
                    Theme.of(context).scaffoldBackgroundColor),
              ),
              TextButton(
                child: Text('SİL',
                    style: TextStyle(
                        fontSize: 12.sp *
                            Provider.of<ThemeOperations>(context)
                                .getTextScaleFactor(context),
                        color: ColorUtils.getContrastingTextColor(
                            Theme.of(context).scaffoldBackgroundColor))),
                onPressed: () {
                  AnalyticsService.logButtonClick('wordbook_delete');
                  Provider.of<DictionaryOperations>(context, listen: false)
                      .deleteDictionary(dict!.id!);
                  setState(() {
                    _isPopupVisible = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
