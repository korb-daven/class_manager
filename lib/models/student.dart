class Student {
  int? id;
  String name, email, phone, className, department, gender, dateRegistered;
  bool present;

  Student({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.className,
    required this.department,
    required this.gender,
    required this.dateRegistered,
    this.present = false,
  });

  factory Student.fromMap(Map<String, dynamic> json) => Student(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    className: json['className'],
    department: json['department'],
    gender: json['gender'],
    dateRegistered: json['dateRegistered'],
    present: json['present'] == 1,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'className': className,
    'department': department,
    'gender': gender,
    'dateRegistered': dateRegistered,
    'present': present ? 1 : 0,
  };
}
