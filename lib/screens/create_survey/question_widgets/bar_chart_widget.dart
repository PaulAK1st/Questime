import 'package:flutter/material.dart';
import '../../../models/question_model.dart';

class BarChartWidget extends StatefulWidget {
  final Question question;
  final Function(Question)? onUpdate;
  final bool isBuilder;

  const BarChartWidget({
    super.key,
    required this.question,
    this.onUpdate,
    this.isBuilder = false,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  late List<TextEditingController> _variableControllers;
  late List<double> _percentages;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final variables = List<String>.from(widget.question.settings['variables'] ?? ['A', 'B', 'C']);
    final percentages = List<double>.from(widget.question.settings['percentages'] ?? [10.0, 40.0, 20.0]);
    
    _variableControllers = variables.map((variable) => TextEditingController(text: variable)).toList();
    _percentages = List.from(percentages);
    
   
    while (_percentages.length < _variableControllers.length) {
      _percentages.add(10.0);
    }
  }

  @override
  void dispose() {
    for (var controller in _variableControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isBuilder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Variables:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ..._variableControllers.asMap().entries.map((entry) {
            final index = entry.key;
            return _buildVariableEditor(index);
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addVariable,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Variable', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preview:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildChartPreview(),
        ],
      );
    }

    return _buildChartPreview();
  }

  Widget _buildVariableEditor(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Var',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              controller: _variableControllers[index],
              onChanged: (value) {
                _updateVariable(index, value);
              },
            ),
          ),
          const SizedBox(width: 8),
     // Percentage slider
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${_percentages[index].round()}%', 
                     style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _getBarColor(index),
                    thumbColor: _getBarColor(index),
                    overlayColor: _getBarColor(index),
                  ),
                  child: Slider(
                    value: _percentages[index],
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (value) {
                      setState(() {
                        _percentages[index] = value;
                      });
                      _updatePercentages();
                    },
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: _variableControllers.length > 2 ? () => _removeVariable(index) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildChartPreview() {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text(
            'Bar Chart Preview',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _variableControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final variable = entry.value.text.isEmpty ? 'Var${index + 1}' : entry.value.text;
                final percentage = _percentages[index];
                
                return _buildBar(variable, percentage, index);
              }).toList(),
            ),
          ),
          const SizedBox(height: 4),
          if (widget.isBuilder)
            Text(
              'Adjust sliders to see bars change!',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBar(String variable, double percentage, int index) {
    final availableHeight = 150.0; 
    final barHeight = (percentage / 100) * availableHeight;
    final color = _getBarColor(index);
    
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(minWidth: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 18,
              child: Text(
                '${percentage.round()}%',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 30,
              height: barHeight,
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 16,
              child: Text(
                variable,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBarColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.amber,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }

  void _addVariable() {
    if (widget.onUpdate != null) {
      _variableControllers.add(TextEditingController(text: 'New'));
      _percentages.add(10.0);
      _updateSettings();
    }
  }

  void _updateVariable(int index, String value) {
    if (widget.onUpdate != null) {
      _updateSettings();
    }
  }

  void _updatePercentages() {
    if (widget.onUpdate != null) {
      _updateSettings();
    }
  }

  void _removeVariable(int index) {
    if (widget.onUpdate != null && _variableControllers.length > 2) {
      _variableControllers[index].dispose();
      _variableControllers.removeAt(index);
      _percentages.removeAt(index);
      _updateSettings();
    }
  }

  void _updateSettings() {
    if (widget.onUpdate != null) {
      final variables = _variableControllers.map((controller) => controller.text).toList();
      final settings = Map<String, dynamic>.from(widget.question.settings);
      settings['variables'] = variables;
      settings['percentages'] = _percentages;
      widget.onUpdate!(widget.question.copyWith(settings: settings));
    }
  }
}