### Project Title:
🚖 **SafeRide: Smart Cab Booking with Enhanced Safety Features** 🚖

### Project Description:
**SafeRide** is an innovative cab booking app built with **Flutter** for a seamless and intuitive user interface. It connects riders and drivers efficiently through **Firebase** for authentication, real-time database management, and Firebase Cloud Messaging. The app integrates a **Python-based backend** to handle real-time driver-user requests, ensuring a smooth and dynamic experience.

With **Safety at its Core**, SafeRide includes features like:

- 🚨 **Emergency Call**: One-touch access to emergency contacts for added security.
- 📍 **Live Location Sharing**: Share your ride’s live location with loved ones in real-time.
- 🚗 **Rash Driving Detection**: Monitor and alert users about potential rash driving behavior.

### Key Features:
- **Real-time Rider & Driver Matchmaking** using Firebase Realtime Database
- **Intuitive UI/UX** developed with Flutter, ensuring a smooth experience on both Android & iOS.
- **Enhanced User Authentication** with Firebase Authentication
- **Safety Features** like emergency calls, live location tracking, and rash driving detection.
- **Location-based Matching** with **Google Maps API** and **Geolocator** integration for accurate pickup/dropoff locations.
- **Push Notifications** via Firebase Cloud Messaging for ride updates.

### Tech Stack:
- **Frontend**: Flutter, Firebase, Google Maps API
- **Backend**: Python (for handling requests and processing logic)
- **Safety Features**: Emergency call functionality, live location sharing, and rash driving detection

### Development Tools:
- **VS Code** for development
- **Android Studio** as the emulator for testing and debugging

SafeRide is the future of smart, safe, and reliable ride-sharing! 🌟### Acknowledgements

We would like to extend our heartfelt gratitude to all those who contributed to the development of **SafeRide**:

- **Our Professors and Mentors** for their invaluable guidance and support throughout the project. Their feedback and expertise helped shape the app’s core functionality and safety features.
  
- **The Flutter and Firebase Communities** for providing comprehensive documentation, tutorials, and solutions to common challenges, making the development process smoother and faster.

- **Python Developers** whose backend solutions and libraries helped us integrate efficient and scalable functionality into the app.

- **Google Maps API** for enabling accurate location services and routing capabilities, crucial for real-time tracking.

- **Firebase** for offering seamless authentication, database management, and push notifications, making the app scalable and user-friendly.

- **Our Friends and Family** for their continuous encouragement, testing, and feedback on the app’s features, helping us refine the user experience.

- **The Open-Source Community** for various libraries and dependencies that powered the app, such as `flutter_geofire`, `smooth_star_rating`, `flutter_polyline_points`, and many more.


Thank you to everyone who made **SafeRide** a reality. Your contributions are greatly appreciated! 🙏🚀### API References for **SafeRide**

Here are the key APIs used in **SafeRide**, including Firebase, Google Maps, and the custom Python backend:

---

#### 1. **Firebase Realtime Database API**:
   - **Firebase Realtime Database** allows us to store and sync data between users in real-time. We use it for storing ride details, user profiles, and driver statuses.
   - **Reference**: [Firebase Realtime Database Documentation](https://firebase.google.com/docs/database)

   - **Common Methods**:
     - `firebase.database().ref('path/to/data').set(data)`: Set data at a specific path.
     - `firebase.database().ref('path/to/data').on('value', callback)`: Listen for real-time updates at a path.
     - `firebase.database().ref('path/to/data').push(data)`: Add new data to the database.
     - `firebase.database().ref('path/to/data').remove()`: Remove data from the database.

---

#### 2. **Firebase Authentication API**:
   - **Firebase Authentication** handles user sign-up, login, and authentication.
   - **Reference**: [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)

   - **Common Methods**:
     - `firebase.auth().signInWithEmailAndPassword(email, password)`: Sign in an existing user.
     - `firebase.auth().createUserWithEmailAndPassword(email, password)`: Register a new user.
     - `firebase.auth().signOut()`: Sign the user out.

---

#### 3. **Firebase Cloud Messaging (FCM)**:
   - **Firebase Cloud Messaging** allows sending push notifications to users.
   - **Reference**: [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)

   - **Common Methods**:
     - `firebase.messaging().getToken()`: Retrieve the FCM token for push notifications.
     - `firebase.messaging().onMessage(callback)`: Handle foreground messages (notifications while app is open).
     - `firebase.messaging().setBackgroundMessageHandler(callback)`: Handle background messages (when the app is in the background or terminated).

---

#### 4. **Google Maps API**:
   - **Google Maps API** is used for displaying maps, geolocation, and route planning (driver/rider matching and live location tracking).
   - **Reference**: [Google Maps SDK for Flutter](https://pub.dev/packages/google_maps_flutter)
   
   - **Common Methods**:
     - `GoogleMap()`: Widget to display the map.
     - `GoogleMapController.animateCamera()`: Animate the camera (for example, move to the user’s location).
     - `Geolocator.getCurrentPosition()`: Get the user’s current location.
     - `Geolocator.getPositionStream()`: Stream real-time location updates.

---

#### 5. **Geolocator API**:
   - **Geolocator** is used for retrieving the current location of the user or driver and tracking changes in location.
   - **Reference**: [Geolocator Plugin Documentation](https://pub.dev/packages/geolocator)

   - **Common Methods**:
     - `Geolocator.getCurrentPosition()`: Get the current position of the user.
     - `Geolocator.getPositionStream()`: Get real-time location updates.
     - `Geolocator.isLocationServiceEnabled()`: Check if location services are enabled.

---

#### 6. **Python Backend API** (Custom Backend):
   - The Python backend uses **Flask** or **FastAPI** for creating REST APIs to handle requests like booking rides, processing payments, and updating driver statuses.
   
   - **Example Endpoints**:
     - `POST /api/ride/request`: Accept a ride request from the user and save it to the Firebase database.
     - `GET /api/ride/driver-status`: Get the status of the nearest available driver for the user.
     - `POST /api/ride/cancel`: Cancel a ride and update the ride status in the database.

   - **Python Libraries Used**:
     - **Flask/FastAPI**: Framework for building REST APIs.
     - **Firebase Admin SDK**: Used to interact with Firebase from the backend (e.g., storing/retrieving data, sending notifications).

   - **References**:
     - [Flask Documentation](https://flask.palletsprojects.com/)
     - [FastAPI Documentation](https://fastapi.tiangolo.com/)
     - [Firebase Admin SDK for Python](https://firebase.google.com/docs/admin/setup)

---

#### 7. **Rash Driving Detection API** (Custom Logic):
   - The rash driving detection uses the device’s accelerometer and gyroscope sensors to detect erratic movements, such as sudden acceleration or hard braking, which may indicate rash driving.
   - **Technologies**:
     - **Sensors Plugin**: `sensors_plus` package is used to access device sensors (accelerometer, gyroscope).
     - **Machine Learning**: You can integrate a model for anomaly detection that analyzes the sensor data to predict rash driving behavior.

   - **Reference**: [sensors_plus Flutter Plugin](https://pub.dev/packages/sensors_plus)

---

### Conclusion:
These APIs power the core functionalities of **SafeRide**, including real-time ride tracking, user authentication, push notifications, location services, and backend processing. By leveraging these tools, we can provide a seamless and secure experience for both drivers and riders.To run **SafeRide** locally, follow these steps to set up the environment and run both the **Flutter frontend** and **Python backend** locally. Make sure you have the required software installed, such as Flutter, Python, and Firebase. Here's a step-by-step guide:

---

### 1. **Set Up the Development Environment**

#### 1.1 Install Flutter
If you don't already have Flutter installed, you can follow these instructions to set it up:
- [Flutter installation guide](https://flutter.dev/docs/get-started/install)

Make sure to add Flutter to your system's PATH and run the following command to verify the installation:
```bash
flutter doctor
```

#### 1.2 Install Python and Flask/FastAPI
If you don't have Python installed, download it from [python.org](https://www.python.org/downloads/).

You can install Flask or FastAPI for the backend:
- For **Flask**:
  ```bash
  pip install Flask
  ```
- For **FastAPI**:
  ```bash
  pip install fastapi uvicorn
  ```

#### 1.3 Install Firebase CLI
If you haven't already, install Firebase CLI to work with Firebase locally:
- [Firebase CLI Setup](https://firebase.google.com/docs/cli)

Install it globally using npm:
```bash
npm install -g firebase-tools
```

### 2. **Set Up Firebase for Local Development**
To run Firebase locally, you'll use the Firebase Emulator Suite. Set up the Firebase Emulator for Authentication, Firestore, and Realtime Database:

#### 2.1 Initialize Firebase Project Locally
In your project directory, run:
```bash
firebase init
```
- Choose Firebase services you want to initialize (Authentication, Realtime Database, Firebase Functions, etc.).
- Configure the Firebase Emulator (select the services you need to emulate).
  
#### 2.2 Start Firebase Emulators
To start the Firebase emulators, run the following:
```bash
firebase emulators:start
```
This will start the local emulators for Realtime Database, Firestore, Authentication, and other Firebase services.

---

### 3. **Run the Flutter Frontend Locally**

#### 3.1 Set Up Firebase in Flutter
- Open your Flutter project in VS Code and ensure that you've added Firebase dependencies in your `pubspec.yaml` file. Here's an example:
  ```yaml
  dependencies:
    cupertino_icons: ^1.0.0
    firebase_core: ^1.10.0
    firebase_auth: ^4.0.0
    firebase_database: ^9.0.0
    firebase_storage: ^10.0.0
    firebase_messaging: ^11.0.0
    google_maps_flutter: ^2.1.0
    geolocator: ^8.0.0
    location: ^4.0.0
  ```

- Initialize Firebase in your app by modifying the `main.dart` file to ensure Firebase is initialized before the app starts:
  ```dart
  import 'package:firebase_core/firebase_core.dart';
  import 'package:flutter/material.dart';

  void main() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    runApp(MyApp());
  }
  ```

#### 3.2 Run the Flutter App
Once your Firebase setup is done and the emulator is running, you can run the app locally:
```bash
flutter run
```

Ensure your device (or emulator) is connected and running to view the app.

---

### 4. **Run the Python Backend Locally**

#### 4.1 Set Up the Backend (Flask/FastAPI)
- **Flask Example** (app.py):
  ```python
  from flask import Flask, request, jsonify
  import firebase_admin
  from firebase_admin import credentials, firestore

  app = Flask(__name__)

  # Initialize Firebase Admin SDK
  cred = credentials.Certificate('path/to/your/firebase-admin-sdk.json')
  firebase_admin.initialize_app(cred)

  db = firestore.client()

  @app.route('/api/ride/request', methods=['POST'])
  def create_ride():
      data = request.get_json()
      # Add ride details to Firestore or Realtime DB
      db.collection('rides').add(data)
      return jsonify({"message": "Ride request created!"}), 200

  if __name__ == '__main__':
      app.run(debug=True)
  ```

- **FastAPI Example** (main.py):
  ```python
  from fastapi import FastAPI
  from pydantic import BaseModel
  from firebase_admin import credentials, firestore, initialize_app

  # Firebase setup
  cred = credentials.Certificate("path/to/your/firebase-admin-sdk.json")
  initialize_app(cred)

  app = FastAPI()
  db = firestore.client()

  class RideRequest(BaseModel):
      user_id: str
      driver_id: str
      location: str
      status: str

  @app.post("/api/ride/request")
  async def create_ride(ride: RideRequest):
      db.collection('rides').add(ride.dict())
      return {"message": "Ride request created!"}

  if __name__ == "__main__":
      import uvicorn
      uvicorn.run(app, host="0.0.0.0", port=8000)
  ```

#### 4.2 Run the Backend Locally
- For **Flask**:
  ```bash
  python app.py
  ```

- For **FastAPI**:
  ```bash
  uvicorn main:app --reload
  ```

The Python backend should now be running on `http://127.0.0.1:5000` (Flask) or `http://127.0.0.1:8000` (FastAPI).

---

### 5. **Testing and Debugging Locally**
- **Testing Firebase Functions**: You can test Firebase functions locally by using the Firebase Emulator.
- **Test Backend API**: Use tools like Postman or Insomnia to send requests to your local Python backend API endpoints.

Example:
```bash
POST http://127.0.0.1:5000/api/ride/request
Content-Type: application/json
{
  "user_id": "123",
  "driver_id": "456",
  "location": "123 Main St",
  "status": "requested"
}
```

---

### 6. **Final Check**
- Ensure Firebase emulators are running in the terminal (`firebase emulators:start`).
- Make sure both your Flutter frontend and Python backend are properly connected to Firebase and are handling requests correctly.

Now you can run **SafeRide** locally on both the frontend and backend, test the functionalities, and make changes as needed before deploying to production!### Usage Example for **SafeRide** 🚖

Here’s a walkthrough of how to use **SafeRide** from a user’s perspective, including both the mobile app and backend API requests:

---

### **1. User Registration & Login**  
**Objective**: Sign up or log in to the app.

**Step-by-step**:
1. **Open the App**: Launch **SafeRide** on your device.
2. **Sign Up**: If you're a new user, tap on the **Sign Up** button. Enter your **email** and **password**, and submit.
   - Firebase Authentication handles the signup process and creates an account for you.
3. **Login**: If you're returning, tap on **Login**, enter your credentials, and proceed.

**Backend Request (Firebase Authentication)**:
- **POST Request to Firebase Authentication**:
  ```http
  POST https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=[API_KEY]
  Content-Type: application/json
  
  {
    "email": "user@example.com",
    "password": "securePassword123",
    "returnSecureToken": true
  }
  ```

---

### **2. Booking a Ride**  
**Objective**: Book a ride by providing pickup and drop-off locations.

**Step-by-step**:
1. **Enter Pickup & Drop-off Locations**: In the app, enter the **pickup address** and **drop-off address** in the search fields.
2. **View Driver Availability**: The app will display nearby available drivers on the map.
3. **Select a Driver**: Choose the driver you’d like to book from the available options. Confirm the ride by tapping **Book Ride**.

**Backend Request (Python)**:
- **POST Request to Python Backend** (Flask/FastAPI):
  ```http
  POST http://127.0.0.1:5000/api/ride/request
  Content-Type: application/json
  
  {
    "user_id": "123",
    "driver_id": "456",
    "pickup_location": "123 Main St",
    "dropoff_location": "456 Elm St",
    "status": "requested"
  }
  ```
  The backend stores this ride request in Firebase and notifies the driver.

---

### **3. Real-Time Ride Tracking**  
**Objective**: Track your ride’s location in real-time and receive updates.

**Step-by-step**:
1. **Start the Ride**: Once the driver accepts the ride, the **real-time tracking** starts.
2. **View Driver’s Location**: The map updates to show the driver’s current location, and the user can see the driver’s progress towards the pickup point.
3. **Notifications**: During the ride, the app sends **push notifications** (via Firebase Cloud Messaging) about ride status (e.g., "Driver on the way", "Ride completed").

**Backend (Python) Notification**:
- **Push Notification** (via Firebase Cloud Messaging):
  ```json
  {
    "to": "fcm_token_of_user",
    "notification": {
      "title": "Ride Status",
      "body": "Your driver is on the way!"
    }
  }
  ```
  The backend sends a message to Firebase Cloud Messaging to notify the user about the ride status.

---

### **4. Emergency Features**  
**Objective**: Use the emergency call feature during the ride.

**Step-by-step**:
1. **Activate Emergency Call**: In case of an emergency, tap the **Emergency Call** button.
2. **Call Emergency Services**: The app will initiate a phone call to local emergency services using the device’s dialer.

**Backend/Device Logic**:
- The device’s dialer is accessed using **Flutter’s `url_launcher`** package:
  ```dart
  launch("tel:112");  // Emergency number (e.g., 112 for Europe)
  ```

---

### **5. Rash Driving Detection**  
**Objective**: Detect and alert the driver in case of rash driving.

**Step-by-step**:
1. **Monitor Acceleration/Braking**: The app continuously monitors the driver’s **accelerometer** and **gyroscope** using the **sensors_plus** package.
2. **Detect Rash Driving**: If sudden acceleration or harsh braking is detected, the app issues an alert:
   - **UI Alert**: "Warning: Rash driving detected! Please drive safely."
   
**Backend (Python) Logic**:
- **Rash Driving Detection**: Python code processes sensor data and alerts the user when abnormal patterns are detected.

**Flutter Code Example** (detecting sudden acceleration):
```dart
import 'package:sensors_plus/sensors_plus.dart';

accelerometerEvents.listen((AccelerometerEvent event) {
  if (event.x > 5 || event.y > 5 || event.z > 5) {
    showAlert("Warning: Rash Driving Detected!");
  }
});
```

---

### **6. Ride Completion & Payment**  
**Objective**: Complete the ride and pay for it.

**Step-by-step**:
1. **Complete Ride**: Once you’ve reached your destination, the app will show a **Ride Completed** screen.
2. **Payment**: You can pay via integrated payment methods (e.g., **Stripe** or **Google Pay**).
3. **Rate the Driver**: After payment, you can rate your driver on a scale of 1-5 stars.

**Backend Request (Payment)**:
- **POST Request to Payment API**:
  ```http
  POST http://127.0.0.1:5000/api/ride/complete
  Content-Type: application/json
  
  {
    "user_id": "123",
    "driver_id": "456",
    "payment_status": "successful",
    "rating": 4
  }
  ```

---

### **7. User Logout**  
**Objective**: Log out from the app.

**Step-by-step**:
1. **Logout**: Tap the **Logout** button on the app’s profile screen.
2. **Firebase Authentication**: The app will sign out the user using Firebase Authentication.

**Backend Request (Firebase Authentication)**:
- **POST Request to Firebase**:
  ```http
  POST https://identitytoolkit.googleapis.com/v1/accounts:signOut?key=[API_KEY]
  ```
  This request logs out the user from the Firebase session.

---

### Conclusion
This usage flow demonstrates how **SafeRide** integrates multiple technologies, including **Flutter**, **Firebase**, and **Python**, to provide a seamless and efficient cab booking and safety experience. From registering and booking a ride to real-time tracking and safety features, **SafeRide** ensures that both drivers and passengers have a smooth and secure experience throughout the ride.