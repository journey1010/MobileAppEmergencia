import 'package:flutter/material.dart';
import 'strings_en.dart';
import 'strings_es.dart';

class LocalizedStrings {
  static dynamic of(BuildContext context) {
    var locale = Localizations.localeOf(context).languageCode;

    if ( locale == 'es' ) {
      return StringsEs();
    } else {
      return StringsEn();
    }
  }
}