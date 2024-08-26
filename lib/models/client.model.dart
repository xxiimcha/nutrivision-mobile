class Client {
  final String address;
  final String guardian;
  final String name;
  final String dob;
  final String gender;
  final String height;
  final String weight;
  final String dateOfWeighing;
  final String weightForAge;
  final String heightForAge;
  final String weightForHeight;
  final String nutritionStatus;
  final int ageInMonths;
  final String userId; // Add the new field for userId

  Client({
    required this.address,
    required this.guardian,
    required this.name,
    required this.dob,
    required this.gender,
    required this.height,
    required this.weight,
    required this.dateOfWeighing,
    required this.weightForAge,
    required this.heightForAge,
    required this.weightForHeight,
    required this.nutritionStatus,
    required this.ageInMonths,
    required this.userId, // Include in the constructor
  });

  Map<String, dynamic> toJson() => {
    'address': address,
    'guardian': guardian,
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
    'userId': userId, // Include in the JSON serialization
  };
}
