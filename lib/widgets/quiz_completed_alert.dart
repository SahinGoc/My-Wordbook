import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/services/ad_service.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:flutter/material.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/theme_operations.dart';
import '../utils/color_utils.dart';

class QuizCompletedAlert extends StatefulWidget {
  final int id;
  final int numberOfTrue;
  final int numberOfFalse;
  final int numberOfRecord;
  final bool newRecord;
  const QuizCompletedAlert(
      {super.key,
      required this.id,
      required this.numberOfTrue,
      required this.numberOfFalse,
      required this.numberOfRecord,
      required this.newRecord});

  @override
  State<QuizCompletedAlert> createState() => _QuizCompletedAlertState();
}

class _QuizCompletedAlertState extends State<QuizCompletedAlert> {
  int id = 0;
  int numberOfTrue = 0;
  int numberOfFalse = 0;
  int numberOfRecord = 0;
  bool newRecord = false;
  List<int> score = [];
  List<int> factor = [];
  int money = 0;
  List<int> numberOfScore = [];
  List<String> text = ['Doğru', 'Yanlış', 'Rekor'];

  late final AdService adService;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    numberOfTrue = widget.numberOfTrue;
    numberOfFalse = widget.numberOfFalse;
    numberOfRecord = widget.numberOfRecord;
    newRecord = widget.newRecord;
    numberOfScore = [numberOfTrue, numberOfFalse, numberOfRecord];

    score = [numberOfTrue, numberOfFalse];
    factor = [20, -10];
    money = score[0] * factor[0] + score[1] * factor[1] + (newRecord ? 20 : 0);

    adService = Provider.of<AdService>(context, listen: false);

    adService.loadRewardedAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storeOperations =
          Provider.of<StoreOperations>(context, listen: false);
      if (storeOperations.totalMoney < -money && money < 0) {
        storeOperations.calculateMoney(-storeOperations.totalMoney);
      } else {
        storeOperations.calculateMoney(money);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            Future.microtask(() {
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/dictionary', arguments: id);
              }
            });
          }
        },
        child: alertDialog());
  }

  alertDialog() {
    return AlertDialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: alertTitle(),
      actions: [buttonsRow()],
      content: SingleChildScrollView(
        child: ListBody(
          children: [
            //Doğru, yanlış ve rekor
            scoreTable(),
            SizedBox(height: 10.h,),
            Container(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
              height: 2.h,
            ),
            SizedBox(
              height: 20.h,
            ),
            //Sonuca göre para hesaplama
            details(),
            SizedBox(
              height: 25.h,
            ),
            Container(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
              height: 2.h,
            ),
            //reklam
            if (money > 0 && !(adService.isClicked))
              rewardedAdContainer(),

            SizedBox(
              height: 10.h,
            ),
            //Toplam para
            totalMoney(),
            SizedBox(
              height: 15.0.h,
            ),
            Container(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
              height: 2.h,
            ),
          ],
        ),
      ),
    );
  }

  alertTitle() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        'TEBRİKLER',
        maxLines: 1,
        textAlign: TextAlign.center,
        style: TextStyle(
            fontSize: 24.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
            fontWeight: FontWeight.bold,
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor)),
      ),
    );
  }

  scoreTable() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) {
          return scoreConstrainedBox(index);
        },
      ),
    );
  }

  scoreConstrainedBox(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        scoreText(index),
        Container(
          height: 1.h,
          width: 50.w,
          color: ColorUtils.getOptimalTextColor(
            context,
            Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        scoreNumber(index)
      ],
    );
  }

  scoreText(int index) {
    return SizedBox(
      width: 80.w,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text[index],
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorUtils.getOptimalTextColor(
              context,
              Theme.of(context).scaffoldBackgroundColor,
            ),
            fontSize: 16.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
          ),
        ),
      ),
    );
  }

  scoreNumber(int index) {
    return SizedBox(
      width: 80.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              numberOfScore[index].toString(),
              maxLines: 1,
              style: TextStyle(
                color: ColorUtils.getOptimalTextColor(
                  context,
                  Theme.of(context).scaffoldBackgroundColor,
                ),
                fontSize: 20.sp * Provider.of<ThemeOperations>(context)
                    .getTextScaleFactor(context),
              ),
            ),
          ),
          if (index == 2 && newRecord) newRecordText(),
        ],
      ),
    );
  }

  newRecordText() {
    return SizedBox(
      width: 80.w,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'Yeni Rekor!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: ColorUtils.getOptimalTextColor(
              context,
              Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ),
      ),
    );
  }

  details() {
    return ConstrainedBox(
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.75,
          maxWidth: MediaQuery.of(context).size.width * 0.75,
          minHeight: MediaQuery.of(context).size.height * 0.04,
          maxHeight: MediaQuery.of(context).size.height * 0.4),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.0.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(
              2,
              (index) {
                return detailsRow(index);
              },
            ),
            if (newRecord) newRecordDetailsRow(),
            if (adService.isClicked) adDetailsRow(),
            Container(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
              height: 1.h,
            ),
            sumDetailsRow()
          ],
        ),
      ),
    );
  }

  detailsRow(int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "${score[index]} x ${factor[index]} puan",
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
        Text(
          (score[index] * factor[index]).toString(),
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ],
    );
  }

  newRecordDetailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Yeni Rekor!",
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
        Text(
          "50",
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
              .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ],
    );
  }

  adDetailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Reklam Ödülü",
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
        Text(
          (money / 2).toInt().toString(),
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ],
    );
  }

  sumDetailsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Kazanılan puan",
          style: TextStyle(
            fontSize: 13.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
        Text(
          money.toString(),
          style: TextStyle(
            fontSize: 14.sp * Provider.of<ThemeOperations>(context)
                .getTextScaleFactor(context),
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor)),
        ),
      ],
    );
  }

  rewardedAdContainer() {
    return ConstrainedBox(
      constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width * 0.75,
          maxWidth: MediaQuery.of(context).size.width * 0.75,
          minHeight: MediaQuery.of(context).size.height * 0.04,
          maxHeight: MediaQuery.of(context).size.height * 0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              rewardedAdText(),
              rewardedAdButton(),
            ],
          ),
          Container(
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor),
            height: 2.h,
          ),
        ],
      ),
    );
  }

  rewardedAdText() {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        "+${money / 2}",
        style: TextStyle(
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor),
            fontWeight: FontWeight.bold),
      ),
    );
  }

  rewardedAdButton() {
    return IconButton(
        onPressed: () {
          adService.rewardedAd == null
              ? null
              : adService
                  .showRewardedAd(context, (money / 2).toInt());
          adService.rewardedAd == null
              ? null
              : AnalyticsService.logRewardedAdClicked((money / 2).toInt());
        },
        icon: PhosphorIcon(PhosphorIconsRegular.filmSlate,
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor),
            size: 42.sp));
  }

  totalMoney() {
    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width * 0.75,
            maxWidth: MediaQuery.of(context).size.width * 0.75,
            minHeight: MediaQuery.of(context).size.height * 0.04,
            maxHeight: MediaQuery.of(context).size.height * 0.4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text("Toplam Puan",
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 24.sp * Provider.of<ThemeOperations>(context)
                          .getTextScaleFactor(context),
                      color: ColorUtils.getOptimalTextColor(
                          context, Theme.of(context).scaffoldBackgroundColor))),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                  Provider.of<StoreOperations>(context, listen: false)
                      .totalMoney
                      .toString(),
                  maxLines: 1,
                  style: TextStyle(
                      fontSize: 22.sp * Provider.of<ThemeOperations>(context)
                          .getTextScaleFactor(context),
                      color: ColorUtils.getOptimalTextColor(
                          context, Theme.of(context).scaffoldBackgroundColor))),
            ),
          ],
        ),
      ),
    );
  }

  buttonsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 20.0.w,
      children: [
        IconButton(
            onPressed: () {
              AnalyticsService.logButtonClick('quiz_back_button');
              AnalyticsService.logScreenView('dictionary');
              adService.showInterstitialAd();
              Navigator.pushNamed(context, '/dictionary', arguments: id);
            },
            icon: PhosphorIcon(
              PhosphorIconsBold.caretLeft,
              size: 52.sp,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
            )),
        IconButton(
            onPressed: () {
              AnalyticsService.logButtonClick('quiz_main_screen_button');
              AnalyticsService.logScreenView('main');
              adService.showInterstitialAd();
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
            },
            icon: PhosphorIcon(
              PhosphorIconsBold.houseLine,
              size: 52.sp,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
            )),
        IconButton(
            onPressed: () {
              AnalyticsService.logButtonClick('quiz_store_screen_button');
              AnalyticsService.logScreenView('store');
              adService.showInterstitialAd();
              Navigator.pushNamed(context, '/store');
            },
            icon: PhosphorIcon(
              PhosphorIconsBold.shoppingBag,
              size: 52.sp,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
            ))
      ],
    );
  }
}
