import 'package:firebase_auth/firebase_auth.dart';
import 'api_service.dart';
import '../../work_order/models/work.dart';
import '../../schedule/models/schedule_model.dart';

class TicketService {
  /// ดึง tickets ทั้งหมดที่ assign ให้ช่างคนนี้ (ทุก status)
  static Future<List<WorkOrder>> getMyTickets() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw ApiException(401, 'Not authenticated');

    final response =
        await ApiService.get('/tickets?assigned_to_id=$uid');
    final data = ApiService.handleResponse(response) as List<dynamic>;
    return data.map((json) => WorkOrder.fromJson(json as Map<String, dynamic>)).toList();
  }

  /// ดึง tickets เฉพาะที่ active (assigned + in_progress) สำหรับหน้า Home
  static Future<List<WorkOrder>> getActiveTickets() async {
    final all = await getMyTickets();
    return all
        .where((t) => t.status == 'Pending' || t.status == 'Repairing')
        .toList();
  }

  /// ดึง ticket เดี่ยว
  static Future<WorkOrder> getTicket(int backendId) async {
    final response = await ApiService.get('/tickets/$backendId');
    final data = ApiService.handleResponse(response) as Map<String, dynamic>;
    return WorkOrder.fromJson(data);
  }

  /// อัปเดต status ของ ticket
  /// backendStatus: 'in_progress' | 'done'
  static Future<WorkOrder> updateStatus(
      int backendId, String backendStatus) async {
    final response = await ApiService.patch(
      '/tickets/$backendId/status',
      queryParams: {'status': backendStatus},
    );
    final data = ApiService.handleResponse(response) as Map<String, dynamic>;
    return WorkOrder.fromJson(data);
  }

  /// อัปโหลดรูปหลักฐาน
  static Future<void> uploadImage(
      int ticketId, List<int> bytes, String filename) async {
    final response = await ApiService.postMultipart(
        '/tickets/$ticketId/images', bytes, filename);
    ApiService.handleResponse(response);
  }

  /// แปลง tickets เป็น ScheduleModel สำหรับหน้า Schedule
  static Future<List<ScheduleModel>> getSchedule() async {
    final tickets = await getMyTickets();
    return tickets
        .where((t) => t.status != 'Cancelled')
        .map((t) => ScheduleModel.fromWorkOrder(t))
        .toList();
  }
}
