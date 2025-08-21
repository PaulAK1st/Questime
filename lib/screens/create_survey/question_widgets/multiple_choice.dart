// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../../models/question_model.dart';

class MultipleChoiceWidget extends StatefulWidget {
  final Question question;
  final Function(Question)? onUpdate;
  final bool isBuilder;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    this.onUpdate,
    this.isBuilder = false,
  });

  @override
  State<MultipleChoiceWidget> createState() => _MultipleChoiceWidgetState();
}

class _MultipleChoiceWidgetState extends State<MultipleChoiceWidget> {
  late List<TextEditingController> _controllers;
  String? _selectedValue; 
  final TextEditingController _otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final options = List<String>.from(widget.question.settings['options'] ?? []);
    _controllers = options.map((option) => TextEditingController(text: option)).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final options = List<String>.from(widget.question.settings['options'] ?? []);
    final allowOther = widget.question.settings['allowOther'] ?? false;

    if (widget.isBuilder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Options:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...options.asMap().entries.map((entry) {
            final index = entry.key;
            return _buildOptionEditor(index);
          }),
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Option', style: TextStyle(fontSize: 12)),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Checkbox(
                    value: allowOther,
                    onChanged: (value) {
                      _updateSetting('allowOther', value ?? false);
                    },
                  ),
                  const Text('"Other" option', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Preview:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildPreview(options, allowOther),
        ],
      );
    }

    return _buildPreview(options, allowOther);
  }

  Widget _buildPreview(List<String> options, bool allowOther) {
    return Column(
      children: [
        ...options.map((option) {
          return _buildRadioOption(option);
        }),
        if (allowOther) _buildOtherOption(),
      ],
    );
  }

  Widget _buildRadioOption(String option) {
    return InkWell(
      onTap: widget.isBuilder ? null : () {
        setState(() {
          _selectedValue = option;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Radio<String>(
              value: option,
              groupValue: _selectedValue,
              onChanged: widget.isBuilder ? null : (String? newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                option,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherOption() {
    const String otherValue = 'other';
    
    return InkWell(
      onTap: widget.isBuilder ? null : () {
        setState(() {
          _selectedValue = otherValue;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Row(
          children: [
            Radio<String>(
              value: otherValue,
              groupValue: _selectedValue,
              onChanged: widget.isBuilder ? null : (String? newValue) {
                setState(() {
                  _selectedValue = newValue;
                });
              },
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            const SizedBox(width: 8),
            const Text(
              'Other: ',
              style: TextStyle(fontSize: 16),
            ),
            Expanded(
              child: TextField(
                controller: _otherController,
                decoration: const InputDecoration(
                  hintText: 'Please specify...',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  border: OutlineInputBorder(),
                ),
                enabled: !widget.isBuilder,
                onTap: widget.isBuilder ? null : () {
                  setState(() {
                    _selectedValue = otherValue;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionEditor(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.radio_button_unchecked, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Option ${index + 1}',
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              controller: _controllers[index],
              onChanged: (value) {
                _updateOption(index, value);
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: _controllers.length > 2 ? () => _removeOption(index) : null,
          ),
        ],
      ),
    );
  }

  void _addOption() {
    if (widget.onUpdate != null) {
      final options = List<String>.from(widget.question.settings['options'] ?? []);
      options.add('New Option');
      _controllers.add(TextEditingController(text: 'New Option'));
      _updateSetting('options', options);
    }
  }

  void _updateOption(int index, String value) {
    if (widget.onUpdate != null) {
      final options = List<String>.from(widget.question.settings['options'] ?? []);
      options[index] = value;
      _updateSetting('options', options);
    }
  }

  void _removeOption(int index) {
    if (widget.onUpdate != null && _controllers.length > 2) {
      final options = List<String>.from(widget.question.settings['options'] ?? []);
      options.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _updateSetting('options', options);
    }
  }

  void _updateSetting(String key, dynamic value) {
    if (widget.onUpdate != null) {
      final settings = Map<String, dynamic>.from(widget.question.settings);
      settings[key] = value;
      widget.onUpdate!(widget.question.copyWith(settings: settings));
    }
  }
}