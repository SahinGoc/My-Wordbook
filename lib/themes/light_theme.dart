import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/store_operations.dart';
import '../providers/theme_operations.dart';

ThemeData lightTheme(BuildContext context) {
  StoreOperations storeOperations = Provider.of<StoreOperations>(context);
  return ThemeData(
    fontFamilyFallback: const ['Roboto'],
    brightness: Brightness.light,
    primaryColor: Color(storeOperations.lightMainColorValue),
    scaffoldBackgroundColor: Color(storeOperations.lightBackGColorValue),
    appBarTheme: AppBarTheme(
      color: Color(storeOperations.lightMainColorValue),
      iconTheme:
          IconThemeData(color: Color(storeOperations.lightIconColorValue)),
      titleTextStyle: GoogleFonts.getFont(
        storeOperations.fontStyleLight,
          color: Color(storeOperations.lightBackGColorValue),
          fontSize: 20.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
          fontWeight: FontWeight.bold),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(storeOperations.lightFABColorValue), // FAB rengi
      foregroundColor: Color(
          storeOperations.lightFABIconColorValue), // FAB üzerindeki ikon rengi
    ),
    cardTheme: CardTheme(
      color: Color(storeOperations.lightRightCardColorValue),
      surfaceTintColor: Color(storeOperations.lightLeftCardColorValue),
      shadowColor: Colors.grey.shade800,
      elevation: 6.r,
    ),
    iconTheme: IconThemeData(color: Color(storeOperations.lightIconColorValue)),
    textTheme: GoogleFonts.getTextTheme(
      storeOperations.fontStyleLight,
      TextTheme(
        bodyLarge: TextStyle(
            color: Color(storeOperations.lightTextColorValue),
            fontSize: 16.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            fontFamilyFallback: const ['Roboto']),
        bodyMedium: TextStyle(
            color: Color(storeOperations.lightTextColorValue),
            fontSize: 14.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            fontFamilyFallback: const ['Roboto']),
        bodySmall: TextStyle(
            color: Color(storeOperations.lightTextColorValue),
            fontSize: 12.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            fontFamilyFallback: const ['Roboto']),
        titleLarge: TextStyle(
            color: Color(storeOperations.lightTextColorValue),
            fontSize: 24.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            fontWeight: FontWeight.bold,
            fontFamilyFallback: const ['Roboto']),
        titleMedium: TextStyle(
            color: Color(storeOperations.lightTextColorValue),
            fontSize: 22.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            fontWeight: FontWeight.bold,
            fontFamilyFallback: const ['Roboto']),
        titleSmall: TextStyle(
            color: Color(storeOperations.lightTextColorValue),
            fontSize: 20.sp * Provider.of<ThemeOperations>(context).getTextScaleFactor(context),
            fontWeight: FontWeight.bold,
            fontFamilyFallback: const ['Roboto']),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: Colors.grey[200], // TextField arka plan rengi
      hintStyle: const TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20.0.r),
      ),
      // TextField hint metni rengi
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.teal, width: 2.0.w),
        borderRadius: BorderRadius.circular(20.0.r), // Odaklanınca kenarlık rengi
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(storeOperations.lightMainColorValue), // Düğme rengi
      textTheme: ButtonTextTheme.primary, // Düğme yazı rengi
    ),
  );
}
