// lib/resident/features/repair_tracking/repair_tracking_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../repair_history/models/repair_ticket_model.dart';
import '../../core/app_config.dart';

class RepairTrackingPage extends StatefulWidget {
  final int ticketId;
  const RepairTrackingPage({super.key, required this.ticketId});

  @override
  State<RepairTrackingPage> createState() => _RepairTrackingPageState();
}

class _RepairTrackingPageState extends State<RepairTrackingPage> {
  RepairTicket? _ticket;
  List<String> _imageUrls = [];
  bool _isLoading = true;
  bool _isCancelling = false;
  String? _error;
  int _currentImagePage = 0;
  final PageController _pageController = PageController();

  // ── Rating state ─────────────────────────────────────────────────────────
  int? _existingRatingScore;
  String? _existingRatingComment;
  int? _selectedRating;
  bool _isSubmittingRating = false;
  final TextEditingController _commentController = TextEditingController();

  final double _inspectionFee = 200.0;
  final double _estimatedMaterialCost = 450.0;
  final _mockTechnician = {
    'name': 'Somchai Rakdee',
    'role': 'Senior Maintenance Specialist',
    'rating': 4.9,
    'repairs': 124,
  };

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    await Future.wait([_fetchTicket(), _fetchImages(), _fetchRating()]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchTicket() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/tickets/${widget.ticketId}'),
      );
      if (res.statusCode == 200) {
        if (mounted)
          setState(() => _ticket = RepairTicket.fromJson(jsonDecode(res.body)));
      } else {
        if (mounted)
          setState(() => _error = 'โหลดข้อมูลไม่สำเร็จ (${res.statusCode})');
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'เชื่อมต่อ Server ไม่ได้');
    }
  }

  Future<void> _fetchImages() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/tickets/${widget.ticketId}/images'),
      );
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            _imageUrls = data
                .map((e) => '${AppConfig.baseUrl}${e['image_url']}')
                .cast<String>()
                .toList();
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchRating() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.baseUrl}/tickets/${widget.ticketId}/rating'),
      );
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(res.body);
        setState(() {
          _existingRatingScore = data['score'] as int?;
          _existingRatingComment = data['comment'] as String?;
        });
      }
    } catch (_) {}
  }

  Future<void> _submitRating() async {
    if (_selectedRating == null) return;
    setState(() => _isSubmittingRating = true);
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.baseUrl}/tickets/${widget.ticketId}/rating'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'score': _selectedRating,
          'comment': _commentController.text.trim().isEmpty
              ? null
              : _commentController.text.trim(),
        }),
      );
      if (!mounted) return;
      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = jsonDecode(res.body);
        setState(() {
          _existingRatingScore = data['score'] as int?;
          _existingRatingComment = data['comment'] as String?;
          _selectedRating = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ขอบคุณสำหรับการให้คะแนน!'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
      } else {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['detail'] ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เชื่อมต่อ Server ไม่ได้'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmittingRating = false);
    }
  }

  Future<void> _cancelTicket() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cancel_outlined,
                  color: Color(0xFFEF4444),
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'ยกเลิกคำขอซ่อม?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'เมื่อยกเลิกแล้วจะไม่สามารถกู้คืนได้\nคุณยืนยันที่จะยกเลิกใช่หรือไม่?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'ไม่ยกเลิก',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFFEF4444),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'ยกเลิกคำขอ',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    try {
      final res = await http.patch(
        Uri.parse('${AppConfig.baseUrl}/tickets/${widget.ticketId}/cancel'),
      );

      if (!mounted) return;
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ยกเลิกคำขอซ่อมเรียบร้อยแล้ว'),
            backgroundColor: Color(0xFF16A34A),
          ),
        );
        await _fetchAll();
      } else {
        final body = jsonDecode(res.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(body['detail'] ?? 'เกิดข้อผิดพลาด'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('เชื่อมต่อ Server ไม่ได้'),
            backgroundColor: Color(0xFFEF4444),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Repair Tracking',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF94A3B8)),
            onPressed: _fetchAll,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF137FEC)),
            )
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'เกิดข้อผิดพลาด',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchAll,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF137FEC),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'ลองใหม่',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final ticket = _ticket!;
    final canCancel =
        ticket.assignedToId == null && !ticket.isDone && !ticket.isCancelled;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _fetchAll,
          color: const Color(0xFF137FEC),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(20, 16, 20, canCancel ? 104 : 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (ticket.showStatusStepper) ...[
                  _buildStatusSection(ticket),
                  const SizedBox(height: 20),
                ],
                _buildTicketInfoCard(ticket),
                const SizedBox(height: 20),
                _buildFeesCard(),
                const SizedBox(height: 20),
                _buildTechnicianCard(ticket),
                if (ticket.isDone) ...[
                  const SizedBox(height: 20),
                  _buildRatingSection(),
                ],
              ],
            ),
          ),
        ),
        if (canCancel)
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SafeArea(
              child: _isCancelling
                  ? Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton.icon(
                      onPressed: _cancelTicket,
                      icon: const Icon(
                        Icons.cancel_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        'ยกเลิกคำขอซ่อม',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        minimumSize: const Size(double.infinity, 54),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 4,
                        shadowColor: const Color(0xFFEF4444).withOpacity(0.4),
                      ),
                    ),
            ),
          ),
      ],
    );
  }

  // ── 1. Status Stepper ──────────────────────────────────────────────────────
  Widget _buildStatusSection(RepairTicket ticket) {
    // submitted และ cancelled ไม่แสดง Current Status
    if (!ticket.showStatusStepper) return const SizedBox.shrink();

    const steps = ['Assigned', 'In Progress', 'Done'];
    final activeStep = ticket.trackingStepIndex;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(steps.length, (i) {
              final isActive = i == activeStep;
              final isDone = i < activeStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(child: _buildStepChip(steps[i], isActive, isDone)),
                    if (i < steps.length - 1)
                      Container(
                        width: 4,
                        height: 2,
                        color: isDone || isActive
                            ? const Color(0xFF137FEC)
                            : const Color(0xFFE2E8F0),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepChip(String label, bool isActive, bool isCompleted) {
    Color bg, fg;
    if (isActive) {
      bg = const Color(0xFF137FEC);
      fg = Colors.white;
    } else if (isCompleted) {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF137FEC);
    } else {
      bg = const Color(0xFFF1F5F9);
      fg = const Color(0xFF94A3B8);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  // ── 2. Ticket Info Card ────────────────────────────────────────────────────
  Widget _buildTicketInfoCard(RepairTicket ticket) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPill(
            ticket.displayCategory,
            const Color(0xFFDBEAFE),
            const Color(0xFF137FEC),
          ),
          const SizedBox(height: 10),
          Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),

          // ── Images ──
          _buildImageCarousel(),
          const SizedBox(height: 16),

          if (ticket.detailDesc != null && ticket.detailDesc!.isNotEmpty) ...[
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              ticket.detailDesc!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF334155),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],

          _buildInfoRow(
            Icons.location_on_outlined,
            'Location',
            ticket.inUnitLocation,
            const Color(0xFF137FEC),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildDateBox(
                  Icons.calendar_today_outlined,
                  'Request Date',
                  ticket.formattedCreatedDate,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateBox(
                  Icons.schedule_outlined,
                  'Scheduled',
                  '${ticket.formattedDate}\n${ticket.formattedTimeSlot}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Image carousel with dot indicators ────────────────────────────────────
  Widget _buildImageCarousel() {
    if (_imageUrls.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image_outlined, size: 44, color: Color(0xFFCBD5E1)),
              SizedBox(height: 8),
              Text(
                'ไม่มีรูปภาพ',
                style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // PageView with images
        SizedBox(
          height: 210,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: _imageUrls.length,
                  onPageChanged: (i) => setState(() => _currentImagePage = i),
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => _openFullscreen(i),
                    child: Image.network(
                      _imageUrls[i],
                      fit: BoxFit.cover,
                      loadingBuilder: (_, child, progress) => progress == null
                          ? child
                          : Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF137FEC),
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFFF1F5F9),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            size: 44,
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Image count badge (top-right)
                if (_imageUrls.length > 1)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentImagePage + 1}/${_imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Expand icon (bottom-right)
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => _openFullscreen(_currentImagePage),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.fullscreen,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Dot indicators
        if (_imageUrls.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_imageUrls.length, (i) {
              final isActive = i == _currentImagePage;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? const Color(0xFF137FEC)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }

  void _openFullscreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            _FullscreenGallery(imageUrls: _imageUrls, initialIndex: index),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateBox(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: const Color(0xFF94A3B8)),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Fees Card ───────────────────────────────────────────────────────────
  Widget _buildFeesCard() {
    final total = _inspectionFee + _estimatedMaterialCost;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Service Fee & Costs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          _buildFeeRow(
            Icons.search_outlined,
            'Initial Inspection Fee',
            _inspectionFee,
            const Color(0xFFE8F3FE),
            const Color(0xFF137FEC),
          ),
          const SizedBox(height: 10),
          _buildFeeRow(
            Icons.construction_outlined,
            'Estimated Material Costs',
            _estimatedMaterialCost,
            const Color(0xFFF0FDF4),
            const Color(0xFF16A34A),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFDBEAFE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Estimated Cost',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A5F),
                    fontSize: 14,
                  ),
                ),
                Text(
                  '฿${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF137FEC),
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: const [
              Icon(Icons.info_outline, size: 11, color: Color(0xFF94A3B8)),
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'Final costs may vary based on actual work performed.',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(
    IconData icon,
    String label,
    double amount,
    Color iconBg,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, size: 15, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            '฿${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Technician Card ─────────────────────────────────────────────────────
  Widget _buildTechnicianCard(RepairTicket ticket) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assigned Technician',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          ticket.assignedToId == null
              ? Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF7ED),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFED7AA)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.schedule, size: 20, color: Color(0xFFF97316)),
                      SizedBox(width: 8),
                      Text(
                        'กำลังรอการมอบหมายช่าง...',
                        style: TextStyle(
                          color: Color(0xFFC2410C),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(
                        Icons.person,
                        size: 30,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _mockTechnician['name'] as String,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _mockTechnician['role'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${_mockTechnician['rating']} (${_mockTechnician['repairs']} repairs)',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Color(0xFF137FEC),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.phone,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  // ── 5. Rating Section ──────────────────────────────────────────────────────
  Widget _buildRatingSection() {
    final alreadyRated = _existingRatingScore != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'ให้คะแนนการซ่อม',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (alreadyRated) ...[
            // ── Already rated — read-only display ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (i) {
                          return Icon(
                            i < _existingRatingScore!
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: Colors.amber,
                            size: 28,
                          );
                        }),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${_existingRatingScore}/5',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ],
                  ),
                  if (_existingRatingComment != null &&
                      _existingRatingComment!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      '"${_existingRatingComment!}"',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF78350F),
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Text(
                    'คุณให้คะแนนแล้ว',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                  ),
                ],
              ),
            ),
          ] else ...[
            // ── Not yet rated — interactive ──
            const Text(
              'แตะดาวเพื่อให้คะแนน',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final starIndex = i + 1;
                final isFilled =
                    _selectedRating != null && starIndex <= _selectedRating!;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      // tap same star → reset to 0
                      _selectedRating = _selectedRating == starIndex
                          ? 0
                          : starIndex;
                    });
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFilled
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      key: ValueKey(isFilled),
                      color: isFilled ? Colors.amber : const Color(0xFFCBD5E1),
                      size: 44,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _selectedRating == null
                    ? 'ยังไม่ได้เลือก'
                    : _selectedRating == 0
                    ? '0 / 5 — ไม่พอใจเลย'
                    : _selectedRating == 1
                    ? '1 / 5 — ไม่ดี'
                    : _selectedRating == 2
                    ? '2 / 5 — พอใช้'
                    : _selectedRating == 3
                    ? '3 / 5 — ปานกลาง'
                    : _selectedRating == 4
                    ? '4 / 5 — ดี'
                    : '5 / 5 — ดีมาก!',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _selectedRating == null
                      ? const Color(0xFFCBD5E1)
                      : _selectedRating! >= 4
                      ? const Color(0xFF16A34A)
                      : _selectedRating! >= 2
                      ? const Color(0xFFF97316)
                      : const Color(0xFFDC2626),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 200,
              decoration: InputDecoration(
                hintText: 'เพิ่มความคิดเห็น (ไม่บังคับ)',
                hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 13,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.all(14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF137FEC)),
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_selectedRating == null || _isSubmittingRating)
                    ? null
                    : _submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF137FEC),
                  disabledBackgroundColor: const Color(0xFFE2E8F0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmittingRating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        'ส่งคะแนน',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(color: const Color(0xFFF1F5F9)),
    );
  }
}

// ── Fullscreen Gallery ────────────────────────────────────────────────────────
class _FullscreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const _FullscreenGallery({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late int _currentPage;
  late PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIndex;
    _ctrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentPage + 1} / ${widget.imageUrls.length}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _ctrl,
        itemCount: widget.imageUrls.length,
        onPageChanged: (i) => setState(() => _currentPage = i),
        itemBuilder: (_, i) => InteractiveViewer(
          child: Center(
            child: Image.network(
              widget.imageUrls[i],
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: 60,
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: widget.imageUrls.length > 1
          ? Container(
              color: Colors.black,
              padding: const EdgeInsets.only(bottom: 24, top: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.imageUrls.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _currentPage ? 20 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _currentPage ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            )
          : null,
    );
  }
}
