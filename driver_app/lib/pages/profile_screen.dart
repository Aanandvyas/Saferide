import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameTextEditingController = TextEditingController();
  final phoneTextEditingController = TextEditingController();
  final addressTextEditingController = TextEditingController();

  final DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  String userName = "N/A";
  String userPhone = "N/A";
  String userAddress = "N/A";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    String uid = firebaseAuth.currentUser?.uid ?? "";

    if (uid.isNotEmpty) {
      userRef.child(uid).once().then((snapshot) {
        if (snapshot.snapshot.value != null) {
          Map data = snapshot.snapshot.value as Map;
          setState(() {
            userName = data['name'] ?? "N/A";
            userPhone = data['phone'] ?? "N/A";
            userAddress = data['address'] ?? "N/A";
          });
        }
      }).catchError((error) {
        Fluttertoast.showToast(msg: "Error loading data: $error");
      });
    } else {
      Fluttertoast.showToast(msg: "User not logged in");
    }
  }

  Future<void> showUserDialogAlert({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required String fieldKey,
    required String currentValue,
  }) async {
    controller.text = currentValue;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextFormField(
            controller: controller,
            decoration: InputDecoration(labelText: "Enter new $title"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                String uid = firebaseAuth.currentUser!.uid;
                userRef.child(uid).update({
                  fieldKey: controller.text.trim(),
                }).then((value) {
                  Fluttertoast.showToast(msg: "$title updated successfully.");
                  setState(() {
                    if (fieldKey == "name") userName = controller.text.trim();
                    if (fieldKey == "phone") userPhone = controller.text.trim();
                    if (fieldKey == "address") userAddress = controller.text.trim();
                  });
                  Navigator.pop(context);
                }).catchError((errorMessage) {
                  Fluttertoast.showToast(msg: "Error occurred: $errorMessage");
                });
              },
              child: const Text("Save", style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Profile"),
          backgroundColor: darkTheme ? Colors.black : Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                CircleAvatar(
                  radius: 50,
                  backgroundColor: darkTheme ? Colors.amber : Colors.blue,
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 20),

                // Name
                buildEditableField(
                  context,
                  title: "Name",
                  value: userName,
                  onEdit: () => showUserDialogAlert(
                    context: context,
                    title: "Name",
                    controller: nameTextEditingController,
                    fieldKey: "name",
                    currentValue: userName,
                  ),
                ),

                // Phone
                buildEditableField(
                  context,
                  title: "Phone",
                  value: userPhone,
                  onEdit: () => showUserDialogAlert(
                    context: context,
                    title: "Phone",
                    controller: phoneTextEditingController,
                    fieldKey: "phone",
                    currentValue: userPhone,
                  ),
                ),

                // Address
                buildEditableField(
                  context,
                  title: "Address",
                  value: userAddress,
                  onEdit: () => showUserDialogAlert(
                    context: context,
                    title: "Address",
                    controller: addressTextEditingController,
                    fieldKey: "address",
                    currentValue: userAddress,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildEditableField(BuildContext context,
      {required String title, required String value, required VoidCallback onEdit}) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                "$title: $value",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
            ),
          ],
        ),
        const Divider(thickness: 1),
      ],
    );
  }
}
