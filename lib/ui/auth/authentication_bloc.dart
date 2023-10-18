import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  User? user;
  late SharedPreferences prefs;
  late bool finishedOnBoarding;

  AuthenticationBloc({this.user})
      : super(const AuthenticationState.unauthenticated()) {
    on<CheckFirstRunEvent>((event, emit) async {
      prefs = await SharedPreferences.getInstance();
      finishedOnBoarding = prefs.getBool(FINISHED_ON_BOARDING) ?? false;
      if (!finishedOnBoarding) {
        emit(const AuthenticationState.onboarding());
      } else {
        String? token = await getToken();
        if (token == null) {
          emit(const AuthenticationState.unauthenticated());
        } else {
          emit(AuthenticationState.authenticated(user!));
        }
      }
    });

    on<FinishedOnBoardingEvent>((event, emit) async {
      await prefs.setBool(FINISHED_ON_BOARDING, true);
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
        await setToken(result);
        user = User(email: event.emailAddress);
        emit(AuthenticationState.authenticated(user!));
      } else {
        emit(AuthenticationState.unauthenticated(
            message: result is String ? result : 'No se pudo registrar, vuelva a intentar.'));
      }
    });

    on<LoginWithEmailAndPasswordEvent>((event, emit) async {
      dynamic result = await loginWithAPI(event.email, event.password);
      if (result != null && result is String) {
        await setToken(result);
        user = User(email: event.email);
        emit(AuthenticationState.authenticated(user!));
      } else {
        emit(AuthenticationState.unauthenticated(
            message: result is String
                ? result
                : 'Fallo el inicio, Por favor vuelva a intentarlo.'));
      }
    });

    on<LogoutEvent>((event, emit) async {
      await removeToken();
      user = null;
      emit(const AuthenticationState.unauthenticated());
    });
  }

  Future<dynamic> loginWithAPI(String email, String password) async {
    final uri = Uri.parse('https://appemergencias.regionloreto.gob.pe/api/login');
    final request = http.MultipartRequest('POST', uri);
    request.fields['email'] = email;
    request.fields['password'] = password;

    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse['access_token'];
    } else {
      try {
        final error = jsonDecode(response.body);
        return error['message'] ?? 'Error inesperado.';
      } catch (e) {
        return 'Error inesperado.';
      }
    }
  }

  Future<dynamic> registerWithAPI(String name, String email, String password, String celular, String dni) async {
    final uri = Uri.parse('https://appemergencias.regionloreto.gob.pe/api/register');
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
      await setToken(token);
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

  Future<void> setToken(String token) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', token);
  }

  Future<String?> getToken() async {
    prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> removeToken() async {
    prefs = await SharedPreferences.getInstance();
    prefs.remove('access_token');
  }
}
