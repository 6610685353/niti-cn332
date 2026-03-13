import 'package:flutter/material.dart';

class CustomInputField extends StatefulWidget {
  final String label;
  final String hint;
  final IconData icon;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomInputField({
    Key? key,
    required this.label,
    required this.hint,
    required this.icon,
    this.isPassword = false,
    this.controller,
  }) : super(key: key);

  @override
  State<CustomInputField> createState() => _CustomInputFieldState();
}

class _CustomInputFieldState extends State<CustomInputField> {
  bool _obscureText = true;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: Row(
            children: [
              // Icon ด้านหน้า
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Icon(widget.icon, color: Colors.blueGrey, size: 20),
              ),
              // เส้นกั้น
              Container(width: 1, height: 24, color: Colors.grey.shade300),
              const SizedBox(width: 12),
              // ช่องกรอก
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  obscureText: widget.isPassword ? _obscureText : false,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              // ปุ่ม เปิด-ปิด ตา Password
              if (widget.isPassword) ...[
                Container(width: 1, height: 24, color: Colors.grey.shade300),
                IconButton(
                  icon: Icon(
                    _obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.blueGrey,
                    size: 20,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
