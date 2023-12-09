import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:app_emergen/constants.dart';
import 'package:progress_dialog/progress_dialog.dart';

String? validateName(String? value) {
  String pattern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.isEmpty ?? true) {
    return "Nombre es requerido";
  } else if (!regExp.hasMatch(value ?? '')) {
    return "El nombre debe contener caracteres a-z and A-Z";
  }
  return null;
}

String? validateMobile(String? value) {
  String pattern = r'(^\+?[0-9]*$)';
  RegExp regExp = RegExp(pattern);
  if (value?.isEmpty ?? true) {
    return "Número de teléfono es requerido";
  } else if (!regExp.hasMatch(value ?? '')) {
    return "Número de telefono solo debe contener números.";
  }
  return null;
}

String? validatePassword(String? value) {
  if ((value?.length ?? 0) < 6) {
    return 'La contraseña debe tener mas 5 caracteres';
  } else {
    return null;
  }
}

String? validateEmail(String? value) {
  String pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(value ?? '')) {
    return 'Ingrese un correo valido.';
  } else {
    return null;
  }
}

String? validateConfirmPassword(String? password, String? confirmPassword) {
  if (password != confirmPassword) {
    return 'Las contraseñas no coinciden';
  } else if (confirmPassword?.isEmpty ?? true) {
    return 'Confirmación de contraseña es requerida.';
  } else {
    return null;
  }
}

//helper method to show progress
late ProgressDialog progressDialog;

showProgress(BuildContext context, String message, bool isDismissible) async {
  progressDialog = ProgressDialog(context,
      type: ProgressDialogType.Normal, isDismissible: isDismissible);
  progressDialog.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: const Color(COLOR_PRIMARY),
      progressWidget: Container(
        padding: const EdgeInsets.all(8.0),
        child: const CircularProgressIndicator(
          backgroundColor: Colors.white,
          valueColor: AlwaysStoppedAnimation(Color(COLOR_PRIMARY)),
        ),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: const TextStyle(
          color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));
  await progressDialog.show();
}

updateProgress(String message) {
  progressDialog.update(message: message);
}

hideProgress() async {
  await progressDialog.hide();
}

//helper method to show alert dialog
showAlertDialog(BuildContext context, String title, String content) {
  // set up the AlertDialog
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );
  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

pushReplacement(BuildContext context, Widget destination) {
  Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (context) => destination));
}

push(BuildContext context, Widget destination) {
  Navigator.of(context)
      .push(MaterialPageRoute(builder: (context) => destination));
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => predict);
}

Widget displayCircleImage(String picUrl, double size, hasBorder) =>
    CachedNetworkImage(
        imageBuilder: (context, imageProvider) =>
            _getCircularImageProvider(imageProvider, size, false),
        imageUrl: picUrl,
        placeholder: (context, url) =>
            _getPlaceholderOrErrorImage(size, hasBorder),
        errorWidget: (context, url, error) =>
            _getPlaceholderOrErrorImage(size, hasBorder));

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          width: hasBorder ? 2.0 : 0.0,
        ),
      ),
      child: ClipOval(
          child: Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
        height: size,
        width: size,
      )),
    );

Widget _getCircularImageProvider(
    ImageProvider provider, double size, bool hasBorder) {
  return ClipOval(
      child: Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(size / 2)),
        border: Border.all(
          color: Colors.white,
          style: hasBorder ? BorderStyle.solid : BorderStyle.none,
          width: 1.0,
        ),
        image: DecorationImage(
          image: provider,
          fit: BoxFit.cover,
        )),
  ));
}

bool isDarkMode(BuildContext context) {
  if (Theme.of(context).brightness == Brightness.light) {
    return false;
  } else {
    return true;
  }
}

InputDecoration getInputDecoration({
  required String hint,
  required bool darkMode,
  required Color errorColor,
  IconData? icon, // Opcional, añade esto si quieres un ícono
}) {
  return InputDecoration(
    filled: true,
    contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    fillColor: darkMode ? Colors.black54 : Colors.white,
    hintText: hint,
    hintStyle: TextStyle(
      color: darkMode ? Colors.white60 : Colors.grey.shade800,
    ),
    prefixIcon: icon != null ? Icon(icon, color: darkMode ? Colors.white60 : Colors.grey) : null,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0), // Ajustado para bordes menos redondeados
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Color(COLOR_PRIMARY), width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorColor),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: errorColor, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: darkMode ? Colors.white24 : Colors.grey.shade200),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
  );
}

showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
}
