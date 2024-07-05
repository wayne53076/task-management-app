import 'package:flutter/material.dart';
import 'package:task_management_app/views/chat_message.dart';
import 'package:task_management_app/services/assistant.dart';

class AIassistant extends StatefulWidget {
  const AIassistant({super.key});

  @override
  _AIassistantState createState() => _AIassistantState();
}

class _AIassistantState extends State<AIassistant> {
  final TextEditingController _textController = TextEditingController();
  final ChatService _chatService = ChatService();
  int responseState = 0;
  List<ChatMessage>messages = [];

  void fetchResponse() async {
    setState(() {
      messages.add(
        ChatMessage(
          role: 'You',
          text: _textController.text.trim(),
        ),
      );
    });
    String response = await _chatService.fetchPromptResponse(_textController.text);
    setState(() {
      messages.add(
        ChatMessage(
          role: 'AI Assistant',
          text: response,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text('AI Assistant',style: TextStyle(
        color: Colors.white,
    ),)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length + 1, // one extra for padding
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const SizedBox(height: 16);
                }
                final message = messages[index - 1];
                return ListTile(
                  tileColor: message.role == 'AI Assistant'
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : Theme.of(context).colorScheme.surface,
                  title: Text(message.role[0].toUpperCase() +
                      message.role.substring(1)),
                  subtitle: Text(message.text),
                );
              },
            )
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration:
                        const InputDecoration(hintText: 'ASK SOME QUESTION'),
                    maxLines: null, // Allows input to expand
                  ),
                ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: () {
                    if (_textController.text.isNotEmpty) {
                      fetchResponse();
                      _textController.clear();
                    }
                  },
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
