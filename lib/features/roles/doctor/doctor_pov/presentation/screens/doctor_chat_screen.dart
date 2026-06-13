import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorChatScreen extends StatefulWidget {
  final String patientId;
  final String? patientName;
  const DoctorChatScreen({super.key, required this.patientId, this.patientName});

  @override
  State<DoctorChatScreen> createState() => _State();
}

class _State extends State<DoctorChatScreen> {
  final _msgCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  late final String _chatId;

  static const _quickReplies = ['Tới phòng khám ngay', 'Nhắc uống thuốc', 'Đặt lịch tái khám'];

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'doctor';
    final ids = [uid, widget.patientId]..sort();
    _chatId = ids.join('_');
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty) return;
    _msgCtrl.clear();
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'doctor';
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).collection('messages').add({
      'text': t, 'senderId': uid, 'timestamp': FieldValue.serverTimestamp(), 'read': false,
    });
    await FirebaseFirestore.instance.collection('chats').doc(_chatId).set({
      'participants': [uid, widget.patientId],
      'lastMessage': t,
      'lastTimestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
    });
  }

  @override
  Widget build(BuildContext context) {
    final patientName = widget.patientName ?? 'Bệnh nhân';
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF0F172A),
        titleSpacing: 0,
        leading: const BackButton(color: Color(0xFF0F172A)),
        title: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
            child: Text(patientName.split(' ').last.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8))),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(patientName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
            const Row(children: [
              Icon(Icons.circle, size: 8, color: Color(0xFF22C55E)),
              SizedBox(width: 4),
              Text('Đang hoạt động', style: TextStyle(fontSize: 11, color: Color(0xFF22C55E))),
            ]),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.phone_rounded, color: Color(0xFF64748B)), onPressed: () {}),
          IconButton(icon: const Icon(Icons.videocam_rounded, color: Color(0xFF64748B)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Appointment context banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: Color(0xFF1D4ED8)),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(style: TextStyle(fontSize: 12, color: Color(0xFF64748B)), children: [
                    TextSpan(text: 'Lịch hẹn 10:30 hôm nay · ', style: TextStyle(color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
                    TextSpan(text: 'ĐTN không ổn định'),
                  ]),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text('Xem hồ sơ', style: TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w600)),
              ),
            ]),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats').doc(_chatId).collection('messages')
                  .orderBy('timestamp').snapshots(),
              builder: (ctx, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: Color(0xFF1D4ED8)));
                final docs = snap.data!.docs;
                final myUid = FirebaseAuth.instance.currentUser?.uid ?? 'doctor';
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data = docs[i].data() as Map<String, dynamic>;
                    final isMe = (data['senderId'] ?? '') == myUid;
                    final ts = data['timestamp'] as Timestamp?;
                    final time = ts != null ? '${ts.toDate().hour.toString().padLeft(2, '0')}:${ts.toDate().minute.toString().padLeft(2, '0')}' : '';
                    return _BubbleRow(text: data['text'] ?? '', isMe: isMe, time: time, isRead: data['read'] ?? false,
                      senderInitial: patientName.split(' ').last.substring(0, 1));
                  },
                );
              },
            ),
          ),
          // Quick replies
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: _quickReplies.length,
              itemBuilder: (_, i) => GestureDetector(
                onTap: () => _send(_quickReplies[i]),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Text('✦ ', style: TextStyle(fontSize: 10, color: Color(0xFF1D4ED8))),
                    Text(_quickReplies[i], style: const TextStyle(fontSize: 12, color: Color(0xFF1D4ED8), fontWeight: FontWeight.w500)),
                  ]),
                ),
              ),
            ),
          ),
          // Input bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: SafeArea(
              top: false,
              child: Row(children: [
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Icons.add_rounded, color: Color(0xFF64748B), size: 24),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      style: const TextStyle(fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Trả lời bệnh nhân...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                      onSubmitted: _send,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _send(_msgCtrl.text),
                  child: Container(
                    width: 40, height: 40,
                    decoration: const BoxDecoration(color: Color(0xFF1D4ED8), shape: BoxShape.circle),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BubbleRow extends StatelessWidget {
  final String text, time, senderInitial;
  final bool isMe, isRead;
  const _BubbleRow({required this.text, required this.isMe, required this.time, required this.isRead, required this.senderInitial});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(radius: 14, backgroundColor: const Color(0xFF1D4ED8).withValues(alpha: 0.12),
              child: Text(senderInitial, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)))),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF1D4ED8) : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)],
                  ),
                  child: Text(text, style: TextStyle(fontSize: 14, color: isMe ? Colors.white : const Color(0xFF0F172A), height: 1.4)),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(time, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.done_all_rounded, size: 12, color: isRead ? const Color(0xFF1D4ED8) : const Color(0xFF94A3B8)),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
