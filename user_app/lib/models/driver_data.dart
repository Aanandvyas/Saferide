class DriverData {
  String? id;
  String? name;
  String? phone;
  String? email;
  String? car_model;
  String? car_number;
  String? car_type;

  DriverData({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.car_model,
    this.car_number,
    this.car_type,
  });

  DriverData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        phone = json['phone'],
        email = json['email'],
        car_model = json['car_model'],
        car_number = json['car_number'],
        car_type = json['car_type'];
}
