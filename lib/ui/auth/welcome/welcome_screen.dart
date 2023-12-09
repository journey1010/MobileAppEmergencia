import 'package:app_emergen/localization/localized_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/services/helper.dart';
import 'package:app_emergen/ui/auth/login/login_screen.dart';
import 'package:app_emergen/ui/auth/signUp/sign_up_screen.dart';
import 'package:app_emergen/ui/auth/welcome/welcome_bloc.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<WelcomeBloc>(
      create: (context) => WelcomeBloc(),
      child: Builder(
        builder: (context) {
          return Scaffold(
            body: BlocListener<WelcomeBloc, WelcomeInitial>(
              listener: (context, state) {
                switch (state.pressTarget) {
                  case WelcomePressTarget.login:
                    push(context, const LoginScreen());
                    break;
                  case WelcomePressTarget.signup:
                    push(context, const SignUpScreen());
                    break;
                  default:
                    break;
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/images/welcome_image.png',
                      width: 150.0,
                      height: 150.0,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 16, top: 32, right: 16, bottom: 8),
                    child: Text(
                      LocalizedStrings.of(context).welcomeTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Color(COLOR_PRIMARY),
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    child: Text(
                    LocalizedStrings.of(context).welcomeBodyText,
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 20),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(COLOR_PRIMARY),
                        textStyle: const TextStyle(color: Colors.white),
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side:
                            const BorderSide(color: Color(COLOR_PRIMARY))
                        ),
                      ),
                      child: Text(
                        LocalizedStrings.of(context).welcomeLogin,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        context.read<WelcomeBloc>().add(LoginPressed());
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0, left: 40.0, top: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Divider(color: Colors.grey.shade600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(
                            LocalizedStrings.of(context).textOr,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        right: 40.0, left: 40.0, top: 10, bottom: 10),
                    child: TextButton(
                      child: Text(
                        LocalizedStrings.of(context).welcomeJoinUs,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(COLOR_PRIMARY)),
                      ),
                      onPressed: () {
                        context.read<WelcomeBloc>().add(SignupPressed());
                      },
                      style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                          const EdgeInsets.only(top: 16, bottom: 16),
                        ),
                        shape: MaterialStateProperty.all<OutlinedBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: const BorderSide(
                              color: Color(COLOR_PRIMARY),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
