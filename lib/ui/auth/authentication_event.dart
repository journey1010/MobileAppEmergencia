part of 'authentication_bloc.dart';

abstract class AuthenticationEvent {}

class LoginWithEmailAndPasswordEvent extends AuthenticationEvent {
  final String email;
  final String password;

  LoginWithEmailAndPasswordEvent({required this.email, required this.password});
}

class SignupWithEmailAndPasswordEvent extends AuthenticationEvent {
  final String emailAddress;
  final String password;
  final File? image;
  final String? firstName, lastName;
  final String? dni;         
  final String? cellphone; 

  SignupWithEmailAndPasswordEvent({
    required this.emailAddress,
    required this.password,
    this.image,
    this.firstName = 'Anonymous',
    this.lastName = 'User',
    this.dni,               
    this.cellphone,      
  });
}

class LogoutEvent extends AuthenticationEvent {}

class FinishedOnBoardingEvent extends AuthenticationEvent {}

class CheckFirstRunEvent extends AuthenticationEvent {}