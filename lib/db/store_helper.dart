import 'package:my_wordbook/models/store.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/store_data.dart';
import 'db_helper.dart';

class StoreHelper {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Category>> getCategories() async {
    final db = await _dbHelper.database;
    final maps = await db.query('categories');
    return List.generate(maps.length, (i) {
      return Category.fromMap(maps[i]);
    });
  }

  Future<List<Subcategory>> getSubcategories(int categoryId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('subcategories',
        where: 'categoryId = ?', whereArgs: [categoryId]);
    return List.generate(
      maps.length,
      (i) {
        return Subcategory.fromMap(maps[i]);
      }
    );
  }

  Future<List<Item>> getColorsItems(int subcategoryId) async {
    final db = await _dbHelper.database;
    final maps = await db
        .query('items', where: 'subcategoryId = ?', whereArgs: [subcategoryId]);
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<List<Item>> getFontsItems() async {
    final db = await _dbHelper.database;
    final maps =
        await db.query('items', where: 'subcategoryId = ?', whereArgs: [-1]);
    return List.generate(maps.length, (i) {
      return Item.fromMap(maps[i]);
    });
  }

  Future<void> purchaseItem(int itemId, int subcategory) async {
    final db = await _dbHelper.database;
    await db.update('items', {'isPurchased': 1},
        where: 'id = ? AND subcategoryId = ?',
        whereArgs: [itemId, subcategory]);
  }

  Future<void> insertMainCategories() async {
    final db = await _dbHelper.database;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isMainInitialized = prefs.getBool('isMainInitialized') ?? false;

    if (!isMainInitialized) {
      await db.insert('categories', {'id': 1, 'name': 'Renkler'});
      await db.insert('categories', {'id': 2, 'name': 'Fontlar'});
      debugPrint('iki ana kategori eklendi');
      await prefs.setBool('isMainInitialized', true);
    }
  }

  Future<void> insertColors() async {
    final db = await _dbHelper.database;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isColorsInitialized = prefs.getBool('isColorsInitialized') ?? false;

    if (!isColorsInitialized) {
      for (var category in categories) {
        // Alt kategoriler için
        if (category.subcategories != null) {
          for (var subcategory in category.subcategories!) {
            int subcategoryId = await db.insert('subcategories', {
              'name': subcategory.name,
              'categoryId': 1,
            });
            debugPrint('alt kategori eklendi');

            for (var item in subcategory.items) {
              await db.insert('items', {
                'name': item.name,
                'price': item.price,
                'code': item.code ?? 0,
                'subcategoryId': subcategoryId,
                'categoryId': 1,
              });
              debugPrint('item renk eklendi');
            }
          }
        }
      }
      await prefs.setBool('isColorsInitialized', true);
    }
  }

  Future<void> insertFonts() async {
    final db = await _dbHelper.database;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFontsInitialized = prefs.getBool('isFontsInitialized') ?? false;

    if (!isFontsInitialized) {
      for (var category in categories) {
        // Kategoriye ait ürünler için
        if (category.items != null) {
          for (var item in category.items!) {
            int isPrchsd = 0;
            if (item.isPurchased) {
              isPrchsd = 1;
            }
            await db.insert('items', {
              'name': item.name,
              'price': item.price,
              'code': item.code ?? 0,
              'isPurchased': isPrchsd,
              'subcategoryId': -1,
              'categoryId': 2,
            });
            debugPrint('font eklendi');
          }
        }
      }
      await prefs.setBool('isFontsInitialized', true);
    }
  }
}
