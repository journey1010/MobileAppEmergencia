class StringsEn {
  String get title => "Hello World";
  //HomeScreen
  String get sendLocationOk => "Location sent successfully.";
  String get sendLocationFailed => "Could not send the location. Please try again.";
  String get alertTitle => "Your Responsibility Saves Lives! 🚨";
  String get alertBodyText => "Use this app wisely and only in genuine emergency situations. Misuse of this tool affects the responsiveness of emergency services and puts at risk those who really need help. Together, we can make our community a safer place. #UseResponsibly 🤝.";
  String get alertButtonText => "Accept";

  String get sideBarItemUser => "Profile";
  String get sideBarItemLogout => "Logout";
  
  String get appBarHomeScreen => "Home";
  String get buttonFireMan => "FIREFIGHTERS";
  String get buttonAmbulance => "AMBULANCE";
  String get buttonPolice => "POLICE";

  // OnBoarding
  List<String> get titles => [
    'Send Your Location Quickly',
    'Contact the Firefighters',
    'Alert the Police',
    'Call an Ambulance',
    'Immediate Assistance',
  ];

  List<String> get subtitles => [
    'Share your exact location with just a tap',
    'Report fire and rescue emergencies efficiently',
    'Report crimes or ask for police help instantly',
    'Request emergency medical services when you need it most',
    'We are here to help you in any emergency',
  ];

  // Login
  String get loginFailed => "Cannot connect, Please try again.";
  String get loginAwait => "Starting, Please wait...";
  String get loginTitle => "Complete the fields";
  String get loginEmail => "Email";
  String get loginPasswd => "Password";
  String get loginButton => "Log In";

  // Register
  String get registerFailed => "Could not join, Please try again.";
  String get registerAwait => "Creating new account, please wait.";
  String get registerTitle => "Create a new account";
  String get registerName => "Name";
  String get registerLastname => "last name";
  String get registerEmail => "Email";

  String get registerDni => "ID Number";
  String get registerDniError => "Please enter your ID number";

  String get registerPhoneNumber => "Phone Number";
  String get registerPhoneNumberError => "Please enter your phone number";
  
  String get registerPasswd => "Password";
  String get registerConfirmPasswd => "Confirm Password";

  String get registerTerms => "By creating an account you accept our terms of use.";
  String get registerTerms2 => "Terms of Use.";
  String get registerButton => "Join";

  //Welcome
  String get welcomeTitle => "Welcome citizen!";
  String get welcomeBodyText => "AppEmergency allows you to share your location and alert emergency services, such as firefighters, police, or ambulances.";
  String get welcomeLogin => "Log In";
  String get welcomeJoinUs => "Join Us";
}