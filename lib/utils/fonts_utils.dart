import 'package:flutter_screenutil/flutter_screenutil.dart';

class FontsUtils {
  static double getFontScaleFactor(String fontFamily) {
    double baseFactor;
    switch (fontFamily) {
      case 'Roboto':
        baseFactor = 1.0;
        break;
      case 'Open Sans':
        baseFactor = 0.95;
        break;
      case 'Oswald':
        baseFactor = 0.85;
        break;
      case 'Montserrat':
        baseFactor = 1.05;
        break;
      case 'Poppins':
        baseFactor = 1.0;
        break;
      case 'Raleway':
        baseFactor = 1.05;
        break;
      case 'Merriweather':
        baseFactor = 1.0;
        break;
      case 'Source Sans 3':
        baseFactor = 0.9;
        break;
      case 'Playfair Display':
        baseFactor = 0.85;
        break;
      case 'Noto Sans':
        baseFactor = 1.0;
        break;
      case 'Nunito':
        baseFactor = 1.0;
        break;
      case 'Quicksand':
        baseFactor = 0.95;
        break;
      case 'Rubik':
        baseFactor = 1.0;
        break;
      case 'Inconsolata':
        baseFactor = 0.8;
        break;
      case 'Fira Sans':
        baseFactor = 0.95;
        break;
      case 'Lobster':
        baseFactor = 1.05;
        break;
      case 'Abril Fatface':
        baseFactor = 0.85;
      case 'Pacifico':
        baseFactor = 1.05;
        break;
      case 'Titillium Web':
        baseFactor = 1.0;
        break;
      case 'Bebas Neue':
        baseFactor = 0.75;
        break;
      case 'Indie Flower':
        baseFactor = 1.0;
        break;
      case 'Exo 2':
        baseFactor = 0.9;
        break;
      case 'Dosis':
        baseFactor = 1.0;
        break;
      case 'Cabin':
        baseFactor = 1.0;
        break;
      case 'Karla':
        baseFactor = 0.95;
        break;
      case 'Rokkitt':
        baseFactor = 1.0;
        break;
      case 'Zilla Slab':
        baseFactor = 0.95;
        break;
      case 'Overpass':
        baseFactor = 1.0;
        break;
      case 'Josefin Sans':
        baseFactor = 0.9;
        break;
      case 'Asap':
        baseFactor = 1.0;
        break;
      case 'Manrope':
        baseFactor = 1.0;
        break;
      case 'Mulish':
        baseFactor = 0.95;
        break;
      case 'PT Sans':
        baseFactor = 1.0;
        break;
      case 'Amatic SC':
        baseFactor = 1.05;
        break;
      case 'Barlow':
        baseFactor = 1.0;
        break;
      case 'Yanone Kaffeesatz':
        baseFactor = 1.0;
        break;
      case 'Sarabun':
        baseFactor = 1.0;
        break;
      case 'Teko':
        baseFactor = 1.05;
        break;
      case 'Spectral':
        baseFactor = 1.0;
        break;
      case 'Courgette':
        baseFactor = 1.0;
        break;
      case 'Crimson Text':
        baseFactor = 1.0;
        break;
      case 'Ubuntu':
        baseFactor = 1.0;
        break;
      case 'Varela Round':
        baseFactor = 1.0;
        break;
      case 'Baloo 2':
        baseFactor = 1.0;
        break;
      case 'Archivo':
        baseFactor = 1.0;
        break;
      case 'Work Sans':
        baseFactor = 1.0;
        break;
      case 'Merriweather Sans':
        baseFactor = 1.0;
        break;
      case 'Play':
        baseFactor = 1.05;
        break;
      case 'Comfortaa':
        baseFactor = 1.05;
        break;
      case 'Gloria Hallelujah':
        baseFactor = 1.05;
        break;
      case 'Anton':
        baseFactor = 0.75;
        break;
      case 'Bitter':
        baseFactor = 1.0;
        break;
      case 'Assistant':
        baseFactor = 1.0;
        break;
      case 'Balsamiq Sans':
        baseFactor = 1.0;
        break;
      case 'Caveat':
        baseFactor = 1.0;
        break;
      case 'Comfortaa':
        baseFactor = 1.05;
        break;
      case 'Gloria Hallelujah':
        baseFactor = 1.05;
        break;
      case 'Indie Flower':
        baseFactor = 1.0;
        break;
      case 'Josefin Sans':
        baseFactor = 0.9;
        break;
      case 'Lobster':
        baseFactor = 1.05;
        break;
      case 'Pacifico':
        baseFactor = 1.05;
        break;
      case 'Pinyon Script':
        baseFactor = 1.0;
        break;
      case 'Quicksand':
        baseFactor = 0.95;
        break;
      case 'Righteous':
        baseFactor = 1.05;
        break;
      case 'Shadows Into Light':
        baseFactor = 1.0;
        break;
      case 'Varela Round':
        baseFactor = 1.0;
        break;
      case 'Alatsi':
        baseFactor = 1.0;
        break;
      case 'Baloo Bhai 2':
        baseFactor = 1.0;
        break;
      case 'Fredoka':
        baseFactor = 1.0;
        break;
      case 'Great Vibes':
        baseFactor = 1.05;
        break;
      case 'Italianno':
        baseFactor = 1.0;
        break;
      case 'Kaushan Script':
        baseFactor = 1.0;
        break;
      case 'Love Ya Like A Sister':
        baseFactor = 1.0;
        break;
      case 'Monoton':
        baseFactor = 0.8;
        break;
      case 'Poiret One':
        baseFactor = 1.0;
        break;
      case 'Press Start 2P':
        baseFactor = 0.75;
        break;
      case 'Special Elite':
        baseFactor = 0.9;
        break;
      case 'Zeyada':
        baseFactor = 1.28;
        break;
      default:
        baseFactor = 1.0;
        break;
    }

    double screenWidthFactor = ScreenUtil().screenWidth / 393;
    return baseFactor * screenWidthFactor;
  }
}
