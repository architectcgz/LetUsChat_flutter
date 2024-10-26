import 'package:flutter/material.dart';

class FileMessageBubble extends StatelessWidget {
  final String? fileUrl;
  final bool isUploading;
  final double fileSize; // bytes
  final String fileName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FileMessageBubble({
    super.key,
    this.fileUrl,
    required this.isUploading,
    required this.fileSize,
    required this.fileName,
    required this.onTap,
    required this.onLongPress,
  });

  String _formatFileSize(double size) {
    if (size < 1024) return '${size.toStringAsFixed(1)} B';
    if (size < 1048576) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / 1048576).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.insert_drive_file,
              color: Colors.blue,
              size: 40,
            ),
            const SizedBox(width: 10),
            // File name and size display
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(fileSize),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (isUploading) ...[
              const CircularProgressIndicator(),
            ] else if (fileUrl != null) ...[
              const Icon(
                Icons.download_done,
                color: Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
