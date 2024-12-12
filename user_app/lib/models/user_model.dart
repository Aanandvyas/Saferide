import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Assuming you have the UserModel class defined like this:
class UserModel {
  String? phone;
  String? name;
  String? email;
  String? id;
  String? address;

  UserModel({this.phone, this.name, this.email, this.id, this.address});

  // Factory constructor to create a UserModel from Firebase DataSnapshot
  UserModel.fromSnapshot(DataSnapshot snap) {
    phone = (snap.value as dynamic)["phone"];
    name = (snap.value as dynamic)["name"];
    email = (snap.value as dynamic)["email"];
    id = snap.key;
    address = (snap.value as dynamic)["address"];
  }
}

Future<void> fetchUserInfo() async {
  // Fetch the current authenticated user
  User? firebaseUser = FirebaseAuth.instance.currentUser;

  if (firebaseUser != null) {
    // Use the UID of the authenticated user to fetch additional user data
    DatabaseReference userRef = FirebaseDatabase.instance.ref('users/${firebaseUser.uid}');

    // Fetch the user data from the database
    DataSnapshot snapshot = await userRef.get();

    if (snapshot.exists) {
      // Create a UserModel instance from the fetched data
      UserModel userModelCurrentInfo = UserModel.fromSnapshot(snapshot);
      print('User info fetched: ${userModelCurrentInfo.name}');
      
      // You can now use userModelCurrentInfo wherever required
    } else {
      print('No user data found in database');
    }
  } else {
    print('No user is logged in');
  }
}
