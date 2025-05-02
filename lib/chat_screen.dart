import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'chat_service.dart';

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
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add({'content': text, 'isUser': false});
    });
    _scrollToBottom();
  }

  void _addImageMessage(File imageFile) {
    setState(() {
      _messages.add({
        'content': imageFile,
        'isUser': true,
        'isImage': true,
      });
    });
    _scrollToBottom();
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    _addUserMessage(input);
    _controller.clear();
    setState(() => _isTyping = true);

    final lowerInput = input.toLowerCase();

    try {
      if (lowerInput.contains("foto") ||
          lowerInput.contains("immagine reale") ||
          lowerInput.contains("immagine vera") ||
          lowerInput.contains("mostrami una foto") ||
          lowerInput.contains("mostra una foto") ||
          lowerInput.contains("mostrami un'immagine reale") ||
          lowerInput.contains("mostra un'immagine reale")) {
        debugPrint("🔎 CERCO IMMAGINE REALE");
        final imageUrl = await ChatService.fetchRealImage(input);

        if (imageUrl != null) {
          setState(() {
            _messages.add({
              'content': imageUrl,
              'isUser': false,
              'isImageUrl': true,
            });
          });
        } else {
          _addBotMessage("Mi dispiace, non ho trovato nessuna immagine reale.");
        }
      } else if (lowerInput.contains("disegna") ||
          lowerInput.contains("immagine") ||
          lowerInput.contains("genera un'immagine") ||
          lowerInput.contains("mostra un'immagine") ||
          lowerInput.contains("crea un'immagine")) {
        debugPrint("🎨 GENERO IMMAGINE AI");
        final imageUrl = await ChatService.generateImage(input);

        if (imageUrl != null) {
          setState(() {
            _messages.add({
              'content': imageUrl,
              'isUser': false,
              'isImageUrl': true,
            });
          });
        } else {
          _addBotMessage("Mi dispiace, non sono riuscito a generare l'immagine.");
        }
      } else {
        final botReply = await ChatService.sendMessage(input);
        _addBotMessage(botReply);
      }
    } catch (e) {
      _addBotMessage("Errore durante la comunicazione.");
    } finally {
      setState(() => _isTyping = false);
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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      _addImageMessage(file);
    }
  }

  void _startNewChat() {
    setState(() {
      _messages.clear();
      _addBotMessage("Benvenuto in Pingipool, come posso aiutarti?");
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF0D0D2B),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF0A0F1C),
              ),
              child: Text(
                'Pingipool Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Colors.cyanAccent),
              title: const Text('Nuova Chat', style: TextStyle(color: Colors.white)),
              onTap: _startNewChat,
            ),
            ListTile(
              leading: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              title: const Text('Indietro', style: TextStyle(color: Colors.white)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Versione 1.0',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        centerTitle: true,
        title: const Text(
          'Pingipool 1.0',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
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
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final message = _messages[index];
                    final isUser = message['isUser'] == true;
                    final isImage = message['isImage'] == true;
                    final isImageUrl = message['isImageUrl'] == true;

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
                                color: isUser
                                    ? const Color.fromARGB(255, 63, 61, 61)
                                    : const Color.fromARGB(255, 36, 91, 82),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: isImage
                                  ? Image.file(message['content'])
                                  : isImageUrl
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
                    IconButton(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.add, color: Colors.cyanAccent),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: "Scrivi un messaggio...",
                          hintStyle: TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white12,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
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
