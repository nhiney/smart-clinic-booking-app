import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:smart_clinic_booking/features/support/presentation/controllers/support_controller.dart';
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';

class TicketChatScreen extends ConsumerStatefulWidget {
  final String ticketId;
  final SupportTicket? ticket;

  const TicketChatScreen({
    super.key,
    required this.ticketId,
    this.ticket,
  });

  @override
  ConsumerState<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends ConsumerState<TicketChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(ticketMessagesProvider(widget.ticketId));
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.ticket?.subject ?? 'Hỗ trợ Ticket', 
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
            Text('ID: ${widget.ticketId.substring(0, 8)}', 
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                _scrollToBottom();
                return messages.isEmpty
                  ? _buildEmptyMessages()
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == currentUser?.uid;
                        return _buildChatBubble(msg, isMe);
                      },
                    );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => Center(child: Text('Lỗi: $e')),
            ),
          ),
          _buildInputSection(currentUser?.uid),
        ],
      ),
    );
  }

  Widget _buildEmptyMessages() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('Chưa có tin nhắn nào', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 4),
          Text('Gửi tin nhắn để bắt đầu hỗ trợ', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildChatBubble(SupportMessage msg, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(msg.content, 
              style: TextStyle(color: isMe ? Colors.white : Colors.black, fontSize: 14)),
            const SizedBox(height: 4),
            Text(DateFormat('HH:mm').format(msg.timestamp), 
              style: TextStyle(color: isMe ? Colors.white70 : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(String? userId) {
    if (userId == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.1))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Nhập tin nhắn...',
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              ),
              onSubmitted: (val) => _sendMessage(userId),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF2563EB),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(userId),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String userId) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    final result = await ref.read(supportRepositoryProvider).sendMessage(widget.ticketId, userId, text);
    result.fold(
      (failure) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
      },
      (_) {
        _scrollToBottom();
      },
    );
  }
}
