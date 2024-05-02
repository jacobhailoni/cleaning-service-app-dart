import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String id;
  final String code;
  final double discountPercentage;

  Coupon({
    required this.id,
    required this.code,
    required this.discountPercentage,
  });

  factory Coupon.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Coupon(
      id: doc.id,
      code: data['code'] ?? '',
      discountPercentage: (data['discountPercentage'] ?? 0.0).toDouble(),
    );
  }
}
