import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_wordbook/providers/store_operations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/theme_operations.dart';

ThemeData darkTheme(BuildContext context) {
  StoreOperations storeOperations = Provider.of<StoreOperations>(context);
  return ThemeData(
    fontFamilyFallback: const ['Roboto'],
    brightness: Brightness.dark,
    primaryColor: Color(storeOperations.darkMainColorValue),
    scaffoldBackgroundColor: Color(storeOperations.darkBackGColorValue),
    appBarTheme: AppBarTheme(
      color: Color(storeOperations.darkMainColorValue),
      elevation: 0,
      iconTheme:
          IconThemeData(color: Color(storeOperations.darkIconColorValue)),
      titleTextStyle: GoogleFonts.getFont(
          storeOperations.fontStyleDark,
          color: Color(storeOperations.darkBackGColorValue),
          fontSize: 20.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
          fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Color(storeOperations.darkFABColorValue),
        foregroundColor: Color(storeOperations.darkFABIconColorValue)),
    cardTheme: CardTheme(
      color: Color(storeOperations.darkRightCardColorValue),
      surfaceTintColor: Color(storeOperations.darkLeftCardColorValue),
      shadowColor: Colors.grey.shade800,
      elevation: 6.r,
    ),
    textTheme: GoogleFonts.getTextTheme(
      storeOperations.fontStyleDark,
      TextTheme(
          bodyLarge: TextStyle(
              color: Color(storeOperations.darkTextColorValue),
              fontSize: 16.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              fontFamilyFallback: const ['Roboto']),
          bodyMedium: TextStyle(
              color: Color(storeOperations.darkTextColorValue),
              fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              fontFamilyFallback: const ['Roboto']),
          bodySmall: TextStyle(
              color: Color(storeOperations.darkTextColorValue),
              fontSize: 12.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              fontFamilyFallback: const ['Roboto']),
          titleLarge: TextStyle(
              color: Color(storeOperations.darkTextColorValue),
              fontWeight: FontWeight.bold,
              fontSize: 24.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              fontFamilyFallback: const ['Roboto']),
          titleMedium: TextStyle(
              color: Color(storeOperations.darkTextColorValue),
              fontWeight: FontWeight.bold,
              fontSize: 22.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              fontFamilyFallback: const ['Roboto']),
          titleSmall: TextStyle(
              color: Color(storeOperations.darkTextColorValue),
              fontWeight: FontWeight.bold,
              fontSize: 20.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
              fontFamilyFallback: const ['Roboto'])),
    ),
    iconTheme: IconThemeData(
      color: Color(storeOperations.darkIconColorValue),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0.r),
        borderSide: BorderSide(
            color: Color(storeOperations.darkMainColorValue), width: 2.0.w),
      ),
    ),
  );
}
