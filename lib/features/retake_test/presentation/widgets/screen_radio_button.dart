import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenRadioButton extends StatelessWidget {
  final String label;
  final String value;
  final String? selectedValue;
  final bool showInput;
  final TextEditingController controller;
  final ValueChanged<String> onSelected;
  final VoidCallback onTextChanged;

  const ScreenRadioButton({
    super.key,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.controller,
    required this.onSelected,
    required this.onTextChanged,
    this.showInput = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = selectedValue == value;

    return Column(
      children: [
        InkWell(
          onTap: () => onSelected(value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF252525),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      height: 1.30,
                      letterSpacing: -0.30,
                    ),
                  ),
                ),
                Radio<String>(
                  value: value,
                  groupValue: selectedValue,
                  activeColor: const Color(0xFF308BF9),
                  onChanged: (v) => onSelected(v!),
                ),
              ],
            ),
          ),
        ),

        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: (isSelected && showInput)
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 8),
            child: TextField(
              controller: controller,
              maxLines: 2,
              onChanged: (_) => onTextChanged(),
              style: const TextStyle(
                color: Color(0xFF252525),
                fontSize: 15,
                height: 1.0,
                letterSpacing: -0.30,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: "Why",
                hintStyle: const TextStyle(
                  color: Color(0xFFA1A1A1),
                  fontSize: 15,
                  height: 1.0,
                  letterSpacing: -0.30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
                enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Color(0xFFE1E6ED),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 1.2,
                    color: Color(0xFF308BF9), // optional focus color
                  ),
                ),
              ),
            ),
          )
              : const SizedBox.shrink(),
        ),

      ],
    );
  }
}
