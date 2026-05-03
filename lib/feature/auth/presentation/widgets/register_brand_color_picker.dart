import 'package:flutter/material.dart';

class RegisterBrandColorPicker extends StatelessWidget {
  const RegisterBrandColorPicker({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onSelected,
  });

  final List<Color> colors;
  final Color selectedColor;
  final ValueChanged<Color> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        for (final color in colors)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => onSelected(color),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selectedColor == color
                      ? Colors.black87
                      : Colors.black26,
                  width: selectedColor == color ? 3 : 1,
                ),
              ),
            ),
          ),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black87, width: 1.5),
          ),
          child: const Icon(Icons.palette_outlined, size: 20),
        ),
      ],
    );
  }
}
