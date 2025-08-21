import 'package:flutter/material.dart';
import '../../../models/question_model.dart';

class DraggableQuestionTool extends StatelessWidget {
  final IconData icon;
  final QuestionType type;
  final String tooltip;
  final VoidCallback onTap;

  const DraggableQuestionTool({
    super.key,
    required this.icon,
    required this.type,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Draggable<QuestionType>(
        data: type,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: QuestionTypeExtension(type).color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  spreadRadius: 2,
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: QuestionTypeExtension(type).color,
              size: 24,
            ),
          ),
        ),
        childWhenDragging: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[400]!),
          ),
          child: Icon(
            icon,
            color: Colors.grey[400],
            size: 20,
          ),
        ),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey,
                  spreadRadius: 1,
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: QuestionTypeExtension(type).color,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}

class QuestionDropZone extends StatefulWidget {
  final Function(QuestionType) onDropAccepted;
  final Widget child;
  final bool isEmpty;

  const QuestionDropZone({
    super.key,
    required this.onDropAccepted,
    required this.child,
    this.isEmpty = false,
  });

  @override
  State<QuestionDropZone> createState() => _QuestionDropZoneState();
}

class _QuestionDropZoneState extends State<QuestionDropZone> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<QuestionType>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        setState(() => _isDragOver = false);
        widget.onDropAccepted(details.data);
      },
      onMove: (details) => setState(() => _isDragOver = true),
      onLeave: (data) => setState(() => _isDragOver = false),
      builder: (context, candidateData, rejectedData) {
        if (widget.isEmpty) {
          return Container(
            width: double.infinity,
            height: 120,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: _isDragOver ? Colors.blue[50] : Colors.grey[100],
              border: Border.all(
                color: _isDragOver ? Colors.blue : Colors.grey[400]!,
                width: _isDragOver ? 2 : 1,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Dashed border effect when not dragging over
                if (!_isDragOver)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: DashedBorderPainter(
                        color: Colors.grey[400]!,
                        strokeWidth: 1,
                        dashWidth: 8,
                        dashSpace: 4,
                      ),
                    ),
                  ),
                // Content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isDragOver ? Icons.add_circle : Icons.add_circle_outline,
                        size: 32,
                        color: _isDragOver ? Colors.blue : Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Drag tools here to add questions\nor tap tools on the left',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: _isDragOver ? Colors.blue : Colors.grey[600],
                          fontWeight: _isDragOver ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: _isDragOver
                ? Border.all(color: Colors.blue, width: 2)
                : null,
            color: _isDragOver ? Colors.blue : null,
          ),
          child: widget.child,
        );
      },
    );
  }
}

// Custom painter for dashed border effect
class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(12),
      ));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics().toList();
    
    for (final pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final segment = pathMetric.extractPath(
          distance,
          distance + dashWidth,
        );
        canvas.drawPath(segment, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Extension to add colors to QuestionType
extension QuestionTypeExtension on QuestionType {
  Color get color {
    switch (this) {
      case QuestionType.textInput:
        return Colors.blue;
      case QuestionType.multipleChoice:
        return Colors.green;
      case QuestionType.percentageScale:
        return Colors.orange;
      case QuestionType.ranking:
        return Colors.purple;
      case QuestionType.barChart:
        return Colors.teal;
      case QuestionType.starRating:
        return Colors.amber;
      case QuestionType.fileUpload:
        return Colors.red;
    }
  }

  String get displayName {
    switch (this) {
      case QuestionType.textInput:
        return 'Text Input';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.percentageScale:
        return 'Percentage Scale';
      case QuestionType.ranking:
        return 'Ranking';
      case QuestionType.barChart:
        return 'Bar Chart';
      case QuestionType.starRating:
        return 'Star Rating';
      case QuestionType.fileUpload:
        return 'File Upload';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionType.textInput:
        return Icons.text_fields;
      case QuestionType.multipleChoice:
        return Icons.radio_button_checked;
      case QuestionType.percentageScale:
        return Icons.linear_scale;
      case QuestionType.ranking:
        return Icons.format_list_numbered;
      case QuestionType.barChart:
        return Icons.bar_chart;
      case QuestionType.starRating:
        return Icons.star;
      case QuestionType.fileUpload:
        return Icons.attach_file;
    }
  }
}