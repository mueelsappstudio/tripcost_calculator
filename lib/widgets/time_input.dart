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
  late TextEditingController _hrCtrl;
  late TextEditingController _minCtrl;

  @override
  void initState() {
    super.initState();
    _updateControllers();
  }

  @override
  void didUpdateWidget(TimeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalMinutes != widget.totalMinutes) {
      // Sync with external changes only if the value actually changed logic
      // Ideally, we check focus, but for this app complexity, this is fine.
      _updateControllers();
    }
  }

  void _updateControllers() {
    int h = (widget.totalMinutes / 60).floor();
    int m = widget.totalMinutes % 60;

    // Only update text if it doesn't match to avoid cursor jumping if user is typing
    if (_hrCtrlIsDifferent(h)) {
      _hrCtrl = TextEditingController(text: h == 0 ? '' : h.toString());
    } else {
      // Fallback for init
      _hrCtrl = TextEditingController(text: h == 0 ? '' : h.toString());
    }

    _minCtrl = TextEditingController(text: m == 0 ? '' : m.toString());
  }

  bool _hrCtrlIsDifferent(int h) {
    try {
      return int.parse(_hrCtrl.text) != h;
    } catch (e) {
      return true;
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
            Expanded(
              child: _buildField(_hrCtrl, "Hr"),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildField(_minCtrl, "Min"),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildField(TextEditingController ctrl, String suffix) {
    return Stack(
      children: [
        TextFormField(
          controller: ctrl,
          onChanged: (_) => _handleInput(),
          style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textMain),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: "0",
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
            filled: true,
            fillColor: AppColors.inputBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.only(left: 16, right: 40, top: 14, bottom: 14),
          ),
        ),
        Positioned(
          right: 12,
          top: 0,
          bottom: 0,
          child: Center(
            child: Text(
              suffix.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
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