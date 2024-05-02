import 'package:cloud_firestore/cloud_firestore.dart';

void createBookingCollection() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference bookings = firestore.collection('bookings');

  // Create the collection and fields
  await bookings.add({
    'userId': 'user123', // Example user ID
    'serviceName': 'Cleaning', // Example service name
    'date': Timestamp.now(),
    'time': {'hour': 10, 'minute': 30},
    'hours': 2.5,
    'maidsCount': 2,
    'withMaterials': true,
    'totalPrice': 50.0,
  });
}
