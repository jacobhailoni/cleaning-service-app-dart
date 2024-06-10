class BookingLocation {
  final String location;
  final String buildingNumber;
  final String apartmentNumber;
  final String administrativeArea;

  BookingLocation({
    required this.location,
    required this.buildingNumber,
    required this.apartmentNumber,
    required this.administrativeArea,
  });

  // Factory method to create BookingLocation from a map
  factory BookingLocation.fromMap(Map<String, dynamic> map) {
    return BookingLocation(
      location: map['location'] ?? '',
      buildingNumber: map['buildingNumber'] ?? '',
      apartmentNumber: map['apartmentNumber'] ?? '',
      administrativeArea: map['administrativeArea'] ?? '', // New field
    );
  }

  // Serialize the BookingLocation object to a Map
  Map<String, dynamic> toMap() {
    return {
      'location': location,
      'buildingNumber': buildingNumber,
      'apartmentNumber': apartmentNumber,
      'administrativeArea': administrativeArea, // New field
    };
  }

  factory BookingLocation.fromJson(Map<String, dynamic> json) {
    return BookingLocation(
      location: json['location'] ?? '',
      buildingNumber: json['buildingNumber'] ?? '',
      apartmentNumber: json['apartmentNumber'] ?? '',
      administrativeArea: json['administrativeArea'] ?? '',
    );
  }
}
