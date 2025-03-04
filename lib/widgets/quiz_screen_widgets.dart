import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:my_wordbook/providers/dictionary_operations.dart';
import 'package:my_wordbook/providers/word_operations.dart';
import 'package:my_wordbook/services/ad_service.dart';
import 'package:my_wordbook/services/analytics_service.dart';
import 'package:my_wordbook/widgets/quiz_completed_alert.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';

import '../models/word.dart';
import '../providers/store_operations.dart';
import '../providers/theme_operations.dart';
import '../utils/color_utils.dart';
import '../utils/fonts_utils.dart';

class QuizScreenWidgets extends StatefulWidget {
  final int id;
  final int numbersOfQuestions;
  final int record;
  final int order;
  final int selectedDifficulty;
  const QuizScreenWidgets(
      {super.key,
      required this.id,
      required this.numbersOfQuestions,
      required this.record,
      required this.order,
      required this.selectedDifficulty});

  @override
  State<QuizScreenWidgets> createState() => _QuizScreenWidgetsState();
}

class _QuizScreenWidgetsState extends State<QuizScreenWidgets>
    with SingleTickerProviderStateMixin {
  late int id;
  TextEditingController answerController = TextEditingController();
  late AnimationController _controller;
  Animation<double>? _animation;
  double _rotation = 0.0;
  bool isFlipped = false;
  int numberOfTrue = 0;
  int numberOfFalse = 0;
  int numberOfRecord = 0;
  late int numberOfQuestions;
  int currentQuestionsNumber = 1;
  List<Word> questions = [];
  late Word currentWord;
  bool isQuizCompleted = false;
  late int order;
  late bool isQuestionWord;
  late bool isHard;
  bool hasAnswered = false;
  bool hasNextQuestionBeenPressed = false;
  bool hasManuallyRotated = false;
  bool isQuestionCompleted = false;
  List<Word> selectedWords = [];
  bool hideNextButton = false;
  bool newRecord = false;
  String questionText = '';
  String answerText = '';

  late final StoreOperations storeOperations;
  late bool isDarkTheme;

  late final AdService adService;

  @override
  void initState() {
    super.initState();
    id = widget.id;
    _fetchQuestions();
    _fetchRecord();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        setState(() {
          _rotation = _animation?.value ?? _rotation;
        });
      });
    numberOfQuestions = widget.numbersOfQuestions;
    currentWord =
        Word(dictionaryId: 0, wordInLanguage1: "", wordInLanguage2: "");
    order = widget.order;
    isHard = widget.selectedDifficulty == 0 ? false : true;
    hideNextButton = numberOfQuestions == 1 ? true : false;
    storeOperations = Provider.of<StoreOperations>(context, listen: false);
    isDarkTheme = ThemeMode.dark ==
        Provider.of<ThemeOperations>(context, listen: false).themeMode;

    adService = Provider.of<AdService>(context, listen: false);
    adService.disposeAd();
    adService.loadBannerAd();
  }

  void _fetchQuestions() async {
    try {
      final list = await Provider.of<WordOperations>(context, listen: false)
          .getWords(id);
      setState(() {
        questions = list;
        currentWord = randomWord();
        questionsBuilderTextOrderUpdate();
        answerBuilderTextOrderUpdate();
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _fetchRecord() async {
    try {
      int highRecord =
          await Provider.of<DictionaryOperations>(context, listen: false)
              .getRecord(id);
      setState(() {
        numberOfRecord = highRecord;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Word randomWord() {
    if (questions.isEmpty) {
      throw Exception('Soru listesi boş');
    }

    if (selectedWords.length == questions.length) {
      selectedWords.clear();
    }

    Word rndmWord;
    do {
      int randomIndex = Random().nextInt(questions.length);
      rndmWord = questions[randomIndex];
    } while (selectedWords.contains(rndmWord));

    selectedWords.add(rndmWord);
    answerController.clear();
    return rndmWord;
  }

  questionsBuilderTextOrderUpdate() {
    if (order == 1) {
      questionText = currentWord.wordInLanguage1;
    } else if (order == 2) {
      isQuestionWord = Random().nextBool();
      questionText = (isQuestionWord)
          ? currentWord.wordInLanguage1
          : currentWord.wordInLanguage2;
    } else if (order == 3) {
      questionText = currentWord.wordInLanguage2;
    } else {
      questionText = '';
    }
  }

  questionsBuilder() {
    return AutoSizeText(
      questionText,
      textAlign: TextAlign.center,
      minFontSize: 14,
      maxFontSize: 26,
      textScaleFactor: Provider.of<ThemeOperations>(context)
          .getTextScaleFactor(context) *
          1.5,
      style: TextStyle(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  answerBuilderTextOrderUpdate() {
    if (order == 1) {
      answerText = currentWord.wordInLanguage2;
    } else if (order == 2) {
      answerText = (isQuestionWord)
          ? currentWord.wordInLanguage2
          : currentWord.wordInLanguage1;
    } else if (order == 3) {
      answerText = currentWord.wordInLanguage1;
    } else {
      answerText = '';
    }
  }

  answerBuilder() {
    return AutoSizeText(
      answerText,
      textAlign: TextAlign.center,
      minFontSize: 11,
      maxFontSize: 26,
      textScaleFactor: Provider.of<ThemeOperations>(context)
          .getTextScaleFactor(context),
      style: TextStyle(
          color: Theme.of(context).scaffoldBackgroundColor, fontSize: 26.sp * Provider.of<ThemeOperations>(context)
          .getTextScaleFactor(context)),
    );
  }

  void answerOfQuestions(String mean) async {
    var list = [];
    if (order == 1) {
      list = await Provider.of<WordOperations>(context, listen: false)
          .getSearchWordMeaning(id, mean);
    } else if (order == 2) {
      list = (isQuestionWord)
          ? await Provider.of<WordOperations>(context, listen: false)
              .getSearchWordMeaning(id, mean)
          : await Provider.of<WordOperations>(context, listen: false)
              .getSearchMeanByWords(id, mean);
    } else if (order == 3) {
      list = await Provider.of<WordOperations>(context, listen: false)
          .getSearchMeanByWords(id, mean);
    }

    if (list.isNotEmpty && list.any((word) => word.id == currentWord.id)) {
      if (mounted) {
        flipCard();
        numberOfTrue += 1;
        isQuestionCompleted = true;
        if (numberOfTrue > numberOfRecord) {
          Provider.of<DictionaryOperations>(context, listen: false)
              .setRecord(id, numberOfTrue);
          _fetchRecord();
          newRecord = true;
        }
        if (hideNextButton) {
          setState(() {
            isQuizCompleted = true;
          });
        }
      }
    } else if (mean.isNotEmpty) {
      if (isHard) {
        incrementWrongAnswer();
        isQuestionCompleted = true;
        if (hideNextButton) {
          debugPrint("bbb");
          isQuizCompleted = true;
        }
      } else if (isQuestionCompleted) {
        incrementWrongAnswer();
        debugPrint("yanlış");
        if (hideNextButton) {
          debugPrint("bbb");
          isQuizCompleted = true;
        }
      }
    }
  }

  Future<void> _animateToSide() async {
    final endRotation =
        (_rotation % (2 * pi) > pi / 2 && _rotation % (2 * pi) < 3 * pi / 2)
            ? pi
            : 0.0;

    _animation = Tween<double>(begin: _rotation, end: endRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(from: 0).then((_) {
      isFlipped = endRotation == pi;
    });

    if (!isQuestionCompleted && !isFlipped) {
      if (answerController.text.isEmpty || !(await _isAnswerCorrect())) {
        incrementWrongAnswer();
        isQuestionCompleted = true;

        if (hideNextButton) {
          isQuizCompleted = true;
          debugPrint("yazı yazılmadı el ile çevrildi");
        }
      }
    } else {}
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _rotation += details.primaryDelta! / 100;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    _animateToSide();
  }

  void flipCard() {
    final endRotation = isFlipped ? 0.0 : pi;

    _animation = Tween<double>(begin: _rotation, end: endRotation).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward(from: 0).then((_) {
      setState(() {
        _rotation = endRotation;
        isFlipped = !isFlipped;
      });
    });
  }

  Future<bool> _isAnswerCorrect() async {
    var list = [];
    if (order == 1) {
      list = await Provider.of<WordOperations>(context, listen: false)
          .getSearchWordMeaning(id, answerController.text);
    } else if (order == 2) {
      list = (isQuestionWord)
          ? await Provider.of<WordOperations>(context, listen: false)
              .getSearchWordMeaning(id, answerController.text)
          : await Provider.of<WordOperations>(context, listen: false)
              .getSearchMeanByWords(id, answerController.text);
    } else if (order == 3) {
      list = await Provider.of<WordOperations>(context, listen: false)
          .getSearchMeanByWords(id, answerController.text);
    }

    return list.isNotEmpty && list.any((word) => word.id == currentWord.id);
  }

  void incrementWrongAnswer() {
    setState(() {
      numberOfFalse += 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Stack(
        alignment: Alignment.center,
        children: [
          //Bulanık Arkaplan
          blurBackground(),
          //Geri butonu
          backScreenButton(),
          //Sayaç
          counter(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  //Soru sayacı
                  questionsCounter(),
                  //Diğer soru
                  nextQuestions(),
                ],
              ),
              //Kart Widgeti
              flippableCard(),
              if (isQuizCompleted) completeButton(),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: bannerAdArea(),
          )
        ],
      ),
      onTap: () {
        FocusScope.of(context).unfocus();
      },
    );
  }

  //Bulanık Arkaplan
  blurBackground() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Container(
          color: Theme.of(context).scaffoldBackgroundColor.withAlpha(55)),
    );
  }

  //Geri butonu
  backScreenButton() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 16.w, top: 30.h),
        child: IconButton(
            onPressed: () {
              AnalyticsService.logButtonClick('quiz_screen_back_button');
              AnalyticsService.logScreenView('dictionary');
              Navigator.pop(context);
              FocusScope.of(context).unfocus();
            },
            icon: PhosphorIcon(
              PhosphorIconsBold.arrowLeft,
              size: 28.sp,
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
            )),
      ),
    );
  }

  //Sayaç
  counter() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(right: 16.0.w, top: 35.0.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 40.h,
            minWidth: 160.w,
            maxHeight: 40.h,
            maxWidth: 200.w,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ColorUtils.getOptimalTextColor(
                  context, Theme.of(context).scaffoldBackgroundColor),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  trueCounter(),
                  SizedBox(
                    width: 8.w,
                  ),
                  falseCounter(),
                  SizedBox(
                    width: 8.w,
                  ),
                  recordCounter(),
                  SizedBox(
                    width: 5.w,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  trueCounter() {
    return Row(
      children: [
        PhosphorIcon(
          PhosphorIconsBold.checkFat,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        Text(
          " : ${numberOfTrue.toString()} ",
          style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  falseCounter() {
    return Row(
      children: [
        PhosphorIcon(PhosphorIconsBold.x,
            color: Theme.of(context).scaffoldBackgroundColor),
        Text(
          " : ${numberOfFalse.toString()} ",
          style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  recordCounter() {
    return Row(
      children: [
        PhosphorIcon(PhosphorIconsBold.star,
            size: 22.sp, color: Theme.of(context).scaffoldBackgroundColor),
        Text(
          " : ${numberOfRecord.toString()}",
          style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  //Soru sayacı
  questionsCounter() {
    return Padding(
      padding: EdgeInsets.only(left: 20.0.w),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
            minHeight: 45, minWidth: 45, maxHeight: 45, maxWidth: 380),
        child: Container(
          decoration: BoxDecoration(
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.only(left: 10.0.w, right: 10.0.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("$currentQuestionsNumber - $numberOfQuestions",
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 18.sp * Provider.of<ThemeOperations>(context)
                            .getTextScaleFactor(context),
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Diğer soru
  nextQuestions() {
    return Padding(
      padding: EdgeInsets.only(left: 8.0.w),
      child: Container(
        alignment: Alignment.center,
        width: 35.w,
        height: 35.h,
        child: Visibility(
          visible: !hideNextButton,
          child: IconButton(
            onPressed: () async {
              // Son soruya ulaşıldıysa tamamlandı olarak işaretle
              if ((currentQuestionsNumber + 1 == numberOfQuestions)) {
                hideNextButton = true;
                if (isFlipped) {
                  flipCard();
                }
              }

              // Yanlış kontrolünü sadece bir kez yap
              if (!hasNextQuestionBeenPressed && !isQuestionCompleted) {
                hasNextQuestionBeenPressed = true;
                isQuestionCompleted = true;

                // Eğer cevap yanlışsa veya boşsa yanlış sayısını artır
                if (answerController.text.isEmpty ||
                    !(await _isAnswerCorrect())) {
                  incrementWrongAnswer();
                  flipCard();
                  Future.delayed(const Duration(seconds: 1, milliseconds: 30))
                      .whenComplete(
                    () {
                      currentWord = randomWord();
                      questionsBuilderTextOrderUpdate();
                      answerBuilderTextOrderUpdate();
                      currentQuestionsNumber += 1;

                      // Yeni soru için durumu sıfırla
                      hasNextQuestionBeenPressed = false;
                      isQuestionCompleted = false;
                      answerController.clear();
                      flipCard();
                    },
                  );
                }
              } else {
                if (isFlipped) {
                  flipCard();
                  currentWord = randomWord();
                  questionsBuilderTextOrderUpdate();
                  answerBuilderTextOrderUpdate();
                  currentQuestionsNumber += 1;

                  // Yeni soru için durumu sıfırla
                  hasNextQuestionBeenPressed = false;
                  isQuestionCompleted = false;
                  answerController.clear();
                } else {
                  currentWord = randomWord();
                  questionsBuilderTextOrderUpdate();
                  answerBuilderTextOrderUpdate();
                  currentQuestionsNumber += 1;

                  // Yeni soru için durumu sıfırla
                  hasNextQuestionBeenPressed = false;
                  isQuestionCompleted = false;
                  answerController.clear();
                }
              }
            },
            icon: const PhosphorIcon(PhosphorIconsBold.caretRight),
            padding: EdgeInsets.zero,
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor),
            iconSize: 30.sp,
          ),
        ),
      ),
    );
  }

  //Kart Widgeti
  flippableCard() {
    return GestureDetector(
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(_rotation),
        child: isFlipped
            ? Transform(
                transform: Matrix4.rotationY(pi),
                alignment: Alignment.center,
                child: backCard(),
              )
            : frontCard(),
      ),
    );
  }

  //Kartın arka yüzü
  backCard() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0.w,
        right: 16.0.w,
      ),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: 400.w, minHeight: 200.h, maxHeight: 600.h),
        child: Card(
          elevation: 4.r,
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).scaffoldBackgroundColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(20.0.r),
                child: answerBuilder(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Kartın ön yüzü
  frontCard() {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0.w,
        right: 16.0.w,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
            minWidth: 400.w,
            maxWidth: 400.w,
            minHeight: 200.h,
            maxHeight: 470.h),
        child: Card(
          elevation: 4.r,
          color: ColorUtils.getOptimalTextColor(
              context, Theme.of(context).scaffoldBackgroundColor),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          child: Padding(
            padding: EdgeInsets.all(20.0.r),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                questionsBuilder(),
                if (!isQuestionCompleted)
                  SizedBox(
                    width: 300.w,
                    child: TextField(
                      controller: answerController,
                      enabled: !isQuizCompleted,
                      maxLines: 4,
                      minLines: 1,
                      textAlign: TextAlign.center,
                      cursorColor: Theme.of(context).scaffoldBackgroundColor,
                      style: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          fontSize: 20.sp *
                              (FontsUtils.getFontScaleFactor(isDarkTheme
                                  ? storeOperations.fontStyleDark
                                  : storeOperations.fontStyleLight))),
                      decoration: InputDecoration(
                          hintText: "...........................",
                          hintStyle: TextStyle(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              fontSize: 18.sp *
                                  (FontsUtils.getFontScaleFactor(isDarkTheme
                                      ? storeOperations.fontStyleDark
                                      : storeOperations.fontStyleLight))),
                          focusedBorder: InputBorder.none,
                          border: InputBorder.none,
                          disabledBorder: InputBorder.none),
                      textInputAction: TextInputAction.done,
                      onSubmitted: (value) {
                        FocusScope.of(context).unfocus();
                        answerOfQuestions(answerController.text);
                      },
                      onChanged: isHard ? null : answerOfQuestions,
                    ),
                  ),
                if (isHard &&
                    answerController.text.isNotEmpty &&
                    !isQuestionCompleted)
                  IconButton(
                    onPressed: () async {
                      flipCard();
                      answerOfQuestions(answerController.text);
                    },
                    icon: PhosphorIcon(
                      PhosphorIconsBold.checkFat,
                      color: ColorUtils.getOptimalTextColor(
                          context, Theme.of(context).primaryColor),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  completeButton() {
    return Padding(
      padding: EdgeInsets.only(top: 20.0.h),
      child: Container(
          height: 70.h,
          width: 70.w,
          decoration: BoxDecoration(
            color: ColorUtils.getOptimalTextColor(
                context, Theme.of(context).scaffoldBackgroundColor),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: IconButton(
              onPressed: () {
                AnalyticsService.logQuizCompleted(
                    numberOfTrue, numberOfFalse, numberOfRecord);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => QuizCompletedAlert(
                    id: id,
                    numberOfTrue: numberOfTrue,
                    numberOfFalse: numberOfFalse,
                    numberOfRecord: numberOfRecord,
                    newRecord: newRecord,
                  ),
                );
              },
              icon: PhosphorIcon(PhosphorIconsBold.check,
                  color: Theme.of(context).scaffoldBackgroundColor,
                  size: 48.sp))),
    );
  }

  bannerAdArea() {
    return SafeArea(
      child: SizedBox(
        width: MediaQuery.of(context).size.width.truncate().toDouble(),
        height: 100.h,
        child: adService.bannerAd == null
            ? const SizedBox()
            : AdWidget(ad: adService.bannerAd!),
      ),
    );
  }
}
