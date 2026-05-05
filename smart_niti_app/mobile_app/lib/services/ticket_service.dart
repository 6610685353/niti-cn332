import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_model.dart';

class TicketService {
  final String _baseUrl = 'https://your-backend-api.com/api/tickets'; //เดี๋ยวมาแก้

  Future<bool> createTicket(TicketModel ticket) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(ticket.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      } else {
        return false; 
      }
    } catch (e) {
      return false; 
    }
  }
}