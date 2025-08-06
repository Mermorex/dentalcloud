class Procedure {
  final int id;
  final String name;
  final double price;
  final String? description;

  Procedure({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  factory Procedure.fromJson(Map<String, dynamic> json) {
    return Procedure(
      id: json['id'],
      name: json['name'],
      price: json['price'].toDouble(),
      description: json['description'],
    );
  }
}
