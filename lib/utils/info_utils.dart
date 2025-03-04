import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InfoUtils {
  static void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black.withAlpha(180),
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  //İnternet bağlantısı kontrol
  static void checkConnection(BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (context.mounted) {
      if (connectivityResult.contains(ConnectivityResult.mobile)) {
        Navigator.pushNamed(context, '/online_translator');
        InfoUtils.showToast('Mobil veri ile bağlantı var!');
      } else if (connectivityResult.contains(ConnectivityResult.wifi)) {
        Navigator.pushNamed(context, '/online_translator');
        InfoUtils.showToast('Wi-Fi ile bağlantı var!');
      } else {
        InfoUtils.showToast('İnternet bağlantısı yok!');
      }
    }
  }
}