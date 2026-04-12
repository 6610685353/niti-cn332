import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../provider/repair_request_provider.dart';

class Step1DetailsView extends StatelessWidget {
  const Step1DetailsView({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final provider = context.read<RepairRequestProvider>();

    // เช็คก่อนว่าครบ 4 รูปยัง
    if (provider.requestData.images.length >= 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Maximum 4 images allowed")));
      return;
    }

    final XFile? pickedFile = await picker.pickImage(
      source:
          ImageSource.gallery, // เลือกจากแกลเลอรี (หรือ .camera สำหรับกล้อง)
      imageQuality: 80, // บีบอัดเล็กน้อยเพื่อประหยัดพื้นที่
    );

    if (pickedFile != null) {
      provider.addImage(File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepairRequestProvider>();
    final data = provider.requestData;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle("ISSUE CATEGORY"),
          const SizedBox(height: 12),

          // Category Selection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryItem(
                context,
                "Plumbing",
                Icons.water_drop,
                data.category == "Plumbing",
              ),
              _buildCategoryItem(
                context,
                "Electric",
                Icons.bolt,
                data.category == "Electric",
              ),
              _buildCategoryItem(
                context,
                "HVAC",
                Icons.ac_unit,
                data.category == "HVAC",
              ),
              _buildCategoryItem(
                context,
                "Other",
                Icons.more_horiz,
                data.category == "Other",
              ),
            ],
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("ISSUE TITLE"),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => provider.updateDetails(title: val),
              decoration: _inputDecoration("Short description of the problem"),
            ),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("DETAILED DESCRIPTION"),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              onChanged: (val) => provider.updateDetails(description: val),
              maxLines: 4,
              decoration: _inputDecoration("Describe the issue in detail..."),
            ),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("LOCATION IN UNIT"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4,
            ), // เพิ่ม Vertical padding เล็กน้อย
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
              ), // เพิ่มเส้นขอบให้อ่อนๆ
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: data.location,
                isExpanded: true,

                // 1. ตกแต่ง Icon ลูกศร
                icon: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF64748B),
                ),

                // 2. ตกแต่ง Text ที่แสดงผลตอนเลือกแล้ว
                style: const TextStyle(
                  color: Color(0xFF1E293B), // สีน้ำเงินเข้มเกือบดำ
                  fontSize: 15,
                  fontWeight: FontWeight.w500, // ถ้าคุณมี Font Custom
                ),

                // 3. ตกแต่งพื้นหลังของเมนูที่เด้งลงมา
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12), // ความมนของตัวเมนู

                items: ["Master Bedroom", "Living Room", "Kitchen", "Bathroom"]
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Row(
                          children: [
                            // เพิ่ม Icon หน้าชื่อสถานที่เพื่อให้ดูสวยขึ้น
                            const Icon(
                              Icons.location_on,
                              size: 24,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              value,
                              style: const TextStyle(
                                color: Color(0xFF0F172A), // สี Slate 600
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    })
                    .toList(),
                onChanged: (val) => provider.updateDetails(location: val),
              ),
            ),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("UPLOAD IMAGES (MAX 4)"),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              GestureDetector(
                onTap: () => _pickImage(context),
                child: _buildImagePicker(context),
              ),
              ...data.images.asMap().entries.map((entry) {
                int index = entry.key;
                File file = entry.value;
                return _buildImagePreview(
                  file,
                  () => provider.removeImage(index),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  // ส่วนหัวข้อ Text เล็กๆ สีเทา
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  // ดีไซน์ช่อง Input
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
      ),
    );
  }

  // ปุ่มเลือกหมวดหมู่ (Category Card)
  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
  ) {
    final color = _getCategoryColor(title);

    return GestureDetector(
      onTap: () {
        context.read<RepairRequestProvider>().updateDetails(category: title);
      },
      child: Container(
        width: 75,
        height: 85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: Color(0xFF3B82F6), width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Color(0XFF000000) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ปุ่มกดเพื่อเลือกรูป
  Widget _buildImagePicker(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, color: Color(0xFF94A3B8), size: 30),
          SizedBox(height: 4),
          Text(
            "ADD PHOTO",
            style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(File file, VoidCallback onDelete) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            image: DecorationImage(image: FileImage(file), fit: BoxFit.cover),
          ),
        ),

        // ปุ่มลบ (ลอย + มีเงา)
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onDelete,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Color(0xFF94A3B8),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case "Plumbing":
        return Color(0xFF3B82F6);
      case "Electric":
        return Color(0xFFF59E0B);
      case "HVAC":
        return Color(0xFF10B981);
      case "Other":
        return Color(0xFFF43F5E);
      default:
        return Colors.grey;
    }
  }
}
