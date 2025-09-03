import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final String avatarUrl;
  final bool isSent; // true if sent by current user

  const ChatBubble({
    super.key,
    required this.message,
    required this.avatarUrl,
    this.isSent = true,
  });

  @override
  Widget build(BuildContext context) {
    final mainAxisAlignment =
    isSent ? MainAxisAlignment.end : MainAxisAlignment.start;

    final bubbleColor = isSent ? Colors.blue : Colors.grey[300];
    final textColor = isSent ? Colors.white : Colors.black87;

    final borderRadius = BorderRadius.only(
      topLeft: Radius.circular(isSent ? 16 : 0),
      topRight: Radius.circular(isSent ? 0 : 16),
      bottomLeft: const Radius.circular(16),
      bottomRight: const Radius.circular(16),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isSent)
            CircleAvatar(
              radius: 18.r,
              backgroundImage:
              avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
              backgroundColor: Colors.grey[400],
              child: avatarUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),

          if (!isSent) const SizedBox(width: 8),

          Flexible(
            child: Container(
              padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: borderRadius,
              ),
              child: Text(
                message,
                style: TextStyle(fontSize: 15.sp, color: textColor),
              ),
            ),
          ),

          if (isSent) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
