import 'package:firebase_database/firebase_database.dart';

class User {
  String? fullName;
  String? email;
  String? phone;
  String? id;

  User({
    this.fullName,
    this.email,
    this.phone,
    this.id,
  });

  User.fromSnapsot(DataSnapshot snapshot) {
    id = snapshot.key;
    phone = (snapshot.value as dynamic)['phone'];
    email = (snapshot.value as dynamic)['email'];
    fullName = (snapshot.value as dynamic)['fullname'];
  }
}
