import 'package:flutter/material.dart';
import 'chat_service.dart';
import 'image_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Benvenuto in Pingipool, come posso aiutarti?");
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add({'content': text, 'isUser': true});
    });
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'content': text, 'isUser': false});
    });
  }

  void _addImageMessage(String imageUrl) {
    setState(() {
      _messages.add({
        'content': imageUrl,
        'isUser': false,
        'isImage': true,
      });
    });
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    _addUserMessage(input);
    _controller.clear();
    setState(() => _isTyping = true);

    await Future.delayed(const Duration(milliseconds: 100));
    _scrollToBottom();

    try {
      if (input.toLowerCase().contains('genera') ||
          input.toLowerCase().contains('immagine')) {
        final imageUrl = await ImageService.generateImage(input);
        if (imageUrl != null && imageUrl.isNotEmpty) {
          _addImageMessage(imageUrl);
        } else {
          _addBotMessage("Mi dispiace, non sono riuscito a generare l'immagine.");
        }
      } else {
        final botReply = await ChatService.getChatResponse(input);
        _addBotMessage(botReply);
      }
    } catch (e) {
      _addBotMessage("Errore: $e");
    } finally {
      setState(() => _isTyping = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/neurali.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'Pingipool 1.0',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['isUser'] == true;
                    final isImage = message['isImage'] == true;

                    final backgroundColor = isUser
                        ? const Color.fromRGBO(255, 255, 255, 0.2)
                        : const Color.fromRGBO(0, 0, 0, 0.4);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser)
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: CircleAvatar(
                                backgroundImage: AssetImage('assets/images/bot_avatar.png'),
                              ),
                            ),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: isImage
                                  ? Image.network(message['content'])
                                  : Text(
                                      message['content'],
                                      style: const TextStyle(color: Colors.white),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (_isTyping)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Pingipool sta scrivendo...",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Scrivi un messaggio...",
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.cyanAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
