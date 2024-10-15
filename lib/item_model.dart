class Item {
  String name;
  int quantity;

  Item(this.name, this.quantity);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
    };
  }

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      json['name'],
      json['quantity'],
    );
  }
}
