class MenuModel {
  int menuId;
  String menuName;
  String menuDescription;
  String menuImageUrl;
  double menuPrice;

  MenuModel({
    required this.menuId,
    required this.menuName,
    required this.menuDescription,
    required this.menuImageUrl,
    required this.menuPrice,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    double price;
    var priceValue = json['menuPrice'];

    if (priceValue is num) {
      price = priceValue.toDouble();
    } else {
      price = double.tryParse(priceValue.toString()) ?? 0.0;
    }

    return MenuModel(
      menuId: json['menuId'] ?? 0,
      menuName: json['menuName'] ?? 'Unknown Menu',
      menuDescription: json['menuDescription'] ?? 'No Description',
      menuImageUrl:
          json['menuImageUrl'] ?? 'cake_icon.png',
      menuPrice: price,
    );
  }
}
