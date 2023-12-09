import 'package:app_emergen/localization/localized_strings.dart';
import 'package:app_emergen/ui/auth/signUp/sign_up_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/services/helper.dart';
import 'package:app_emergen/ui/auth/authentication_bloc.dart';
import 'package:app_emergen/ui/auth/login/login_bloc.dart';
//import 'package:app_emergen/ui/auth/resetPasswordScreen/reset_password_screen.dart';
import 'package:app_emergen/ui/home/home_screen.dart';
import 'package:app_emergen/ui/loading_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State createState() {
    return _LoginScreen();
  }
}

class _LoginScreen extends State<LoginScreen> {
  final GlobalKey<FormState> _key = GlobalKey();
  AutovalidateMode _validate = AutovalidateMode.disabled;
  String? email, password;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LoginBloc>(
      create: (context) => LoginBloc(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
              color: isDarkMode(context) ? Colors.white : Colors.black),
            elevation: 0.0,
          ),
          body: MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  context.read<LoadingCubit>().hideLoading();
                  if (state.authState == AuthState.authenticated) {
                    pushAndRemoveUntil(
                        context, HomeScreen(user: state.user!), false);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message ?? LocalizedStrings.of(context).loginFailed)),
                    );
                  }
                },
              ),
              BlocListener<LoginBloc, LoginState>(
                listener: (context, state) {
                  if (state is ValidLoginFields) {
                    context.read<LoadingCubit>().showLoading(
                        context, LocalizedStrings.of(context).loginAwait, false);
                    context.read<AuthenticationBloc>().add(
                          LoginWithEmailAndPasswordEvent(
                            email: email!,
                            password: password!,
                          ),
                        );
                  }
                },
              ),
            ],
            child: BlocBuilder<LoginBloc, LoginState>(
              buildWhen: (old, current) =>
                  current is LoginFailureState && old != current,
              builder: (context, state) {
                if (state is LoginFailureState) {
                  _validate = AutovalidateMode.onUserInteraction;
                }
                return Form(
                  key: _key,
                  autovalidateMode: _validate,
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset(
                          'assets/images/login_image.png',
                          width: 250.0,
                          height: 250.0,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.0, left: 16.0),
                        child: Text(
                          LocalizedStrings.of(context).loginTitle,
                          style: TextStyle(
                            color: Color(COLOR_PRIMARY),
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 16.0, left: 16.0),
                        child: Text(
                          LocalizedStrings.of(context).loginSubtitle,
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15, right: 16.0, left: 16.0
                        ),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          textInputAction: TextInputAction.next,
                          validator: validateEmail,
                          onSaved: ( String? val ) {
                            email = val;
                          },
                          style: const TextStyle(fontSize: 18.0),
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: const Color(COLOR_PRIMARY),
                          decoration: getInputDecoration(
                            hint: LocalizedStrings.of(context).loginEmail,
                            darkMode: isDarkMode(context),
                            icon: Icons.email,
                            errorColor: Theme.of(context).colorScheme.error
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 15.0, right: 16.0, left: 16.0
                        ),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          obscureText: true,
                          validator: validatePassword,
                          onSaved: (String? val) {
                            password = val;
                          },
                          onFieldSubmitted: (password) => context
                              .read<LoginBloc>()
                              .add(ValidateLoginFieldsEvent(_key)),
                          textInputAction: TextInputAction.done,
                          style: const TextStyle(fontSize: 18.0),
                          cursorColor: const Color(COLOR_PRIMARY),
                          decoration: getInputDecoration(
                            hint: LocalizedStrings.of(context).loginPasswd,
                            darkMode: isDarkMode(context),
                            icon: Icons.password,
                            errorColor: Theme.of(context).colorScheme.error
                          )
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 16),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            child: Text(  LocalizedStrings.of(context).loginForgotPw,
                              style: TextStyle(
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                letterSpacing: 1
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 16.0, left: 16.0, top: 10
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(top: 18, bottom: 18), backgroundColor: const Color(COLOR_PRIMARY),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular( 8.0 ),
                              side: const BorderSide(
                                color: Color(COLOR_PRIMARY),
                              ),
                            ),
                          ),
                          child: Text(
                            LocalizedStrings.of(context).loginButton,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          onPressed: () => context
                              .read<LoginBloc>()
                              .add(ValidateLoginFieldsEvent(_key)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10, right: 16),
                        child: Align(
                          alignment: Alignment.center,
                          child: GestureDetector(
                            child: GestureDetector(
                            onTap: () {
                              // Lógica de navegación para llevar al usuario a la pantalla de registro
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: ( context ) => SignUpScreen(), // Reemplaza con tu pantalla de registro
                              ));
                            },
                            child: Text(  LocalizedStrings.of(context).loginToSignUp,
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}
