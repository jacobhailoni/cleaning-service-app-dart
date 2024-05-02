import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tophservices/models/coupon_model.dart';

class BookingDetailsBloc {
  late StreamController<List<Coupon>> _couponsController;
  Stream<List<Coupon>> get couponsStream => _couponsController.stream;

  BookingDetailsBloc() {
    _couponsController = StreamController<List<Coupon>>.broadcast();
  }

  void dispose() {
    _couponsController.close();
  }

  void fetchCoupons() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('coupons').get();

      List<Coupon> coupons =
          querySnapshot.docs.map((doc) => Coupon.fromFirestore(doc)).toList();

      _couponsController.sink.add(coupons);
    } catch (e) {
      _couponsController.addError(e);
    }
  }
}
