import 'package:my_wordbook/db/store_helper.dart';
import 'package:my_wordbook/models/store.dart';

class StoreRepository {
  final StoreHelper _storeHelper = StoreHelper();

  // Kategorileri al
  Future<List<Category>> getCategories() async {
    return await _storeHelper.getCategories();
  }

  // Alt kategorileri al
  Future<List<Subcategory>> getSubcategories(int categoryId) async {
    return await _storeHelper.getSubcategories(categoryId);
  }

  // Renkleri al
  Future<List<Item>> getColorsItems(int subcategoryId) async {
    return await _storeHelper.getColorsItems(subcategoryId);
  }

  // Fontları al
  Future<List<Item>> getFontsItems() async {
    return await _storeHelper.getFontsItems();
  }

  // Ürünü satın al
  Future<void> purchaseItem(int itemId, int subcategory) async {
    await _storeHelper.purchaseItem(itemId, subcategory);
  }

  Future<void> insertMainCategories() async {
    await _storeHelper.insertMainCategories();
  }

  Future<void> insertColors() async {
    await _storeHelper.insertColors();
  }

  Future<void> insertFonts() async {
    await _storeHelper.insertFonts();
  }
}
