class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  // In a real app, this would be a URL or asset path
  final String imageEmoji;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageEmoji,
  });

  static const List<Product> mockProducts = [
    Product(
      id: 'p1',
      name: 'Wireless Headphones',
      price: 5.99,
      description: 'High quality sound with noise cancellation.',
      imageEmoji: '🎧',
    ),
    Product(
      id: 'p2',
      name: 'Smart Watch',
      price: 9.50,
      description: 'Track your fitness and notifications.',
      imageEmoji: '⌚',
    ),
    Product(
      id: 'p3',
      name: 'Running Shoes',
      price: 5.00,
      description: 'Comfortable shoes for long distance running.',
      imageEmoji: '👟',
    ),
    Product(
      id: 'p4',
      name: 'Laptop Backpack',
      price: 4.00,
      description: 'Water resistant backpack fits 15" laptops.',
      imageEmoji: '🎒',
    ),
    Product(
      id: 'p5',
      name: 'Sunglasses',
      price: 2.00,
      description: 'UV protection with stylish frames.',
      imageEmoji: '🕶️',
    ),
    Product(
      id: 'p6',
      name: 'Gaming Mouse',
      price: 3.99,
      description: 'Ergonomic design for gamers.',
      imageEmoji: '🖱️',
    ),
  ];
}
