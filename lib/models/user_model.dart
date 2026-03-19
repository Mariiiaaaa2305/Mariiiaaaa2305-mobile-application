class UserModel {
  final String fullName;
  final String carPlate;
  final String carBrand; 
  final String carModel; 
  final String email;
  final String password;

  UserModel({
    required this.fullName,
    required this.carPlate,
    required this.carBrand,
    required this.carModel,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'fullName': fullName,
    'carPlate': carPlate,
    'carBrand': carBrand,
    'carModel': carModel,
    'email': email,
    'password': password,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    fullName: json['fullName'],
    carPlate: json['carPlate'],
    carBrand: json['carBrand'] ?? 'Tesla', 
    carModel: json['carModel'] ?? 'Model 3',
    email: json['email'],
    password: json['password'],
  );
}