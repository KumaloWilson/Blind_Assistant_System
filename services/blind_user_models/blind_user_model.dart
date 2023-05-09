import 'package:firebase_database/firebase_database.dart';

class BlindUserModel {
  String? phone;
  String? name;
  String? id;
  String? email;
  String? ageRange;

  BlindUserModel({
    this.phone,
    this.name,
    this.id,
    this.email,
    this.ageRange
  });

  BlindUserModel.fromSnapShot(DataSnapshot snap){
    phone =(snap.value as dynamic)["phone"];
    name =(snap.value as dynamic)["name"];
    id = snap.key;
    email =(snap.value as dynamic)["email"];
    ageRange=(snap.value as dynamic)["age"];
  }
}