import 'dart:math';
import 'package:app_emergen/localization/localized_strings.dart';
import 'package:app_emergen/ui/chat/chat_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/model/user.dart';
import 'package:app_emergen/services/helper.dart';
import 'package:app_emergen/services/gps.dart';
import 'package:app_emergen/ui/auth/authentication_bloc.dart';
import 'package:app_emergen/ui/auth/welcome/welcome_screen.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late User user;
  final LocationService locationService = LocationService();

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  void handleSOSResponse(bool success) {
    final snackBar = SnackBar(
      content: Text(success
        ? LocalizedStrings.of(context).sendLocationOk  // Usa la cadena localizada para el caso de éxito
        : LocalizedStrings.of(context).sendLocationFailed),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> attemptSendSOS(String tipo) async {
  bool success = await locationService.getLocationAndSendSOS(tipo);
  handleSOSResponse(success);
  }
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(LocalizedStrings.of(context).alertTitle),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(LocalizedStrings.of(context).alertBodyText),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(LocalizedStrings.of(context).alertButtonText),
              ),
            ],
          );
        },
      );
    });

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(COLOR_PRIMARY),
                ),
                child: Text(
                  LocalizedStrings.of(context).sideBarItemUser,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: Text(
                  LocalizedStrings.of(context).sideBarItemLogout,
                  style: TextStyle(color: Colors.black),
                ),
                leading: Transform.rotate(
                    angle: pi / 1,
                    child: const Icon(Icons.exit_to_app, color: Colors.black)),
                onTap: () {
                  context.read<AuthenticationBloc>().add(LogoutEvent());
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: Text(
            LocalizedStrings.of(context).appBarHomeScreen,
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(height: 20.0), 
                    ElevatedButton.icon(
                      onPressed: () => attemptSendSOS('bomberos'),
                      icon: Icon(Icons.local_fire_department, color: Colors.white, size: 48.0),
                      label: Text( LocalizedStrings.of(context).buttonFireMan, style: TextStyle(fontSize: 20.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.all(16.0),
                        minimumSize: Size(double.infinity, 80.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton.icon(
                      onPressed: () => attemptSendSOS('hospital'),
                      icon: Icon(Icons.local_hospital, color: Colors.white, size: 48.0),
                      label: Text( LocalizedStrings.of(context).buttonAmbulance, style: TextStyle(fontSize: 20.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.all(16.0),
                        minimumSize: Size(double.infinity, 80.0),
                      ),
                    ),
                    SizedBox(height: 20.0), 
                    ElevatedButton.icon(
                      onPressed: () => attemptSendSOS('policia'),
                      icon: const Icon(Icons.local_police, color: Colors.white, size: 48.0),
                      label: Text( LocalizedStrings.of(context).buttonPolice, style: TextStyle(fontSize: 20.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.all(16.0),
                        minimumSize: Size(double.infinity, 80.0),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
          },
          child: Icon( Icons.chat ),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  } 
}