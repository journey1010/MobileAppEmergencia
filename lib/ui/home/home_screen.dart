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
import 'package:carousel_slider/carousel_slider.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> {
  late User user;
  final LocationService locationService = LocationService();
  
  List<Widget> buildCarouselItems(BuildContext context) {
    return [
      buildImageWithCaption( context, 'assets/images/carrusel_1.jpg', LocalizedStrings.of(context).carouselCaption1, LocalizedStrings.of(context).carouselSubtitles1),
      buildImageWithCaption( context, 'assets/images/carrusel_2.jpg', LocalizedStrings.of(context).carouselCaption2, LocalizedStrings.of(context).carouselSubtitles2),
      buildImageWithCaption( context, 'assets/images/carrusel_3.jpg', LocalizedStrings.of(context).carouselCaption3, LocalizedStrings.of(context).carouselSubtitles3),
    ];
  }

  Widget buildImageWithCaption(BuildContext context, String imagePath, String caption, String captionSubtitle) {
    return Card(
      elevation: 5.0, // Adjust the elevation for desired shadow effect
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Adjust the border radius for desired roundness
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0), // Same value as above to clip the image
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: <Widget>[
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 200,
            ),
            Positioned( // Use Positioned to place the Container at the bottom left
              left: 10.0,
              bottom: 10.0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(5.0), // Round corners for the text background
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Ensure the column takes up only as much space as needed
                  children: [
                    Text(
                      caption,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      captionSubtitle,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
    handleSOSResponse( success );
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
            children: [
              CarouselSlider(
                items: buildCarouselItems(context),
                options: CarouselOptions(
                  height: 200,
                  autoPlay: true,
                  autoPlayCurve: Curves.easeInOut,
                  autoPlayAnimationDuration: Duration(milliseconds: 500),
                  aspectRatio: 16/9,
                  viewportFraction: 0.8,
                ),
              ),
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        child: Text(
                          LocalizedStrings.of(context).ourServices, 
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildServiceButton(
                            context: context,
                            image: 'assets/images/policia_logo.png',
                            label: LocalizedStrings.of(context).buttonPolice,
                            color: Colors.green,
                            onPressed: () => attemptSendSOS('policia'),
                          ),
                          SizedBox(width: 10), // Espacio entre botones
                          _buildServiceButton(
                            context: context,
                            image: 'assets/images/emergencia_logo.png',
                            label: LocalizedStrings.of(context).buttonAmbulance,
                            color: Colors.blue,
                            onPressed: () => attemptSendSOS('hospital'),
                          ),
                        ],
                      ),
                      SizedBox(height: 10), // Espacio entre las filas de botones
                      Row(
                        children: [
                          Expanded(
                            child: _buildServiceButton(
                              context: context,
                              image: 'assets/images/bomberos_logo.png',
                              label: LocalizedStrings.of(context).buttonFireMan,
                              color: Colors.red,
                              onPressed: () => attemptSendSOS('bomberos'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(  horizontal: 14 ),
                child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular( 8 ), // Esquinas redondeadas del Card
                ),
                elevation: 10.0, // Sombra del Card
                child: Padding(
                  padding: const EdgeInsets.all( 16 ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.blue, 
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Text(
                          LocalizedStrings.of(context).lastNotf,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        LocalizedStrings.of(context).lastNotfBodyText,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14.0,
                        ),
                        maxLines: 2, 
                        overflow: TextOverflow.ellipsis,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: TextButton(
                          onPressed: () {
                          },
                          child: Text(
                            LocalizedStrings.of(context).lastNotfSeeMoreButton,
                            style: TextStyle(
                              color: Colors.blue,
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(50, 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ),
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

Widget _buildServiceButton({
  required BuildContext context,
  required String image,
  required String label,
  required Color color,
  required VoidCallback onPressed,
}) {
  return Expanded(
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        primary: color,
        backgroundColor: Colors.white, // Color de fondo del botón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8), // Bordes redondeados
        ),
        elevation: 4, // Elevación para la sombra
        shadowColor: Colors.grey, // Color de la sombra
        padding: EdgeInsets.symmetric(vertical: 16.0), // Añade padding vertical
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            height: 60.0, // Aumenta el tamaño de la imagen
            width: 60.0,
            child: Image.asset(image), // Usa el nombre del asset de la imagen
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0), // Añade espacio entre la imagen y el texto
            child: FittedBox(
              fit: BoxFit.scaleDown, // Asegura que el texto se ajuste al espacio disponible
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 14, // Mantiene el tamaño del texto
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
