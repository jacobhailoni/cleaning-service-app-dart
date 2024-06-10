import 'package:firebase_database/firebase_database.dart';

class Service {
  final String id;
  late String name;
  late String description;
  final String image_url;
  final Map<String, dynamic> bookingOptions;
  final Map<String, dynamic> addons;

  Service({
    required this.id,
    required this.image_url,
    required this.bookingOptions,
    required this.addons,
  });

  factory Service.fromSnapshot(Map<String, dynamic> data, String languageCode) {
    return Service(
      id: data['id'],
      image_url: data['image_url'],
      bookingOptions: data['bookingOptions'],
      addons: data['addons'],
    )..setLocalizedContent(data, languageCode);
  }

  void setLocalizedContent(Map<String, dynamic> data, String languageCode) {
    if (languageCode == 'ar' && data.containsKey('name_ar')) {
      name = data['name_ar'];
      description = data['description_ar'];
    } else {
      name = data['name_en'];
      description = data['description_en'];
    }
  }

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
