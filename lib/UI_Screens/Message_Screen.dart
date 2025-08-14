import 'package:flutter/material.dart';
import 'package:matrimony/services/api_service.dart';

class MessageScreen extends StatefulWidget {
  final String senderId; // Current logged-in user
  final String receiverId; // Chat partner
  final String receiverName; // Optional: display name in AppBar

  const MessageScreen({
    Key? key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
  }) : super(key: key);

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = []; // Dynamic message list
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      final result = await ApiService.getMessages(
        senderId: widget.senderId,
        receiverId: widget.receiverId,
      );

      if (result['success'] == true) {
        setState(() {
          messages = List<Map<String, dynamic>>.from(result['messages']);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Failed to load messages"),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    setState(() => isSending = true);
    String msg = _messageController.text.trim();

    final result = await ApiService.sendMessage(
      senderId: widget.senderId,
      receiverId: widget.receiverId,
      message: msg,
    );

    if (result['success']) {
      setState(() {
        messages.add({
          'sender_id': widget.senderId,
          'message': msg,
          'time': DateTime.now().toString(),
        });
        _messageController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed to send")),
      );
    }

    setState(() => isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Set your desired color here
        ),
        title: Text(
          widget.receiverName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.pink,
      ),
      body: Column(
        children: [
          Expanded(
            child:
                messages.isEmpty
                    ? const Center(child: Text("No messages yet"))
                    : ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg =
                            messages[messages.length -
                                1 -
                                index]; // reverse list
                        bool isMe =
                            msg['sender_id'].toString() == widget.senderId;

                        return Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.pink[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(msg['message']),
                          ),
                        );
                      },
                    ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: "Type a message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  isSending
                      ? const CircularProgressIndicator()
                      : IconButton(
                        icon: const Icon(Icons.send, color: Colors.pink),
                        onPressed: _sendMessage,
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
