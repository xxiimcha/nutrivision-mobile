class Client {
  String? id; // Changed _id to a public id field
  String? guardian;
  String? address;
  String? name;
  String? dob;
  String? gender;
  String? height;
  String? weight;
  String? dateOfWeighing;
  String? weightForAge;
  String? heightForAge;
  String? weightForHeight;
  String? nutritionStatus;
  int? ageInMonths;
  String? userId;

  Client({
    this.id, // Public id field
    this.guardian,
    this.address,
    this.name,
    this.dob,
    this.gender,
    this.height,
    this.weight,
    this.dateOfWeighing,
    this.weightForAge,
    this.heightForAge,
    this.weightForHeight,
    this.nutritionStatus,
    this.ageInMonths,
    this.userId,
  });

  // Factory constructor to create a Client from JSON
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['_id'], // Use id as public field
      guardian: json['guardian'],
      address: json['address'],
      name: json['name'],
      dob: json['dob'],
      gender: json['gender'],
      height: json['height'],
      weight: json['weight'],
      dateOfWeighing: json['dateOfWeighing'],
      weightForAge: json['weightForAge'],
      heightForAge: json['heightForAge'],
      weightForHeight: json['weightForHeight'],
      nutritionStatus: json['nutritionStatus'],
      ageInMonths: json['ageInMonths'],
      userId: json['userId'],
    );
  }

  // Method to convert a Client object to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id, // Add id to JSON object
      'guardian': guardian,
      'address': address,
      'name': name,
      'dob': dob,
      'gender': gender,
      'height': height,
      'weight': weight,
      'dateOfWeighing': dateOfWeighing,
      'weightForAge': weightForAge,
      'heightForAge': heightForAge,
      'weightForHeight': weightForHeight,
      'nutritionStatus': nutritionStatus,
      'ageInMonths': ageInMonths,
      'userId': userId,
    };
  }
}
