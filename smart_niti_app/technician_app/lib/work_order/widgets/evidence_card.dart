import 'package:flutter/material.dart';

class EvidenceCard extends StatelessWidget {
  final String title;
  final bool isReadOnly;

  const EvidenceCard({Key? key, required this.title, this.isReadOnly = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 180,
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 1.5),
          ),
          child: Center(
            child: isReadOnly
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: Colors.grey.shade300,
                        size: 40,
                      ),
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
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: Colors.grey.shade400,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Photo',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
