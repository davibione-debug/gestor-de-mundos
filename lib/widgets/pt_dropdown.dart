import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class PTDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final ValueChanged<T?> onChanged;

  const PTDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: PTColors.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 5),

        Container(
          height: 52,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
          ),
          decoration: BoxDecoration(
            color: PTColors.lightBlue,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PTColors.border,
              width: 1.5,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: PTColors.surface,

              selectedItemBuilder: (context) {
                return items.map((item) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      itemLabel(item),
                      style: const TextStyle(
                        color: PTColors.text,
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList();
              },

              icon: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: PTColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 20,
                ),
              ),

              items: items.map((item) {
                return DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: const TextStyle(
                      color: PTColors.text,
                      fontSize: 16,
                    ),
                  ),
                );
              }).toList(),

              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
