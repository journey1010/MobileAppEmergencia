import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/ui/auth/authentication_bloc.dart';
import 'package:app_emergen/ui/auth/launcherScreen/launcher_screen.dart';
import 'package:app_emergen/ui/loading_cubit.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:app_emergen/localization/strings_en.dart';
import 'package:app_emergen/localization/strings_es.dart';

void main() => runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AuthenticationBloc()),
        BlocProvider(create: (_) => LoadingCubit()),
      ],
      child: const MyApp(),
    ));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
            snackBarTheme: const SnackBarThemeData(
                contentTextStyle: TextStyle(color: Colors.white)),
            colorScheme: ColorScheme.fromSwatch()
                .copyWith(secondary: const Color(COLOR_PRIMARY))),
        debugShowCheckedModeBanner: false,
        color: const Color(COLOR_PRIMARY),
        home: BlocProvider<AuthenticationBloc>(
          create: (context) => AuthenticationBloc(),
          child: const LauncherScreen(),
        ),
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          // Agrega tus propios delegates de localización aquí
        ],
        supportedLocales: [
          const Locale('en', ''), // Inglés
          const Locale('es', ''), // Español
        ],
      );
  }
}