import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';

class MessageService {
  final storage = FlutterSecureStorage();

  Future<bool> sendMessageWithLocation(String messageType, String text) async {
    final url = Uri.parse('https://appemergencias.regionloreto.gob.pe/api/message');
    String? operationToken = await storage.read(key: 'operation_token');

    try {
      var request = http.MultipartRequest('POST', url);
      request.headers['Authorization'] = 'Bearer $operationToken';

      // Agrega los campos necesarios para el mensaje
      request.fields['message_type'] = messageType;
      request.fields['text'] = text;

      // Obtiene la ubicación actual
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

      // Agrega la ubicación al mensaje
      request.fields['latitud'] = position.latitude.toString();
      request.fields['longitud'] = position.longitude.toString();
      request.fields['fecha'] = DateTime.now().toString().split(' ')[0];
      request.fields['hora'] = DateTime.now().toString().split(' ')[1];

      var response = await request.send();

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}