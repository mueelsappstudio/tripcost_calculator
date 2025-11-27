import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class TimeInput extends StatefulWidget {
  final String label;
  final int totalMinutes;
  final Function(int) onChanged;
  final IconData? icon;

  const TimeInput({
    super.key,
    required this.label,
    required this.totalMinutes,
    required this.onChanged,
    this.icon,
  });

  @override
  State<TimeInput> createState() => _TimeInputState();
}

class _TimeInputState extends State<TimeInput> {
  final TextEditingController _hrCtrl = TextEditingController();
  final TextEditingController _minCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncControllersWithType();
  }

  @override
  void didUpdateWidget(TimeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalMinutes != widget.totalMinutes) {
      _syncControllersWithType();
    }
  }

  @override
  void dispose() {
    _hrCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }

  void _syncControllersWithType() {
    int currentH = int.tryParse(_hrCtrl.text) ?? 0;
    int currentM = int.tryParse(_minCtrl.text) ?? 0;
    int totalCurrent = (currentH * 60) + currentM;

    if (totalCurrent != widget.totalMinutes) {
      int h = (widget.totalMinutes / 60).floor();
      int m = widget.totalMinutes % 60;

      if (h == 0 && _hrCtrl.text.isEmpty) {
        // keep empty
      } else {
        _hrCtrl.text = h == 0 ? "" : h.toString();
      }

      if (m == 0 && _minCtrl.text.isEmpty) {
        // keep empty
      } else {
        _minCtrl.text = m == 0 ? "" : m.toString();
      }
    }
  }

  void _handleInput() {
    int h = int.tryParse(_hrCtrl.text) ?? 0;
    int m = int.tryParse(_minCtrl.text) ?? 0;
    widget.onChanged((h * 60) + m);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(child: _buildField(_hrCtrl, "Hr")),
            const SizedBox(width: 8), // Reduced gap
            Expanded(child: _buildField(_minCtrl, "Min")),
          ],
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController ctrl, String suffix) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackground,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: ctrl,
            onChanged: (_) => _handleInput(),
            style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              hintText: "0",
              hintStyle: TextStyle(color: AppColors.textSecondary.withValues(alpha: 0.5)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              // FIX IS HERE: Reduced padding significantly to allow numbers to fit
              contentPadding: const EdgeInsets.only(left: 10, right: 30, top: 14, bottom: 14),
            ),
          ),
        ),
        Positioned(
          right: 8, // Moved closer to edge
          top: 0,
          bottom: 0,
          child: Center(
            child: Text(
              suffix.toUpperCase(),
              style: const TextStyle(
                fontSize: 9, // Slightly smaller font for label
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}