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
  final String? firstName, lastName;
  final String? dni;         
  final String? cellphone; 

  SignupWithEmailAndPasswordEvent({
    required this.emailAddress,
    required this.password,
    this.firstName = 'Anonymous',
    this.lastName = 'User',
    required this.dni,               
    required this.cellphone,      
  });
}

class LogoutEvent extends AuthenticationEvent {}

class FinishedOnBoardingEvent extends AuthenticationEvent {}

class CheckFirstRunEvent extends AuthenticationEvent {}