import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/services/ticket_service.dart';

class EvidenceCard extends StatefulWidget {
  final String title;
  final bool isReadOnly;
  final int ticketId;

  /// 'resident' = รูปจากลูกบ้าน (read-only สำหรับช่าง)
  /// 'before'   = ก่อนซ่อม (ช่างอัปโหลด)
  /// 'after'    = หลังซ่อม (ช่างอัปโหลด)
  final String imageType;

  const EvidenceCard({
    super.key,
    required this.title,
    required this.ticketId,
    required this.imageType,
    this.isReadOnly = false,
  });

  @override
  State<EvidenceCard> createState() => _EvidenceCardState();
}

class _EvidenceCardState extends State<EvidenceCard> {
  File? _imageFile;
  String? _remoteUrl;
  bool _uploading = false;
  bool _loadingRemote = false;

  @override
  void initState() {
    super.initState();
    _loadRemoteImages();
  }

  Future<void> _loadRemoteImages() async {
    setState(() => _loadingRemote = true);
    try {
      final urls = await TicketService.getTicketImageUrls(
        widget.ticketId,
        imageType: widget.imageType,
      );
      if (!mounted) return;
      if (urls.isNotEmpty) {
        setState(() => _remoteUrl = urls.last);
      }
    } catch (_) {
      // ไม่มีรูป หรือ network error
    } finally {
      if (mounted) setState(() => _loadingRemote = false);
    }
  }

  Future<void> _pickAndUpload() async {
    if (widget.isReadOnly) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.photo_library_rounded,
                    color: Color(0xFF1677FF),
                  ),
                ),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(
                    Icons.camera_alt_rounded,
                    color: Color(0xFF1677FF),
                  ),
                ),
                title: const Text('Take a Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (picked == null) return;

    setState(() {
      _imageFile = File(picked.path);
      _uploading = true;
    });

    try {
      final bytes = await File(picked.path).readAsBytes();
      await TicketService.uploadImage(
        widget.ticketId,
        bytes,
        picked.name,
        imageType: widget.imageType,
      );
      if (!mounted) return;
      await _loadRemoteImages(); // refresh signed URL จาก server
      if (!mounted) return;
      setState(() => _uploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.title} photo uploaded'),
          backgroundColor: const Color(0xFF16A34A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _imageFile = null;
        _uploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  bool get _hasImage => _imageFile != null || _remoteUrl != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            if (_hasImage && !widget.isReadOnly) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle,
                color: Color(0xFF16A34A),
                size: 14,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: widget.isReadOnly ? null : _pickAndUpload,
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _hasImage
                    ? const Color(0xFF16A34A)
                    : Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: _buildContent(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_uploading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2),
            SizedBox(height: 10),
            Text(
              'Uploading...',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      );
    }
    if (_loadingRemote) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    // รูปที่เพิ่งเลือก (local)
    if (_imageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.file(_imageFile!, fit: BoxFit.cover),
          if (!widget.isReadOnly)
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickAndUpload,
                child: _changeBtn(),
              ),
            ),
        ],
      );
    }
    // รูปจาก server (signed URL)
    if (_remoteUrl != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            _remoteUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
            errorBuilder: (_, __, ___) => _noPhoto(),
          ),
          if (!widget.isReadOnly)
            Positioned(
              bottom: 8,
              right: 8,
              child: GestureDetector(
                onTap: _pickAndUpload,
                child: _changeBtn(),
              ),
            ),
        ],
      );
    }
    // ไม่มีรูป
    if (widget.isReadOnly) return _noPhoto();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add_a_photo_rounded,
            color: Color(0xFF1677FF),
            size: 22,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Upload Photo',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1677FF),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Tap to add',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
        ),
      ],
    );
  }

  Widget _changeBtn() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.6),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.edit, color: Colors.white, size: 12),
        SizedBox(width: 4),
        Text('Change', style: TextStyle(color: Colors.white, fontSize: 11)),
      ],
    ),
  );

  Widget _noPhoto() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.image_outlined, color: Colors.grey.shade300, size: 40),
      const SizedBox(height: 8),
      Text(
        'No Photo',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade400,
        ),
      ),
    ],
  );
}
