import 'dart:math';
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

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('¡Tu Responsabilidad Salva Vidas! 🚨'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Utiliza esta aplicación con prudencia y solo en situaciones de emergencia genuina. El abuso de esta herramienta afecta la capacidad de respuesta de los servicios de emergencía y pone en riesgo a quienes realmente necesitan ayuda. Juntos, podemos hacer de nuestra comunidad un lugar más seguro. #UsaConResponsabilidad 🤝.',
                ),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Aceptar'),
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
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(COLOR_PRIMARY),
                ),
                child: Text(
                  'Perfil',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              ListTile(
                title: const Text(
                  'Salir',
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
          title: const Text(
            'Inicio',
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
                      onPressed: () {
                        locationService.getLocationAndSendSOS('bomberos');
                      },
                      icon: Icon(Icons.local_fire_department, color: Colors.white, size: 48.0),
                      label: const Text('BOMBEROS', style: TextStyle(fontSize: 20.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.all(16.0),
                        minimumSize: Size(double.infinity, 80.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton.icon(
                      onPressed: () {
                        locationService.getLocationAndSendSOS('hospital');
                      },
                      icon: Icon(Icons.local_hospital, color: Colors.white, size: 48.0),
                      label: const Text('AMBULANCIA', style: TextStyle(fontSize: 20.0)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.all(16.0),
                        minimumSize: Size(double.infinity, 80.0),
                      ),
                    ),
                    SizedBox(height: 20.0), 
                    ElevatedButton.icon(
                      onPressed: () {
                        locationService.getLocationAndSendSOS('policia');
                      },
                      icon: const Icon(Icons.local_police, color: Colors.white, size: 48.0),
                      label: const Text('POLICÍA', style: TextStyle(fontSize: 20.0)),
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
      ),
    );
  } 
}