import firebase_admin
from firebase_admin import credentials, firestore, messaging
from flask import Flask, request, jsonify

# Initialize Firebase Admin SDK
cred = credentials.Certificate("C:/Users/LENOVO/Documents/flutter project/service-account-key.json")  # Replace with the actual path
firebase_admin.initialize_app(cred)

# Initialize Firestore DB
db = firestore.client()

app = Flask(__name__)

@app.route('/send_ride_request', methods=['POST'])
def send_ride_request():
    """Send a ride request to all available drivers."""
    try:
        # Parse input data
        data = request.get_json()
        origin = data['origin']
        destination = data['destination']
        user_id = data['user_id']

        # Add ride request to Firestore
        ride_request_ref = db.collection('ride_requests').add({
            'origin': origin,
            'destination': destination,
            'user_id': user_id,
            'status': 'waiting',
            'driver_id': None,
        })
        ride_request_id = ride_request_ref[1].id

        # Fetch all available drivers
        drivers = db.collection('drivers').where('newRideStatus', '==', 'idle').stream()
        tokens = [driver.to_dict().get('token') for driver in drivers if 'token' in driver.to_dict()]

        # Send notifications to available drivers
        if tokens:
            message = messaging.MulticastMessage(
                notification=messaging.Notification(
                    title='New Ride Request',
                    body=f'Ride request from {origin} to {destination}',
                ),
                data={'ride_request_id': ride_request_id},
                tokens=tokens
            )
            response = messaging.send_multicast(message)
            print(f'Notifications sent: {response.success_count} success, {response.failure_count} failure')

        return jsonify({'message': 'Ride request sent successfully', 'ride_request_id': ride_request_id})

    except Exception as e:
        print(f"Error in send_ride_request: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/update_ride_status', methods=['POST'])
def update_ride_status():
    """Update ride status by driver."""
    try:
        # Parse input data
        data = request.get_json()
        ride_request_id = data['ride_request_id']
        driver_id = data['driver_id']

        # Update ride request in Firestore
        db.collection('ride_requests').document(ride_request_id).update({
            'status': 'accepted',
            'driver_id': driver_id,
        })

        # Notify the user about the ride acceptance
        ride_request = db.collection('ride_requests').document(ride_request_id).get().to_dict()
        user_ref = db.collection('users').document(ride_request['user_id']).get()
        user_data = user_ref.to_dict()

        if 'token' in user_data:
            message = messaging.Message(
                notification=messaging.Notification(
                    title='Ride Accepted',
                    body=f'Driver {driver_id} has accepted your ride request',
                ),
                token=user_data['token']
            )
            messaging.send(message)

        return jsonify({'message': 'Ride status updated successfully'})

    except Exception as e:
        print(f"Error in update_ride_status: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/get_ride_status/<ride_request_id>', methods=['GET'])
def get_ride_status(ride_request_id):
    """Get the current status of a ride request."""
    try:
        ride_request = db.collection('ride_requests').document(ride_request_id).get()
        if not ride_request.exists:
            return jsonify({'error': 'Ride request not found'}), 404

        return jsonify(ride_request.to_dict())

    except Exception as e:
        print(f"Error in get_ride_status: {e}")
        return jsonify({'error': str(e)}), 500


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
