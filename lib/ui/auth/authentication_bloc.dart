import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/model/user.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  User? user;
  final storage = FlutterSecureStorage();
  late bool finishedOnBoarding;

  AuthenticationBloc({this.user})
      : super(const AuthenticationState.unauthenticated()) {
    on<CheckFirstRunEvent>((event, emit) async {
      String? finishedOnBoardingStr = await storage.read(key: FINISHED_ON_BOARDING);
      finishedOnBoarding = finishedOnBoardingStr == 'true';
      if (!finishedOnBoarding) {
        emit(const AuthenticationState.onboarding());
      } else {
        Map<String, String>? credentialsAndToken = await getCredentialsAndToken();
        if (credentialsAndToken != null && credentialsAndToken['token'] != null) {
          String email = credentialsAndToken['email']!;
          String password = credentialsAndToken['password']!;
          dynamic result = await loginWithAPI(email, password);
          if (result != null && result is String && result != 'false') {
            user = User(email: email); 
            emit(AuthenticationState.authenticated(user!)); 
          } else {
            emit(const AuthenticationState.unauthenticated()); 
          }
        } else {
          emit(const AuthenticationState.unauthenticated()); 
        }
      }
    });

    on<FinishedOnBoardingEvent>((event, emit) async {
      await storage.write(key: FINISHED_ON_BOARDING, value: 'true');
      emit(const AuthenticationState.unauthenticated());
    });

    on<SignupWithEmailAndPasswordEvent>((event, emit) async {
      dynamic result = await registerWithAPI(
        '${event.firstName} ${event.lastName!}',
        event.emailAddress,
        event.password,
        event.cellphone!,
        event.dni!,
      );

      if (result != null && result is String) {
        await setCredentialsAndToken(
            event.emailAddress, event.password, result);
        user = User(email: event.emailAddress);
        emit(AuthenticationState.authenticated(user!));
      } else {
        emit(AuthenticationState.unauthenticated(
            message: result is String
                ? 'No se pudo registrar, vuelva a intentar.'
                : 'No se pudo registrar, vuelva a intentar.'));
      }
    });

    on<LoginWithEmailAndPasswordEvent>((event, emit) async {
      Map<String, String>? credentialsAndToken = await getCredentialsAndToken();
      String? bearerToken = credentialsAndToken?['token'];

      dynamic result =
          await loginWithAPI(event.email, event.password, bearerToken);
      if (result != null && result is String && result != 'false')  {
        await setOperationToken(result);
        user = User(email: event.email);
        emit(AuthenticationState.authenticated(user!));
      } else {
        emit(AuthenticationState.unauthenticated(
            message: result is String
                ? 'Fallo el inicio, Por favor vuelva a intentarlo.'
                : 'Fallo el inicio, Por favor vuelva a intentarlo.'));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await removeCredentials();
      await storage.delete(key: FINISHED_ON_BOARDING); 
      user = null;
      emit(const AuthenticationState.unauthenticated());
    });
  }

  Future<dynamic> loginWithAPI(String email, String password,
      [String? bearerToken]) async {
    final uri =
        Uri.parse('https://appemergencias.regionloreto.gob.pe/api/login');
    final request = http.MultipartRequest('POST', uri)
      ..fields['email'] = email
      ..fields['password'] = password;
    if (bearerToken != null) {
      request.headers['Authorization'] = 'Bearer $bearerToken';
    }
    final response = await http.Response.fromStream(await request.send());

    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse.containsKey('access_token')) {
      final operationToken = jsonResponse['access_token'];
      await setOperationToken(operationToken);
      user = User(email: email);
      return operationToken;
    } else {
      try {
        final error = 'false';
        return error;
      } catch (e) {
        return 'false';
      }
    }
  }

  Future<dynamic> registerWithAPI(String name, String email, String password,
      String celular, String dni) async {
    final uri =
        Uri.parse('https://appemergencias.regionloreto.gob.pe/api/register');
    final request = http.MultipartRequest('POST', uri);
    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;
    request.fields['celular'] = celular;
    request.fields['dni'] = dni;

    final response = await http.Response.fromStream(await request.send());

    Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (jsonResponse.containsKey('access_token')) {
      final token = jsonResponse['access_token'];
      await setCredentialsAndToken(email, password, token);
      user = User(email: email);
      return token;
    } else {
      try {
        final error = jsonResponse['message'] ?? 'Error inesperado.';
        return error;
      } catch (e) {
        return 'Error inesperado.';
      }
    }
  }

  Future<void> setCredentialsAndToken(
      String email, String password, String token) async {
    await storage.write(key: 'email', value: email);
    await storage.write(key: 'password', value: password);
    await storage.write(key: 'access_token', value: token);
  }

  Future<void> setOperationToken(String operationToken) async {
    await storage.write(key: 'operation_token', value: operationToken);
  }

  Future<Map<String, String>?> getCredentialsAndToken() async {
    String? email = await storage.read(key: 'email');
    String? password = await storage.read(key: 'password');
    String? token = await storage.read(key: 'access_token');
    if (email != null && password != null && token != null) {
      return {'email': email, 'password': password, 'token': token};
    }
    return null;
  }

  Future<void> removeCredentials() async {
    await storage.delete(key: 'email');
    await storage.delete(key: 'password');
    await storage.delete(key: 'access_token');
  }

  Future<void> removeOperationToken() async {
    await storage.delete(key: 'operation_token');
  }
}
