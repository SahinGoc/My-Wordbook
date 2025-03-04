class Item {
  int? id;
  String name;
  int price;
  int? code;
  bool isPurchased;
  int subcategoryId;

  Item(
      {this.id,
      required this.name,
      required this.price,
      this.isPurchased = false,
      this.code,
      this.subcategoryId = -1});

  factory Item.fromMap(Map<String, dynamic> json) {
    return Item(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      code: json['code'] ?? 0,
      isPurchased: json['isPurchased'] == 1,
      subcategoryId: json['subcategoryId'] ?? -1,
    );
  }

  // Dönüşüm metodu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'code': code,
      'isPurchased': isPurchased ? 1 : 0,
      'subcategoryId': subcategoryId
    };
  }
}

class Subcategory {
  int id;
  String name;
  List<Item> items;

  Subcategory({required this.id, required this.name, required this.items});

  // Dönüşüm metodu
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory Subcategory.fromMap(Map<String, dynamic> map) {
    return Subcategory(
      id: map['id'],
      name: map['name'],
      items:
          (map['items'] as List?)?.map((item) => Item.fromMap(item)).toList() ??
              [],
    );
  }
}

class Category {
  String name;
  List<Subcategory>? subcategories; // Renkler için
  List<Item>? items; // Fontlar için

  Category({required this.name, this.subcategories, this.items});

  // Dönüşüm metodu
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      name: map['name'],
      subcategories: (map['subcategories'] as List?)
          ?.map((subcategory) => Subcategory.fromMap(subcategory))
          .toList(),
      items: (map['items'] as List?)
          ?.map((item) => Item.fromMap(item))
          .toList(),
    );
  }
}
