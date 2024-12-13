# SafeRide: Smart Cab Booking with Enhanced Safety Features 🚖

## Project Description

**SafeRide** is an innovative cab booking app built with **Flutter** for a seamless and intuitive user interface. It connects riders and drivers efficiently through **Firebase** for authentication, real-time database management, and Firebase Cloud Messaging. The app integrates a **Python-based backend** to handle real-time driver-user requests, ensuring a smooth and dynamic experience.

With **Safety at its Core**, SafeRide includes features like:

- 🚨 **Emergency Call**: One-touch access to emergency contacts for added security.
- 📍 **Live Location Sharing**: Share your ride’s live location with loved ones in real-time.
- 🚗 **Rash Driving Detection**: Monitor and alert users about potential rash driving behavior.

## Key Features

- **Real-time Rider & Driver Matchmaking** using Firebase Realtime Database.
- **Intuitive UI/UX** developed with Flutter, ensuring a smooth experience on both Android & iOS.
- **Enhanced User Authentication** with Firebase Authentication.
- **Safety Features** like emergency calls, live location tracking, and rash driving detection.
- **Location-based Matching** with **Google Maps API** and **Geolocator** integration for accurate pickup/dropoff locations.
- **Push Notifications** via Firebase Cloud Messaging for ride updates.

## Tech Stack

- **Frontend**: Flutter, Firebase, Google Maps API
- **Backend**: Python (for handling requests and processing logic)
- **Safety Features**: Emergency call functionality, live location sharing, and rash driving detection

## Development Tools

- **VS Code** for development
- **Android Studio** as the emulator for testing and debugging

SafeRide is the future of smart, safe, and reliable ride-sharing! 🌟

## Acknowledgements

We would like to extend our heartfelt gratitude to all those who contributed to the development of **SafeRide**:

- **Our Professors and Mentors** for their invaluable guidance and support throughout the project. Their feedback and expertise helped shape the app’s core functionality and safety features.
  
- **The Flutter and Firebase Communities** for providing comprehensive documentation, tutorials, and solutions to common challenges, making the development process smoother and faster.

- **Python Developers** whose backend solutions and libraries helped us integrate efficient and scalable functionality into the app.

- **Google Maps API** for enabling accurate location services and routing capabilities, crucial for real-time tracking.

- **Firebase** for offering seamless authentication, database management, and push notifications, making the app scalable and user-friendly.

- **Our Friends and Family** for their continuous encouragement, testing, and feedback on the app’s features, helping us refine the user experience.

- **The Open-Source Community** for various libraries and dependencies that powered the app, such as `flutter_geofire`, `smooth_star_rating`, `flutter_polyline_points`, and many more.

Thank you to everyone who made **SafeRide** a reality. Your contributions are greatly appreciated! 🙏🚀

## API References for **SafeRide**

Here are the key APIs used in **SafeRide**, including Firebase, Google Maps, and the custom Python backend:

---

### 1. Firebase Realtime Database API

- **Firebase Realtime Database** allows us to store and sync data between users in real-time. We use it for storing ride details, user profiles, and driver statuses.
- **Reference**: [Firebase Realtime Database Documentation](https://firebase.google.com/docs/database)

**Common Methods**:
- `firebase.database().ref('path/to/data').set(data)`: Set data at a specific path.
- `firebase.database().ref('path/to/data').on('value', callback)`: Listen for real-time updates at a path.
- `firebase.database().ref('path/to/data').push(data)`: Add new data to the database.
- `firebase.database().ref('path/to/data').remove()`: Remove data from the database.

---

### 2. Firebase Authentication API

- **Firebase Authentication** handles user sign-up, login, and authentication.
- **Reference**: [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)

**Common Methods**:
- `firebase.auth().signInWithEmailAndPassword(email, password)`: Sign in an existing user.
- `firebase.auth().createUserWithEmailAndPassword(email, password)`: Register a new user.
- `firebase.auth().signOut()`: Sign the user out.

---

### 3. Firebase Cloud Messaging (FCM)

- **Firebase Cloud Messaging** allows sending push notifications to users.
- **Reference**: [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)

**Common Methods**:
- `firebase.messaging().getToken()`: Retrieve the FCM token for push notifications.
- `firebase.messaging().onMessage(callback)`: Handle foreground messages (notifications while app is open).
- `firebase.messaging().setBackgroundMessageHandler(callback)`: Handle background messages (when the app is in the background or terminated).

---

### 4. Google Maps API

- **Google Maps API** is used for displaying maps, geolocation, and route planning (driver/rider matching and live location tracking).
- **Reference**: [Google Maps SDK for Flutter](https://pub.dev/packages/google_maps_flutter)

**Common Methods**:
- `GoogleMap()`: Widget to display the map.
- `GoogleMapController.animateCamera()`: Animate the camera (for example, move to the user’s location).
- `Geolocator.getCurrentPosition()`: Get the user’s current location.
- `Geolocator.getPositionStream()`: Stream real-time location updates.

---

### 5. Geolocator API

- **Geolocator** is used for retrieving the current location of the user or driver and tracking changes in location.
- **Reference**: [Geolocator Plugin Documentation](https://pub.dev/packages/geolocator)

**Common Methods**:
- `Geolocator.getCurrentPosition()`: Get the current position of the user.
- `Geolocator.getPositionStream()`: Get real-time location updates.
- `Geolocator.isLocationServiceEnabled()`: Check if location services are enabled.

---

### 6. Python Backend API (Custom Backend)

- The Python backend uses **Flask** or **FastAPI** for creating REST APIs to handle requests like booking rides, processing payments, and updating driver statuses.

**Example Endpoints**:
- `POST /api/ride/request`: Accept a ride request from the user and save it to the Firebase database.
- `GET /api/ride/driver-status`: Get the status of the nearest available driver for the user.
- `POST /api/ride/cancel`: Cancel a ride and update the ride status in the database.

**Python Libraries Used**:
- **Flask/FastAPI**: Framework for building REST APIs.
- **Firebase Admin SDK**: Used to interact with Firebase from the backend (e.g., storing/retrieving data, sending notifications).

**References**:
- [Flask Documentation](https://flask.palletsprojects.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Firebase Admin SDK for Python](https://firebase.google.com/docs/admin/setup)

---

### 7. Rash Driving Detection API (Custom Logic)

- The rash driving detection uses the device’s accelerometer and gyroscope sensors to detect erratic movements, such as sudden acceleration or hard braking, which may indicate rash driving.
- **Technologies**:
  - **Sensors Plugin**: `sensors_plus` package is used to access device sensors (accelerometer, gyroscope).
  - **Machine Learning**: You can integrate a model for anomaly detection that analyzes the sensor data to predict rash driving behavior.

**Reference**: [sensors_plus Flutter Plugin](https://pub.dev/packages/sensors_plus)

---

## Conclusion

These APIs power the core functionalities of **SafeRide**, including real-time ride tracking, user authentication, push notifications, location services, and backend processing. By leveraging these tools, we can provide a seamless and secure experience for both drivers and riders.

---

## SnapShots

![WhatsApp Image 2024-12-12 at 00 56 32_bfc58414](https://github.com/user-attachments/assets/75731d5d-99c1-4e74-bac1-777d485f495f)
![WhatsApp Image 2024-12-12 at 00 59 27_6d126249](https://github.com/user-attachments/assets/be368e81-bc42-4f19-8429-a52822243052)
![WhatsApp Image 2024-12-12 at 01 01 02_7fd41447](https://github.com/user-attachments/assets/dfad8723-5a59-4680-895c-01155a7d5d26)
![WhatsApp Image 2024-12-12 at 01 05 24_0db24a66](https://github.com/user-attachments/assets/d543f2d1-c745-469d-8325-87bf91e5a3f4)
![WhatsApp Image 2024-12-12 at 01 05 24_5c0c7a7a](https://github.com/user-attachments/assets/39267ada-66e4-4e3c-a60d-420ef6de81dc)
![WhatsApp Image 2024-12-12 at 01 10 46_16bbc96d](https://github.com/user-attachments/assets/bd87dec1-c407-4d17-b6d1-d98af561d739)

## Setting Up SafeRide Locally

To run **SafeRide** locally, follow these steps to set up the environment and run both the **Flutter frontend** and **Python backend** locally. Make sure you have the required software installed, such as Flutter, Python, and Firebase.

### 1. Set Up the Development Environment

#### 1.1 Install Flutter
If you don't already have Flutter installed, you can follow these instructions to set it up:
- [Flutter installation guide](https://flutter.dev/docs/get-started/install)

Run the following command to verify the installation:
```bash
flutter doctor
