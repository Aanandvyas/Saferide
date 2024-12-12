import 'package:driver_app/authentication/SubscriptiionPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CarInfoScreen extends StatefulWidget {
  const CarInfoScreen({super.key});

  @override
  State<CarInfoScreen> createState() => _CarInfoScreenState();
}

class _CarInfoScreenState extends State<CarInfoScreen> {
  final _carModelController = TextEditingController();
  final _carNumberController = TextEditingController();
  final _carColorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  List<String> carTypes = ["Car", "CNG", "Bike"];
  String? selectedCarType;

  void _submit() {
    if (_formKey.currentState!.validate() && selectedCarType != null) {
      final carInfo = {
        "car_model": _carModelController.text.trim(),
        "car_number": _carNumberController.text.trim(),
        "car_color": _carColorController.text.trim(),
        "car_type": selectedCarType,
      };

      final driverId = FirebaseAuth.instance.currentUser?.uid;
      if (driverId != null) {
        DatabaseReference ref = FirebaseDatabase.instance
            .ref()
            .child("drivers/$driverId/car_details");
        ref.set(carInfo).then((_) {
          Fluttertoast.showToast(msg: "Car details updated successfully");
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SubscriptionPage()),
          );
        }).catchError((error) {
          Fluttertoast.showToast(msg: "Error: $error");
        });
      } else {
        Fluttertoast.showToast(msg: "User not logged in");
      }
    } else if (selectedCarType == null) {
      Fluttertoast.showToast(msg: "Please select a car type");
    }
  }

  @override
  void dispose() {
    _carModelController.dispose();
    _carNumberController.dispose();
    _carColorController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(icon, color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(40),
          borderSide: BorderSide.none,
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 249, 246, 222),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_taxi,
                        size: 120.0,
                        color: Color(0xFFFFD600), // Bright yellow taxi icon
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Add Your Car Details",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Complete your profile to start driving!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  hintText: "Car Model",
                  icon: Icons.directions_car,
                  controller: _carModelController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Car model is required";
                    }
                    if (value.length < 2) {
                      return "Car model must be at least 2 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: "Car Number",
                  icon: Icons.numbers,
                  controller: _carNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Car number is required";
                    }
                    if (value.length < 2) {
                      return "Car number must be at least 2 characters";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  hintText: "Car Color",
                  icon: Icons.color_lens,
                  controller: _carColorController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Car color is required";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedCarType,
                  decoration: InputDecoration(
                    hintText: "Select Car Type",
                    prefixIcon:
                        const Icon(Icons.car_rental, color: Colors.black),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: carTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(
                              type,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCarType = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? "Please select a car type" : null,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD600), // Bright yellow
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
