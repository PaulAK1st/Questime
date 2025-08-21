import 'package:flutter/material.dart';
import '../../../models/question_model.dart';

class PercentageScaleWidget extends StatefulWidget {
  final Question question;
  final Function(Question)? onUpdate;
  final bool isBuilder;

  const PercentageScaleWidget({
    super.key,
    required this.question,
    this.onUpdate,
    this.isBuilder = false,
  });

  @override
  State<PercentageScaleWidget> createState() => _PercentageScaleWidgetState();
}

class _PercentageScaleWidgetState extends State<PercentageScaleWidget> {
  late double _currentValue;
  late TextEditingController _minController;
  late TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    final min = widget.question.settings['min']?.toDouble() ?? 0.0;
    final max = widget.question.settings['max']?.toDouble() ?? 100.0;
    _currentValue = (min + max) / 2;
    _minController = TextEditingController(text: min.toInt().toString());
    _maxController = TextEditingController(text: max.toInt().toString());
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final min = widget.question.settings['min']?.toDouble() ?? 0.0;
    final max = widget.question.settings['max']?.toDouble() ?? 100.0;

    if (widget.isBuilder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scale Settings:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Min',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newMin = double.tryParse(value) ?? min;
                    if (newMin < max) {
                      _updateSetting('min', newMin);
                      _currentValue = (_currentValue < newMin) ? newMin : _currentValue;
                      _currentValue = (_currentValue > max) ? max : _currentValue;
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Max',
                    isDense: true,
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final newMax = double.tryParse(value) ?? max;
                    if (newMax > min) {
                      _updateSetting('max', newMax);
                      _currentValue = (_currentValue > newMax) ? newMax : _currentValue;
                      _currentValue = (_currentValue < min) ? min : _currentValue;
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Preview (Draggable):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildDraggableSlider(min, max, true),
        ],
      );
    }

    return _buildDraggableSlider(min, max, false);
  }

  Widget _buildDraggableSlider(double min, double max, bool isTestMode) {
    _currentValue = _currentValue.clamp(min, max);
    
    return Column(
      children: [
        Text(
          'Value: ${_currentValue.round()}%',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.blue,
            thumbColor: Colors.blue,
            overlayColor: Colors.blue,
            valueIndicatorColor: Colors.blue,
            valueIndicatorTextStyle: const TextStyle(color: Colors.white),
          ),
          child: Slider(
            value: _currentValue,
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: '${_currentValue.round()}%',
            onChanged: (value) {
              setState(() {
                _currentValue = value;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.round()}%', style: const TextStyle(fontSize: 12)),
            Text('${max.round()}%', style: const TextStyle(fontSize: 12)),
          ],
        ),
        if (isTestMode)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Drag the slider to test!',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  void _updateSetting(String key, dynamic value) {
    if (widget.onUpdate != null) {
      final settings = Map<String, dynamic>.from(widget.question.settings);
      settings[key] = value;
      widget.onUpdate!(widget.question.copyWith(settings: settings));
    }
  }
}
