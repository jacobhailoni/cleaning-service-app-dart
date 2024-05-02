class Service {
  final int id;
  final String name;
  final String description;
  final String image_url;
  final Map<String, dynamic> bookingOptions;
  final Map<String, dynamic> addons;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.image_url,
    required this.bookingOptions,
    required this.addons,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': image_url,
      'bookingOptions': bookingOptions,
      'addons': addons,
    };
  }
}
