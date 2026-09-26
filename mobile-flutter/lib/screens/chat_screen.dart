import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../config.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String token;
  final String username;

  const ChatScreen({
    super.key,
    required this.token,
    required this.username,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late io.Socket _socket;
  final List<Map<String, dynamic>> _messages = [];
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _connected = false;

  @override
  void initState() {
    super.initState();
    _connectSocket();
  }

  void _connectSocket() {
    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': widget.token}) // mismo mecanismo que el cliente React
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) {
      if (mounted) setState(() => _connected = true);
    });

    _socket.onDisconnect((_) {
      if (mounted) setState(() => _connected = false);
    });

    // Historial de los últimos 10 mensajes al conectar
    _socket.on('messages-history', (data) {
      if (data is List && mounted) {
        setState(() {
          _messages.clear();
          _messages.addAll(data.cast<Map<String, dynamic>>());
        });
        _scrollToBottom();
      }
    });

    // Nuevos mensajes en tiempo real (broadcast)
    _socket.on('new-message', (data) {
      if (data is Map && mounted) {
        setState(() => _messages.add(Map<String, dynamic>.from(data)));
        _scrollToBottom();
      }
    });

    _socket.onConnectError((err) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de conexión: $err')),
        );
      }
    });
  }

  void _sendMessage() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || !_connected) return;
    _socket.emit('new-message', {'text': text});
    _textCtrl.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _socket.clearListeners();
    _socket.dispose();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Icons.circle,
              size: 12,
              color: _connected ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Lista de mensajes ────────────────────────────────────────────
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('No hay mensajes aún.'))
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isMe = msg['username'] == widget.username;
                      return MessageBubble(
                        username: msg['username']?.toString() ?? '?',
                        text: msg['text']?.toString() ?? '',
                        createdAt: msg['created_at']?.toString(),
                        isMe: isMe,
                      );
                    },
                  ),
          ),
          // ── Input de envío ───────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje...',
                        border: OutlineInputBorder(),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _connected ? _sendMessage : null,
                    tooltip: 'Enviar',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
