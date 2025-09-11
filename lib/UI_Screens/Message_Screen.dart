import 'package:flutter/material.dart';
import 'package:matrimony/services/api_service.dart';

class MessageScreen extends StatefulWidget {
  final String senderId; // Current logged-in user
  final String receiverId; // Chat partner
  final String receiverName; // Display name in AppBar

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
  List<Map<String, dynamic>> messages = [];
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();

    // 🔄 Auto refresh every 5 seconds to update ticks and new messages
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      await _loadMessages();
      return true;
    });
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
      _messageController.clear();
      // ✅ Reload full list so ticks update properly
      await _loadMessages();
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
        iconTheme: const IconThemeData(color: Colors.white),
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
                        final msg = messages[messages.length - 1 - index];

                        /// ✅ Null safe handling
                        final String text = msg['message']?.toString() ?? "";
                        final String senderId =
                            msg['sender_id']?.toString() ?? "";
                        final String time = msg['time']?.toString() ?? "";
                        final String seen = msg['is_seen']?.toString() ?? "0";

                        bool isMe = senderId == widget.senderId;

                        // ✅ Date header logic
                        String msgDate = _formatDate(time);
                        bool showHeader = true;
                        if (index > 0) {
                          final prevMsg =
                              messages[messages.length - 1 - (index - 1)];
                          String prevDate = _formatDate(
                            prevMsg['time']?.toString() ?? "",
                          );
                          if (prevDate == msgDate) {
                            showHeader = false;
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (showHeader)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Text(
                                  msgDate,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),

                            Align(
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
                                  color:
                                      isMe
                                          ? Colors.pink[100]
                                          : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        text,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),

                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Icon(
                                        seen == "1"
                                            ? Icons.done_all
                                            : Icons.done,
                                        size: 16,
                                        color:
                                            seen == "1"
                                                ? Colors.blue
                                                : Colors.grey,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),

          // Input box
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
                  IconButton(
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

/// Format message date into Today / Yesterday / dd-MM-yyyy
String _formatDate(String? dateTime) {
  if (dateTime == null || dateTime.isEmpty) return "";
  try {
    final now = DateTime.now();
    final msgDate = DateTime.parse(dateTime);

    if (msgDate.year == now.year &&
        msgDate.month == now.month &&
        msgDate.day == now.day) {
      return "Today";
    } else if (msgDate.year == now.year &&
        msgDate.month == now.month &&
        msgDate.day == now.day - 1) {
      return "Yesterday";
    } else {
      return "${msgDate.day}-${msgDate.month}-${msgDate.year}";
    }
  } catch (e) {
    return dateTime;
  }
}
