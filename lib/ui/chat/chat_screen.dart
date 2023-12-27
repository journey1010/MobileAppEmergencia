import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:geolocator/geolocator.dart';
import 'package:uuid/uuid.dart';
import 'package:app_emergen/localization/localized_strings.dart';
import 'package:app_emergen/services/msg.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');
  String _selectedEmergencyType = ''; // Variable para almacenar el tipo de emergencia seleccionado

@override
Widget build(BuildContext context) {
  double bottomPadding = 50; // Ajusta este valor según la altura de tus botones.

  return Scaffold(
    appBar: AppBar(
      title: Text("Chat"),
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle( color: Colors.black, fontSize: 20 ),
    ),
    body: Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: bottomPadding), // Añade padding en la parte inferior del chat.
          child: Chat(
            messages: _messages,
            onSendPressed: _handleSendPressed,
            user: _user,
            l10n: ChatL10nEn(
              inputPlaceholder: LocalizedStrings.of(context).chatInputHint,
              emptyChatPlaceholder: LocalizedStrings.of(context).chatPlaceholder,
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom, // Esto permite ajustar la posición de los botones cuando aparece el teclado.
            ),
            child: Container(
              color: Colors.white, // Puedes cambiar el color para que coincida con el tema de tu app.
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildEmergencyButton(context, LocalizedStrings.of(context).chatButtonPolice, 'policia'),
                    _buildEmergencyButton(context, LocalizedStrings.of(context).chatButtonAmbulance, 'hospital'),
                    _buildEmergencyButton(context, LocalizedStrings.of(context).chatButtonFireman, 'bomberos'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


Widget _buildEmergencyButton(BuildContext context, String label, String emergencyType) {
  IconData iconData;
  Color buttonColor;

  switch (emergencyType) {
    case 'policia':
      iconData = Icons.security; // Ejemplo de ícono para policía
      buttonColor = Colors.blue;
      break;
    case 'hospital':
      iconData = Icons.local_hospital; // Ejemplo de ícono para ambulancia
      buttonColor = Colors.green;
      break;
    case 'bomberos':
      iconData = Icons.fire_extinguisher; // Ejemplo de ícono para bomberos
      buttonColor = Colors.red;
      break;
    default:
      iconData = Icons.warning; // Ícono por defecto
      buttonColor = Colors.grey;
  }

  return ElevatedButton.icon(
    icon: Icon(iconData, color: Colors.white),
    label: Text(
      label,
      style: TextStyle(color: Colors.white),
    ),
    onPressed: () {
      setState(() {
        _selectedEmergencyType = emergencyType;
      });
    },
    style: ElevatedButton.styleFrom(
      primary: _selectedEmergencyType == emergencyType ? buttonColor : Colors.grey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      elevation: _selectedEmergencyType == emergencyType ? 4 : 2, // Cambia la elevación cuando está seleccionado
    ),
  );
}


  void handleMsgResponse(bool success) {
    final snackBar = SnackBar(
      content: Text(success
          ? LocalizedStrings.of(context).sendLocationOk
          : LocalizedStrings.of(context).sendLocationFailed),
      backgroundColor: success ? Colors.green : Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

void _handleSendPressed(types.PartialText message) async {
  if (_selectedEmergencyType.isEmpty) {
    final snackBar = SnackBar(
      content: Text('Por favor, seleccione un tipo de emergencia.'),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    return;
  }

  final messageService = MessageService();
  final Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  final success = await messageService.sendMessageWithLocation(_selectedEmergencyType, message.text);

  final content = _buildMessageContent(message.text, position, _selectedEmergencyType, success);
  final textMessage = types.TextMessage(
    author: _user,
    createdAt: DateTime.now().millisecondsSinceEpoch,
    id: const Uuid().v4(),
    text: content,
  );

  _addMessage(textMessage);
  handleMsgResponse(success);
}

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }
}

String _buildMessageContent(String text, Position position, String emergencyType, bool success) {
  DateTime now = DateTime.now();
  String formattedDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  String formattedTime = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

  return 'Mensaje: $text\n'
      'Coordenadas: ${position.latitude}, ${position.longitude}\n'
      'Servicio: $emergencyType\n'
      'Estado: ${success ? "Enviado" : "No Enviado (Error)"}\n'
      'Fecha: $formattedDate\n'
      'Hora: $formattedTime';
}