import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/repair_request_provider.dart';

class Step1DetailsView extends StatelessWidget {
  const Step1DetailsView({super.key});

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
          TextField(
            onChanged: (val) => provider.updateDetails(title: val),
            decoration: _inputDecoration("Short description of the problem"),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("DETAILED DESCRIPTION"),
          const SizedBox(height: 10),
          TextField(
            onChanged: (val) => provider.updateDetails(description: val),
            maxLines: 4,
            decoration: _inputDecoration("Describe the issue in detail..."),
          ),

          const SizedBox(height: 25),
          _buildSectionTitle("LOCATION IN UNIT"),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: data.location,
                isExpanded: true,
                items: ["Master Bedroom", "Living Room", "Kitchen", "Bathroom"]
                    .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
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
          Row(
            children: [
              _buildImagePicker(context),
              const SizedBox(width: 10),
              // แสดงรูปที่เลือกมาแล้ว (ตัวอย่าง)
              if (data.images.isNotEmpty)
                ...data.images.map((file) => _buildImagePreview(file)).toList(),
            ],
          ),
          const SizedBox(height: 100), // กันปุ่มบัง
        ],
      ),
    );
  }

  // ส่วนหัวข้อ Text เล็กๆ สีเทา
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.blueGrey,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }

  // ดีไซน์ช่อง Input
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 1),
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
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade100,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue : Colors.blueGrey.shade300,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black54,
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
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade300,
          style: BorderStyle.none,
        ),
      ),
      child: const Icon(Icons.add_a_photo, color: Colors.grey),
    );
  }

  Widget _buildImagePreview(dynamic file) {
    return Container(
      width: 70,
      height: 70,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage("https://via.placeholder.com/70"), // ตัวอย่าง
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
