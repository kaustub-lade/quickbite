import 'package:flutter/material.dart';

class PlatformFilterChip extends StatelessWidget {
  final String platform;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const PlatformFilterChip({
    super.key,
    required this.platform,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  Color _getPlatformColor() {
    switch (platform) {
      case 'swiggy':
        return const Color(0xFFFC8019);
      case 'zomato':
        return const Color(0xFFE23744);
      case 'ondc':
        return const Color(0xFF6366F1);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getPlatformColor();
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(
                Icons.check_circle,
                size: 18,
                color: color,
              ),
            if (isSelected) const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlatformFilterBar extends StatelessWidget {
  final String selectedPlatform;
  final Function(String) onPlatformSelected;

  const PlatformFilterBar({
    super.key,
    required this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Platform',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PlatformFilterChip(
                  platform: 'all',
                  label: 'All Platforms',
                  isSelected: selectedPlatform == 'all',
                  onTap: () => onPlatformSelected('all'),
                ),
                const SizedBox(width: 8),
                PlatformFilterChip(
                  platform: 'swiggy',
                  label: 'Swiggy',
                  isSelected: selectedPlatform == 'swiggy',
                  onTap: () => onPlatformSelected('swiggy'),
                ),
                const SizedBox(width: 8),
                PlatformFilterChip(
                  platform: 'zomato',
                  label: 'Zomato',
                  isSelected: selectedPlatform == 'zomato',
                  onTap: () => onPlatformSelected('zomato'),
                ),
                const SizedBox(width: 8),
                PlatformFilterChip(
                  platform: 'ondc',
                  label: 'ONDC',
                  isSelected: selectedPlatform == 'ondc',
                  onTap: () => onPlatformSelected('ondc'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
