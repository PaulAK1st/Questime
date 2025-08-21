import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../models/question_model.dart';

class FileUploadWidget extends StatefulWidget {
  final Question question;
  final Function(Question)? onUpdate;
  final bool isBuilder;

  const FileUploadWidget({
    super.key,
    required this.question,
    this.onUpdate,
    this.isBuilder = false,
  });

  @override
  State<FileUploadWidget> createState() => _FileUploadWidgetState();
}

class _FileUploadWidgetState extends State<FileUploadWidget> {
  List<String> _uploadedFiles = [];

  @override
  Widget build(BuildContext context) {
    final allowMultiple = widget.question.settings['allowMultiple'] ?? false;

    if (widget.isBuilder) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'File Upload Settings:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: allowMultiple,
                onChanged: (value) {
                  _updateSetting('allowMultiple', value ?? false);
                },
              ),
              const Text('Allow multiple files', style: TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Preview:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 8),
          _buildUploadPreview(allowMultiple, true),
        ],
      );
    }

    return _buildUploadPreview(allowMultiple, false);
  }

  Widget _buildUploadPreview(bool allowMultiple, bool isTestMode) {
    return Column(
      children: [
        GestureDetector(
          onTap: isTestMode ? _handleFileUpload : null,
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isTestMode ? Colors.grey[50] : Colors.grey[100],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    size: 40,
                    color: isTestMode ? Colors.blue : Colors.grey,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Click to upload files',
                    style: TextStyle(
                      color: isTestMode ? Colors.blue : Colors.grey,
                      fontWeight: isTestMode ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    allowMultiple ? 'Multiple files allowed' : 'Single file only',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isTestMode)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '(Test upload functionality)',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Show uploaded files (for testing)
        if (_uploadedFiles.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              border: Border.all(color: Colors.green[200]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Uploaded Files:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._uploadedFiles.map((fileName) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(Icons.insert_drive_file, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          fileName,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      if (isTestMode)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _uploadedFiles.remove(fileName);
                            });
                          },
                          child: Icon(Icons.close, size: 16, color: Colors.grey[600]),
                        ),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _handleFileUpload() async {
    try {
      final allowMultiple = widget.question.settings['allowMultiple'] ?? false;
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: FileType.any,
      );

      if (result != null) {
        setState(() {
          if (allowMultiple) {
            // Add all selected files
            _uploadedFiles.addAll(
              result.files.map((file) => file.name).toList(),
            );
          } else {
            // Replace with single file
            _uploadedFiles = [result.files.first.name];
          }
        });

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                allowMultiple 
                    ? 'Files uploaded successfully! (${result.files.length} files)'
                    : 'File uploaded successfully!',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
