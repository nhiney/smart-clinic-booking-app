import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_clinic_booking/features/support/domain/entities/support_entities.dart';
import 'package:smart_clinic_booking/features/support/domain/repositories/support_repository.dart';
import 'package:smart_clinic_booking/features/support/data/repositories/support_repository_impl.dart';
import 'package:smart_clinic_booking/features/support/domain/usecases/support_usecases.dart';

// --- FAQ Provider ---

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepositoryImpl(
    firestore: FirebaseFirestore.instance,
  );
});

final getFAQsUseCaseProvider = Provider<GetFAQsUseCase>((ref) {
  return GetFAQsUseCase(ref.watch(supportRepositoryProvider));
});

class FAQState {
  final List<FAQ> faqs;
  final bool isLoading;
  final String? error;

  FAQState({this.faqs = const [], this.isLoading = false, this.error});
}

class FAQNotifier extends StateNotifier<FAQState> {
  final SupportRepository repository;
  FAQNotifier(this.repository) : super(FAQState());

  Future<void> loadFAQs({String? category, String? query}) async {
    state = FAQState(isLoading: true);
    final result = await repository.getFAQs(category: category, query: query);
    result.fold(
      (failure) => state = FAQState(error: failure.message),
      (faqs) => state = FAQState(faqs: faqs),
    );
  }
}

final faqProvider = StateNotifierProvider<FAQNotifier, FAQState>((ref) {
  return FAQNotifier(ref.watch(supportRepositoryProvider));
});

// --- Ticket Provider ---

class TicketState {
  final List<SupportTicket> tickets;
  final bool isLoading;
  final String? error;

  TicketState({this.tickets = const [], this.isLoading = false, this.error});
}

class TicketNotifier extends StateNotifier<TicketState> {
  final SupportRepository repository;
  TicketNotifier(this.repository) : super(TicketState());

  Future<void> loadTickets() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    state = TicketState(isLoading: true);
    final result = await repository.getUserTickets(user.uid);
    result.fold(
      (failure) => state = TicketState(error: failure.message),
      (tickets) => state = TicketState(tickets: tickets),
    );
  }

  Future<String?> createTicket(String subject) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final result = await repository.createTicket(user.uid, subject);
    return result.fold(
      (failure) {
        state = TicketState(error: failure.message, tickets: state.tickets);
        return null;
      },
      (ticketId) {
        loadTickets(); // Refresh list
        return ticketId;
      },
    );
  }
}

final ticketProvider = StateNotifierProvider<TicketNotifier, TicketState>((ref) {
  final repo = ref.watch(supportRepositoryProvider);
  return TicketNotifier(repo)..loadTickets();
});

// --- Message Provider (Family of Stream) ---

final ticketMessagesProvider = StreamProvider.family<List<SupportMessage>, String>((ref, ticketId) {
  return ref.watch(supportRepositoryProvider).streamMessages(ticketId);
});
