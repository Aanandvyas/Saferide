import 'package:driver_app/global/global_var.dart';
import 'package:driver_app/models/driver_data.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  DriverData? driverData;
  File? _profileImage;
  File? _carDocument;

  @override
  void initState() {
    super.initState();
    fetchDriverDetails();
  }

  // Fetch driver details from Firebase
  Future<void> fetchDriverDetails() async {
    try {
      final userId = currentUser!.uid; // Replace with actual driver ID logic
      DatabaseReference driverRef =
          FirebaseDatabase.instance.ref().child("drivers").child(userId);

      DataSnapshot snapshot = await driverRef.get();

      if (snapshot.exists && snapshot.value != null) {
        print("Fetched Driver Data: ${snapshot.value}");
        final Map<dynamic, dynamic> data =
            snapshot.value as Map<dynamic, dynamic>;

        setState(() {
          driverData = DriverData(
            id: snapshot.key,
            name: data["name"] as String?,
            phone: data["phone"] as String?,
            email: data["email"] as String?,
            address: data["address"] as String?,
            car_color: data["car_details"]?["car_color"] as String?,
            car_model: data["car_details"]?["car_model"] as String?,
            car_number: data["car_details"]?["car_number"] as String?,
            ratings: data["ratings"] as String?,
            car_type: data["car_details"]?["car_type"] as String?,
          );
        });
      } else {
        print("Driver data not found.");
        Fluttertoast.showToast(msg: "Driver data not found.");
      }
    } catch (e) {
      print("Error fetching data: $e");
      Fluttertoast.showToast(msg: "Error fetching data: $e");
    }
  }

  // Pick an image from gallery
  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
      Fluttertoast.showToast(msg: "Profile photo updated!");
    }
  }

  // Pick a car document PDF
  Future<void> pickCarDocument() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedDocument =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedDocument != null) {
      setState(() {
        _carDocument = File(pickedDocument.path);
      });
      Fluttertoast.showToast(msg: "Car document uploaded!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return driverData == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Driver Avatar with Edit Button
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : const AssetImage('assets/images/avatarman.png')
                                as ImageProvider,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: pickImage,
                          child: const CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.blue,
                            child: Icon(
                              Icons.edit,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Driver Name
                  Text(
                    driverData?.name ?? "N/A",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Driver Ratings
                  Text(
                    "Ratings: ${driverData?.ratings ?? 'N/A'}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Driver Details
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow("Email", driverData?.email),
                          _buildInfoRow("Phone", driverData?.phone),
                          _buildInfoRow("Address", driverData?.address),
                          _buildInfoRow("Car Model", driverData?.car_model),
                          _buildInfoRow("Car Color", driverData?.car_color),
                          _buildInfoRow("Car Number", driverData?.car_number),
                          _buildInfoRow("Car Type", driverData?.car_type),
                          _buildInfoRow("Aadhaar Number", "Not provided"),
                          _buildInfoRow("Driver License", "Not provided"),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Upload Car Document
                  ElevatedButton.icon(
                    onPressed: pickCarDocument,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload Car Documents"),
                  ),
                  const SizedBox(height: 20),
                  // Verification Notice in Hindi
                  const Text(
                    "\u0938\u092d\u0940 \u092a\u0924\u094d\u0930 \u092a\u0942\u0930\u094d\u0923 \u0915\u0930\u0947\u0902 \u0924\u093e\u0915\u093f \u0935\u0947\u0930\u093f\u092b\u093e\u0908\u0921 \u0914\u0930 \u092a\u094d\u0930\u0940\u092e\u093f\u092f\u092e \u0906\u0915\u093e\u0909\u0902\u091f \u0936\u0941\u0930\u0942 \u0915\u0930 \u0938\u0915\u0947\u0902!",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? "N/A",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}