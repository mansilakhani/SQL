import 'dart:typed_data';

class Student {
  int? id;
  final String name;
  final String age;
  final String city;
  final Uint8List image;

  Student({
    this.id,
    required this.name,
    required this.age,
    required this.city,
    required this.image,
  });

  factory Student.fromMap(Map<String, dynamic> data) {
    return Student(
      id: data['id'],
      name: data['name'],
      age: data['age'],
      city: data['city'],
      image: data['image'],
    );
  }
}
