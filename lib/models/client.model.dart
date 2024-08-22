class Client {
  int id;
  final String name;
  final String guardian;
  final String address;
  final String age;
  final String height;
  final String gender;
  final String weight;
  final String actualDate;
  final bool indigenousChild;

  Client({
    this.id = 0,
    this.name = '',
    this.guardian = '',
    this.address = '',
    this.age = '',
    this.height = '',
    this.gender = '',
    this.weight = '',
    this.actualDate = '',
    this.indigenousChild = false,
  });

  // Convert Client model to Json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'guardian': guardian,
      'address': address,
      'age': age,
      'height': height,
      'gender': gender,
      'weight': weight,
      'actualDate': actualDate,
      'indigenousChild': indigenousChild,
    };
  }

  // Convert Json to Client model
  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      guardian: json['guardian'] ?? '',
      age: json['age'] ?? '',
      height: json['height'] ?? '',
      gender: json['gender'] ?? '',
      weight: json['weight'] ?? '',
      actualDate: json['actualDate'] ?? '',
      indigenousChild: json['indigenousChild'] ?? false,
    );
  }

  @override
  String toString() {
    return 'Client{id: $id, name: $name, guardian: $guardian, address: $address, age: $age, height: $height, gender: $gender, weight: $weight, actualDate: $actualDate, indigenousChild: $indigenousChild}';
  }
}
