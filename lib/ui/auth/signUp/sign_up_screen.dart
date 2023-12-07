import 'package:app_emergen/localization/localized_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/services/helper.dart';
import 'package:app_emergen/ui/auth/authentication_bloc.dart';
import 'package:app_emergen/ui/auth/signUp/sign_up_bloc.dart';
import 'package:app_emergen/ui/home/home_screen.dart';
import 'package:app_emergen/ui/loading_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _key = GlobalKey();
  String? firstName, lastName, email, password, confirmPassword, dni, cellphone;
  AutovalidateMode _validate = AutovalidateMode.disabled;
  bool acceptEULA = false;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SignUpBloc>(
      create: (context) => SignUpBloc(),
      child: Builder(
        builder: (context) {
          return MultiBlocListener(
            listeners: [
              BlocListener<AuthenticationBloc, AuthenticationState>(
                listener: (context, state) {
                  context.read<LoadingCubit>().hideLoading();
                  if (state.authState == AuthState.authenticated) {
                    pushAndRemoveUntil(
                        context, HomeScreen(user: state.user!), false);
                  } else {
                    showSnackBar(
                        context,
                        state.message ?? LocalizedStrings.of(context).registerFailed );
                  }
                },
              ),
              BlocListener<SignUpBloc, SignUpState>(
                listener: (context, state) {
                  if (state is ValidFields) {
                    context.read<LoadingCubit>().showLoading(
                        context, LocalizedStrings.of(context).registerAwait , false);
                    context.read<AuthenticationBloc>().add(
                        SignupWithEmailAndPasswordEvent(
                            emailAddress: email!,
                            password: password!,
                            lastName: lastName,
                            firstName: firstName,
                            cellphone: cellphone,
                            dni: dni));
                  } else if (state is SignUpFailureState) {
                    showSnackBar(context, state.errorMessage);
                  }
                },
              ),
            ],
            child: Scaffold(
              appBar: AppBar(
                elevation: 0.0,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                    color: isDarkMode(context) ? Colors.white : Colors.black),
              ),
              body: SingleChildScrollView(
                padding:
                    const EdgeInsets.only(left: 16.0, right: 16, bottom: 16),
                child: BlocBuilder<SignUpBloc, SignUpState>(
                  buildWhen: (old, current) =>
                      current is SignUpFailureState && old != current,
                  builder: (context, state) {
                    if (state is SignUpFailureState) {
                      _validate = AutovalidateMode.onUserInteraction;
                    }
                    return Form(
                      key: _key,
                      autovalidateMode: _validate,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                           Text(
                            LocalizedStrings.of(context).registerTitle,
                            style: TextStyle(
                                color: Color(COLOR_PRIMARY),
                                fontWeight: FontWeight.bold,
                                fontSize: 25.0),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              validator: validateName,
                              onSaved: (String? val) {
                                firstName = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: LocalizedStrings.of(context).registerName,
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textCapitalization: TextCapitalization.words,
                              validator: validateName,
                              onSaved: (String? val) {
                                lastName = val;
                              },
                              textInputAction: TextInputAction.next,
                              decoration: getInputDecoration(
                                  hint: LocalizedStrings.of(context).registerLastname,
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: validateEmail,
                              onSaved: (String? val) {
                                email = val;
                              },
                              decoration: getInputDecoration(
                                  hint: LocalizedStrings.of(context).registerEmail,
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.text, 
                              textInputAction: TextInputAction.next,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return LocalizedStrings.of(context).registerDniError;
                                }
                                return null;
                              },
                              onSaved: (String? val) {
                                dni = val;
                              },
                              decoration: getInputDecoration(
                                  hint: LocalizedStrings.of(context).registerDni,
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).colorScheme.error),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              keyboardType: TextInputType.text, // Cambia el tipo según sea necesario
                              textInputAction: TextInputAction.next,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return LocalizedStrings.of(context).registerPhoneNumberError;
                                }
                                return null;
                              },
                              onSaved: (String? val) {
                                cellphone = val;
                              },
                              decoration: getInputDecoration(
                                  hint: LocalizedStrings.of(context).registerPhoneNumber,
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).colorScheme.error),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              controller: _passwordController,
                              validator: validatePassword,
                              onSaved: (String? val) {
                                password = val;
                              },
                              style:
                                  const TextStyle(height: 0.8, fontSize: 18.0),
                              cursorColor: const Color(COLOR_PRIMARY),
                              decoration: getInputDecoration(
                                  hint: LocalizedStrings.of(context).registerPasswd,
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 16.0, right: 8.0, left: 8.0),
                            child: TextFormField(
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) =>
                                  context.read<SignUpBloc>().add(
                                        ValidateFieldsEvent(_key,
                                            acceptEula: acceptEULA),
                                      ),
                              obscureText: true,
                              validator: (val) => validateConfirmPassword(
                                  _passwordController.text, val),
                              onSaved: (String? val) {
                                confirmPassword = val;
                              },
                              style:
                                  const TextStyle(height: 0.8, fontSize: 18.0),
                              cursorColor: const Color(COLOR_PRIMARY),
                              decoration: getInputDecoration(
                                  hint: LocalizedStrings.of(context).registerConfirmPasswd,
                                  darkMode: isDarkMode(context),
                                  errorColor: Theme.of(context).colorScheme.error),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                right: 40.0, left: 40.0, top: 40.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(COLOR_PRIMARY),
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25.0),
                                  side: const BorderSide(
                                    color: Color(COLOR_PRIMARY),
                                  ),
                                ),
                              ),
                              child: Text(
                                LocalizedStrings.of(context).registerButton,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () => context.read<SignUpBloc>().add(
                                    ValidateFieldsEvent(_key,
                                        acceptEula: acceptEULA),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ListTile(
                            trailing: BlocBuilder<SignUpBloc, SignUpState>(
                              buildWhen: (old, current) =>
                                  current is EulaToggleState && old != current,
                              builder: (context, state) {
                                if (state is EulaToggleState) {
                                  acceptEULA = state.eulaAccepted;
                                }
                                return Checkbox(
                                  onChanged: (value) =>
                                      context.read<SignUpBloc>().add(
                                            ToggleEulaCheckboxEvent(
                                              eulaAccepted: value!,
                                            ),
                                          ),
                                  activeColor: const Color(COLOR_PRIMARY),
                                  value: acceptEULA,
                                );
                              },
                            ),
                            title: RichText(
                              textAlign: TextAlign.left,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text:
                                      LocalizedStrings.of(context).registerTerms,
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                    ),
                                    text: LocalizedStrings.of(context).registerTerms2,
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () async {
                                        if (await canLaunch(EULA)) {
                                          await launch(
                                            EULA,
                                            forceSafariVC: false,
                                          );
                                        }
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }
}
