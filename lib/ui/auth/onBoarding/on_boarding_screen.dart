import 'package:app_emergen/localization/localized_strings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_emergen/constants.dart';
import 'package:app_emergen/services/helper.dart';
import 'package:app_emergen/ui/auth/authentication_bloc.dart';
import 'package:app_emergen/ui/auth/onBoarding/on_boarding_cubit.dart';
import 'package:app_emergen/ui/auth/welcome/welcome_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  // /list of strings containing onBoarding titles
  // final List<String> _titlesList = [
  //   'Envía tu Ubicación Rápidamente',
  //   'Contacta a los Bomberos',
  //   'Alerta a la Policía',
  //   'Llama a una Ambulancia',
  //   'Asistencia Inmediata',
  // ];

  // / list of strings containing onBoarding subtitles, the small text under the
  // / title
  // final List<String> _subtitlesList = [
  //   'Comparte tu ubicación exacta con solo un toque',
  //   'Informa emergencias de fuego y rescate de forma eficiente',
  //   'Reporta delitos o pide ayuda policial al instante',
  //   'Solicita servicios médicos de emergencia cuando más lo necesitas',
  //   'Estamos aquí para ayudarte en cualquier emergencia',
  // ];

  /// list containing image paths or IconData representing the image of each page

final List<dynamic> _imageList = [
  Icons.location_on, 
  'assets/images/bomberos.png', 
  'assets/images/policias.png', 
  'assets/images/ambulancias.png', 
  Icons.help_outline, 
];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OnBoardingCubit(),
      child: Scaffold(
        backgroundColor: const Color(COLOR_PRIMARY),
        body: BlocBuilder<OnBoardingCubit, OnBoardingInitial>(
          builder: (context, state) {
            return Stack(
              children: [
                PageView.builder(
                  itemBuilder: (context, index) => getPage(_imageList[index], index, context),
                  controller: pageController,
                  itemCount: LocalizedStrings.of(context).titles.length,
                  onPageChanged: (int index) {
                    context.read<OnBoardingCubit>().onPageChanged(index);
                  },
                ),
                Visibility(
                  visible: state.currentPageCount + 1 == LocalizedStrings.of(context).titles.length,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Directionality.of(context) == TextDirection.ltr
                          ? Alignment.bottomRight
                          : Alignment.bottomLeft,
                      child:
                          BlocListener<AuthenticationBloc, AuthenticationState>(
                        listener: (context, state) {
                          if (state.authState == AuthState.unauthenticated) {
                            pushAndRemoveUntil(
                                context, const WelcomeScreen(), false);
                          }
                        },
                        child: OutlinedButton(
                          onPressed: () {
                            context
                                .read<AuthenticationBloc>()
                                .add(FinishedOnBoardingEvent());
                          },
                          child: const Text(
                            'Continuar',
                            style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white),
                              shape: const StadiumBorder()),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SmoothPageIndicator(
                      controller: pageController,
                      count: LocalizedStrings.of(context).titles.length,
                      effect: ScrollingDotsEffect(
                          activeDotColor: Colors.white,
                          dotColor: Colors.grey.shade400,
                          dotWidth: 8,
                          dotHeight: 8,
                          fixedCenter: true),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }

  Widget getPage( dynamic image, int index, BuildContext context ) {
    String title = LocalizedStrings.of(context).titles[index];
    String subTitle = LocalizedStrings.of(context).subtitles[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        image is String
            ? Image.asset(
                image,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              )
            : Icon(
                image as IconData,
                color: Colors.white,
                size: 150,
              ),
        const SizedBox(height: 40),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            subTitle,
            style: const TextStyle(color: Colors.white, fontSize: 14.0),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Future<bool> setFinishedOnBoarding() async {
    final storage = FlutterSecureStorage();
    await storage.write(key: FINISHED_ON_BOARDING, value: 'true');
    return true; 
  }
}
