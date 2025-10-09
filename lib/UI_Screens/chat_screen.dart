import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:matrimony/UI_Screens/Message_Screen.dart';

class ChatScreen extends StatefulWidget {
  final int userId; // pass logged-in user id
  const ChatScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<dynamic> senders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMessages();
  }

  Future<void> fetchMessages() async {
    try {
      final url = Uri.parse(
        "https://pheonixconstructions.com/Matrimony API/message_list.php?receiver_id=${widget.userId}",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          setState(() {
            senders = data['contacts'] ?? [];
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching messages: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(
              top: 44,
              left: 18,
              right: 18,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: pinkColor,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Messages',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          // Chat List
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : senders.isEmpty
                    ? const Center(child: Text("No messages found"))
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: senders.length,
                      itemBuilder: (context, index) {
                        final sender = senders[index];
                        return _ChatItem(
                          name: sender['name'] ?? "",
                          lastMessage: sender['message'] ?? "",
                          time: sender['created'] ?? "",
                          profileImg: sender['profile_img'] ?? "",
                          unreadCount: 0,
                          isOnline: false,
                          loggedInUserId: widget.userId.toString(),
                          messageSenderId:
                              sender['contact_user_id']
                                  .toString(), // use contact_user_id
                          receiverId:
                              sender['contact_user_id']
                                  .toString(), // chat partner id
                          isSeen: "0", // API doesn't provide → default 0
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String name;
  final String lastMessage;
  final String time;
  final String profileImg;
  final int unreadCount;
  final bool isOnline;
  final String loggedInUserId; // logged-in user id
  final String messageSenderId; // actual sender of last message
  final String receiverId; // chat partner id
  final String isSeen; // "0" = not seen, "1" = seen

  const _ChatItem({
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.profileImg,
    required this.unreadCount,
    required this.isOnline,
    required this.loggedInUserId,
    required this.messageSenderId,
    required this.receiverId,
    required this.isSeen,
  });

  @override
  Widget build(BuildContext context) {
    final pinkColor = const Color(0xFFA51C48);

    return InkWell(
      onTap: () async {
        // 👁 Mark as read API call
        final url = Uri.parse(
          "https://pheonixconstructions.com/Matrimony API/mark_as_read.php?sender_id=$receiverId&receiver_id=$loggedInUserId",
        );
        await http.get(url);

        // Navigate to message screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => MessageScreen(
                  senderId: loggedInUserId,
                  receiverId: receiverId,
                  receiverName: name,
                ),
          ),
        ).then((_) {
          // Refresh chat list after returning
          (context as Element).markNeedsBuild();
        });
      },

      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[300],
                  backgroundImage:
                      profileImg.isNotEmpty ? NetworkImage(profileImg) : null,
                  child:
                      profileImg.isEmpty
                          ? const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 28,
                          )
                          : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Chat content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + time
                  Row(
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        formatChatDate(time),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Message + ticks + unread badge
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            // ✅ Show tick marks only if logged-in user sent last message
                            if (messageSenderId == loggedInUserId) ...[
                              Icon(
                                isSeen == "1" ? Icons.done_all : Icons.done,
                                size: 16,
                                color:
                                    isSeen == "1" ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                            ],
                            Expanded(
                              child: Text(
                                lastMessage,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      unreadCount > 0
                                          ? Colors.black87
                                          : Colors.black54,
                                  fontWeight:
                                      unreadCount > 0
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Unread count badge
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: pinkColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String formatChatDate(String dateTime) {
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
      return "${msgDate.day}/${msgDate.month}/${msgDate.year}";
    }
  } catch (e) {
    return dateTime; // fallback if parse fails
  }
}
