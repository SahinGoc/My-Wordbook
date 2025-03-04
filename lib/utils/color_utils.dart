import 'package:flutter/material.dart';

class ColorUtils {

  static Color getOptimalTextColor(BuildContext context, Color backgroundColor) {
    // Tema renklerini al
    Color primaryColor = Theme.of(context).primaryColor;
    Color scaffoldBackgroundColor = Theme.of(context).scaffoldBackgroundColor;

    // Kontrast oranını hesaplayan bir fonksiyon
    double getContrastRatio(Color color1, Color color2) {
      double luminance1 = color1.computeLuminance();
      double luminance2 = color2.computeLuminance();

      return luminance1 > luminance2
          ? luminance1 / luminance2
          : luminance2 / luminance1;
    }

    // Varsayılan renkler
    Color lightText = Colors.white;
    Color darkText = Colors.black;

    // Kontrast oranı eşik değeri
    const double contrastThreshold = 1.0094;

    // Primary renk ile kontrast
    double contrastWithPrimary =
    getContrastRatio(backgroundColor, primaryColor);

    // Scaffold rengi ile kontrast
    double contrastWithScaffold =
    getContrastRatio(backgroundColor, scaffoldBackgroundColor);

    // Eğer primary ile kontrast yeterliyse onu döndür
    if (contrastWithPrimary >= contrastThreshold) {
      return primaryColor;
    }

    // Eğer scaffold ile kontrast yeterliyse onu döndür
    if (contrastWithScaffold >= contrastThreshold) {
      return scaffoldBackgroundColor;
    }

    // İkisi de yeterli kontrast sağlamıyorsa siyah ya da beyaz döndür
    return backgroundColor.computeLuminance() > 0.5 ? darkText : lightText;
  }

  static Color getContrastingTextColor(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color getContainerColor(Color color, BuildContext context) {
    double luminance = color.computeLuminance();
    return luminance > 0.5
        ? adjustColor(Theme.of(context).primaryColor, 0.05, true)
        : adjustColor(Theme.of(context).scaffoldBackgroundColor, 0.5, true);
  }

  static Color adjustColor(Color color, double factor, bool adjustAlpha) {
    int red = (color.r * 255 * factor).clamp(0, 255).toInt();
    int green = (color.g * 255 * factor).clamp(0, 255).toInt();
    int blue = (color.b * 255 * factor).clamp(0, 255).toInt();
    int alpha = (color.a * 255 * factor).clamp(0, 255).toInt();

    if (adjustAlpha) {
      return Color.fromARGB(alpha, red, green, blue);
    } else {
      return Color.fromARGB((color.a * 255).toInt(), red, green, blue);
    }
  }

  static Color generateColorFromIndex(Color color, double index) {
    HSVColor primaryHsv = HSVColor.fromColor(color);

    // Indexe göre küçük sapmalar ekle
    double hue =
        (primaryHsv.hue + (index * 7)) % 360; // 360'ı geçmemesi için mod al
    double saturation = (primaryHsv.saturation * 0.8) +
        (index % 5) * 0.04; // Doygunluğu hafifçe değiştir
    double value = (primaryHsv.value * 0.9) +
        (index % 3) * 0.03; // Parlaklığı hafifçe değiştir

    // HSV'den tekrar Color'a dönüştür
    return HSVColor.fromAHSV(primaryHsv.alpha, hue, saturation.clamp(0.0, 1.0),
        value.clamp(0.0, 1.0))
        .toColor();
  }

  static Color getSnackBarTextColor(BuildContext context) {
    return ColorUtils.getContrastingTextColor(
        ColorUtils.getContrastingTextColor(Theme.of(context).scaffoldBackgroundColor));
  }

  static adjustDoubleToIntColorValue(Color color) {
    int alpha = (color.a * 255).round();
    int red = (color.r * 255).round();
    int green = (color.g * 255).round();
    int blue = (color.b * 255).round();
    int colorValue = (alpha << 24) | (red << 16) | (green << 8) | blue;
    return colorValue;
  }
}