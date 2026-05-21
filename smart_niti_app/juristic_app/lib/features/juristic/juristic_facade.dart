import 'package:firebase_auth/firebase_auth.dart';
import '../auth/adapters/auth_adapter.dart';
import '../../core/services/api_service.dart';
import '../home/models/ticket_model.dart';

class JuristicFacade {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ApiService _api = ApiService();

  // ─── Auth ───────────────────────────────────────────────────────
  Future<User?> login(AuthAdapter adapter) => adapter.login();
  Future<void> logout() => _auth.signOut();

  // ─── Tickets ────────────────────────────────────────────────────
  Future<List<TicketModel>> getTickets({String? reqUserId}) async {
    final raw = await _api.getTickets(reqUserId: reqUserId);
    return raw.map((j) => TicketModel.fromJson(j)).toList();
  }

  Future<TicketModel> getTicket(int ticketId) async {
    final raw = await _api.getTicket(ticketId);
    return TicketModel.fromJson(raw);
  }

  Future<TicketModel> updateTicketStatus(int ticketId, String status) async {
    final raw = await _api.updateTicketStatus(ticketId, status);
    return TicketModel.fromJson(raw);
  }

  Future<TicketModel> assignTicket(int ticketId, String technicianId) async {
    final raw = await _api.assignTicket(ticketId, technicianId);
    return TicketModel.fromJson(raw);
  }

  Future<TicketModel> unassignTicket(int ticketId) async {
    final raw = await _api.unassignTicket(ticketId);
    return TicketModel.fromJson(raw);
  }

  // ─── Users ──────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getUser(String uid) => _api.getUser(uid);
  Future<List<Map<String, dynamic>>> getTechnicians() => _api.getTechnicians();
  Future<List<Map<String, dynamic>>> getUsersByRole(String role) =>
      _api.getUsersByRole(role);
  Future<void> deleteUser(String uid) => _api.deleteUser(uid);

  // ─── Helpers ────────────────────────────────────────────────────
  // 🌟 เพิ่มฟังก์ชันนี้เพื่อดึง Token ไปให้รูปภาพ
  Future<Map<String, String>> getHeaders() => _api.getHeaders();

  Map<String, int> countByStatus(List<TicketModel> tickets) {
    final map = <String, int>{
      'submitted': 0,
      'assigned': 0,
      'in_progress': 0,
      'done': 0,
      'cancelled': 0,
    };
    for (final t in tickets) {
      switch (t.status) {
        case TicketStatus.submitted:
          map['submitted'] = (map['submitted'] ?? 0) + 1;
          break;
        case TicketStatus.assigned:
          map['assigned'] = (map['assigned'] ?? 0) + 1;
          break;
        case TicketStatus.inProgress:
          map['in_progress'] = (map['in_progress'] ?? 0) + 1;
          break;
        case TicketStatus.done:
          map['done'] = (map['done'] ?? 0) + 1;
          break;
        case TicketStatus.cancelled:
          map['cancelled'] = (map['cancelled'] ?? 0) + 1;
          break;
      }
    }
    return map;
  }
}
