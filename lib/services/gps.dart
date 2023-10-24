import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:io';

class LocationService {
  final storage = FlutterSecureStorage();

  Future<dynamic> sendSOS(double latitud, double longitud, String tipo) async {
    final url = Uri.parse('https://appemergencias.regionloreto.gob.pe/api/create/sos');
    String? operationToken = await storage.read(key: 'operation_token');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $operationToken';
      
      request.fields['latitud'] = latitud.toString();
      request.fields['longitud'] = longitud.toString();
      request.fields['tipo'] = tipo;
      request.fields['fecha'] = DateTime.now().toString().split(' ')[0];
      request.fields['hora'] = DateTime.now().toString().split(' ')[1];

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return 'Error en la solicitud SOS: $e';
    }
  }

  Future<bool> getLocationAndSendSOS(String tipo) async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return false;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      double latitud = position.latitude;
      double longitud = position.longitude;

      await sendSOS(latitud, longitud, tipo);
      return true;
    } catch (e) {
      return false;
    }
  }
}
