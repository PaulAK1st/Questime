import 'package:flutter/material.dart';
import '../../../models/question_model.dart';
//import '../../create_survey/question_widgets/drag_drop_tools.dart';

class RankingWidget extends StatefulWidget {
  final Question question;
  final Function(Question)? onUpdate;
  final bool isBuilder;

  const RankingWidget({
    super.key,
    required this.question,
    this.onUpdate,
    this.isBuilder = false,
  });

@override
  State<RankingWidget> createState() => _RankingWidgetState();
}

class _RankingWidgetState extends State<RankingWidget> {
  late List<TextEditingController> _controllers;
  late List<String> _previewItems;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _previewItems = List<String>.from(widget.question.settings['items'] ?? []);
  }

  void _initializeControllers() {
    final items = List<String>.from(widget.question.settings['items'] ?? []);
    _controllers = items.map((item) => TextEditingController(text: item)).toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

@override
Widget build(BuildContext context) {
    final items = List<String>.from(widget.question.settings['items'] ?? []);

    if (widget.isBuilder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ranking Items:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            return _buildItemEditor(index);
          }),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: _addItem,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Item', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(height: 16),
          const Text(
            'Preview (Drag to reorder):',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildDraggablePreview(),
        ],
      );
    }

    return _buildDraggablePreview();
  }

Widget _buildItemEditor(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                (index + 1).toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
        Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Item ${index + 1}',
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              controller: _controllers[index],
              onChanged: (value) {
                _updateItem(index, value);
                setState(() {
                  _previewItems[index] = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.drag_handle, color: Colors.grey),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: _controllers.length > 2 ? () => _removeItem(index) : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDraggablePreview() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _previewItems.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            final item = _previewItems.removeAt(oldIndex);
            _previewItems.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          return _buildRankingItem(_previewItems[index], index + 1, index);
        },
        footer: widget.isBuilder
            ? Container(
                key: const ValueKey('footer'),
                padding: const EdgeInsets.all(8),
                child: Text(
                  'Drag items to reorder them',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            : null,
      ),
    );
    }

Widget _buildRankingItem(String item, int rank, int index) {
  return Container(
    key: ValueKey('$item-$index'),
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            // 
            ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle, color: Colors.grey),
            ),
          ],
        ),
      ),
    ),
  );
}


  void _addItem() {
    if (widget.onUpdate != null) {
      final items = List<String>.from(widget.question.settings['items'] ?? []);
      items.add('New Item');
      _controllers.add(TextEditingController(text: 'New Item'));
      setState(() {
        _previewItems.add('New Item');
      });
      _updateSetting('items', items);
    }
  }

  void _updateItem(int index, String value) {
    if (widget.onUpdate != null) {
      final items = List<String>.from(widget.question.settings['items'] ?? []);
      items[index] = value;
      _updateSetting('items', items);
    }
  }

  void _removeItem(int index) {
    if (widget.onUpdate != null && _controllers.length > 2) {
      final items = List<String>.from(widget.question.settings['items'] ?? []);
      items.removeAt(index);
      _controllers[index].dispose();
      _controllers.removeAt(index);
      setState(() {
        _previewItems.removeAt(index);
      });
      _updateSetting('items', items);
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
