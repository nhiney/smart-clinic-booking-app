import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_clinic_booking/core/widgets/branded_app_bar.dart';
import 'package:smart_clinic_booking/features/support/presentation/controllers/support_controller.dart';
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';

class TicketListScreen extends ConsumerWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const BrandedAppBar(
        title: 'Yêu cầu hỗ trợ',
        showBackButton: true,
      ),
      body: Skeletonizer(
        enabled: state.isLoading,
        child: state.error != null
          ? _buildErrorState(ref, state.error!)
          : state.tickets.isEmpty && !state.isLoading
            ? _buildEmptyState(context, ref)
            : _buildTicketList(context, state.tickets),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketDialog(context, ref),
        label: const Text('Tạo yêu cầu', style: TextStyle(fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add),
        backgroundColor: const Color(0xFF2563EB),
      ),
    );
  }

  Widget _buildTicketList(BuildContext context, List<SupportTicket> tickets) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            onTap: () => context.push('/support/tickets/${ticket.id}', extra: ticket),
            contentPadding: const EdgeInsets.all(16),
            title: Text(ticket.subject, 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildStatusBadge(ticket.status),
                    const SizedBox(width: 8),
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(ticket.createdAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(TicketStatus status) {
    Color color;
    String text;
    switch (status) {
      case TicketStatus.open:
        color = Colors.blue;
        text = 'Mở';
        break;
      case TicketStatus.inProgress:
        color = Colors.orange;
        text = 'Đang xử lý';
        break;
      case TicketStatus.closed:
        color = Colors.green;
        text = 'Đóng';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, 
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.confirmation_num_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('Bạn chưa có yêu cầu hỗ trợ nào', 
            style: TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showCreateTicketDialog(context, ref),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white),
            child: const Text('Tạo yêu cầu ngay'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey)),
          TextButton(
            onPressed: () => ref.read(ticketProvider.notifier).loadTickets(),
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }

  void _showCreateTicketDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tạo yêu cầu hỗ trợ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nhập vấn đề bạn cần hỗ trợ...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              final ticketId = await ref.read(ticketProvider.notifier).createTicket(controller.text);
              if (context.mounted) {
                Navigator.pop(context);
                if (ticketId != null) {
                  context.push('/support/tickets/$ticketId');
                }
              }
            },
            child: const Text('Gửi yêu cầu'),
          ),
        ],
      ),
    );
  }
}
