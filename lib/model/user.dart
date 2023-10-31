import 'dart:io';

class User {
  String email;
  String firstName;
  String lastName;
  String userID;
  String profilePictureURL;
  String appIdentifier;
  String cellphone;
  String dni;

  User({
    this.email = '',
    this.firstName = '',
    this.lastName = '',
    this.userID = '',
    this.profilePictureURL = '',
    this.cellphone = '',
    this.dni = '',
  }) : appIdentifier = 'appEmergencia login';

  String fullName() => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
      email: parsedJson['email'] ?? '',
      firstName: parsedJson['firstName'] ?? '',
      lastName: parsedJson['lastName'] ?? '',
      userID: parsedJson['id'] ?? parsedJson['userID'] ?? '',
      cellphone: parsedJson['cellphone'] ?? '',
      dni: parsedJson['dni'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'id': userID,
      'appIdentifier': appIdentifier,
      'cellphone': cellphone,
      'dni': dni, 
    };
  }
}
