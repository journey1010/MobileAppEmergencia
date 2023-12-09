import 'package:app_emergen/localization/localized_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart'; // Assuming you're using the uuid package for generating unique IDs

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<types.Message> _messages = [];
  final _user = const types.User(id: '82091008-a484-4a89-ae75-a22bf8d6f3ac');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat"), backgroundColor: Colors.white,), // Optional: Added for better UI
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        l10n: ChatL10nEn(
          inputPlaceholder: LocalizedStrings.of(context).chatInputHint,
          emptyChatPlaceholder: LocalizedStrings.of(context).chatPlaceholder,
        ),
      ),
    );
  }

  void _handleSendPressed(types.PartialText message) {
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(), // Generating a unique ID for each message
      text: message.text,
    );

    _addMessage(textMessage);
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message); // Inserts the new message at the start of the list
    });
  }
}