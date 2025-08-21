import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

class LocalStorageService {
  static const Uuid _uuid = Uuid();

  // Get app documents directory
  Future<Directory> get _documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  // Get app cache directory
  Future<Directory> get _cacheDirectory async {
    return await getTemporaryDirectory();
  }

  // Create directory if doesn't exist
  Future<Directory> _ensureDirectoryExists(String folderPath) async {
    final directory = Directory(folderPath);
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  // Helper to get filename from path
  String _getFileName(String filePath) {
    if (Platform.isWindows) {
      return filePath.split('\\').last;
    } else {
      return filePath.split('/').last;
    }
  }

  // Save banner image local
  Future<String> saveBanner(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) throw Exception('File does not exist');

      final docsDir = await _documentsDirectory;
      final bannersDir = await _ensureDirectoryExists('${docsDir.path}/banners');
      
      final fileName = '${_uuid.v4()}.jpg';
      final newPath = '${bannersDir.path}/$fileName';
      
      await file.copy(newPath);
      
      if (kDebugMode) {
        print('Banner saved locally: $newPath');
      }
      
      return newPath;
    } catch (e) {
      throw Exception('Error saving banner: $e');
    }
  }

  // Save profile picture local
  Future<String> saveProfilePicture(String imagePath, String userId) async {
    try {
      final file = File(imagePath);
      if (!file.existsSync()) throw Exception('File does not exist');

      final docsDir = await _documentsDirectory;
      final profilesDir = await _ensureDirectoryExists('${docsDir.path}/profiles/$userId');
      
      final fileName = '${userId}_profile.jpg';
      final newPath = '${profilesDir.path}/$fileName';
      
      await file.copy(newPath);
      
      if (kDebugMode) {
        print('Profile picture saved locally: $newPath');
      }
      
      return newPath;
    } catch (e) {
      throw Exception('Error saving profile picture: $e');
    }
  }

  // Save survey file local
  Future<String> saveSurveyFile(String filePath, String surveyId) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) throw Exception('File does not exist');

      final docsDir = await _documentsDirectory;
      final uploadsDir = await _ensureDirectoryExists('${docsDir.path}/uploads/$surveyId');
      
      final originalFileName = _getFileName(filePath);
      final fileName = '${_uuid.v4()}_$originalFileName';
      final newPath = '${uploadsDir.path}/$fileName';
      
      await file.copy(newPath);
      
      if (kDebugMode) {
        print('Survey file saved locally: $newPath');
      }
      
      return newPath;
    } catch (e) {
      throw Exception('Error saving survey file: $e');
    }
  }

  // Delete file from local storage
  Future<void> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        if (kDebugMode) {
          print('File deleted: $filePath');
        }
      }
    } catch (e) {
      throw Exception('Error deleting file: $e');
    }
  }

  // Get file info
  Future<Map<String, dynamic>> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }
      
      final stat = await file.stat();
      final fileName = _getFileName(filePath);
      final fileSize = stat.size;
      final lastModified = stat.modified;
      
      return {
        'name': fileName,
        'path': filePath,
        'size': fileSize,
        'sizeInMB': (fileSize / (1024 * 1024)).toStringAsFixed(2),
        'lastModified': lastModified.toIso8601String(),
        'exists': true,
      };
    } catch (e) {
      throw Exception('Error getting file info: $e');
    }
  }

  // Save image from XFile
  Future<String> saveImageFromXFile(XFile imageFile, String folder) async {
    try {
      final docsDir = await _documentsDirectory;
      final targetDir = await _ensureDirectoryExists('${docsDir.path}/$folder');
      
      final fileName = '${_uuid.v4()}.jpg';
      final newPath = '${targetDir.path}/$fileName';
      
      await imageFile.saveTo(newPath);
      
      if (kDebugMode) {
        print('Image saved from XFile: $newPath');
      }
      
      return newPath;
    } catch (e) {
      throw Exception('Error saving image from XFile: $e');
    }
  }

  // List files in a directory
  Future<List<String>> listFiles(String folderName) async {
    try {
      final docsDir = await _documentsDirectory;
      final directory = Directory('${docsDir.path}/$folderName');
      
      if (!await directory.exists()) {
        return [];
      }
      
      final files = await directory.list().toList();
      return files
          .whereType<File>()
          .map((file) => file.path)
          .toList();
    } catch (e) {
      throw Exception('Error listing files: $e');
    }
  }

  // Check if file exists
  Future<bool> fileExists(String filePath) async {
    try {
      final file = File(filePath);
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // Clean up old files
  Future<void> cleanupOldFiles(String folderName, Duration maxAge) async {
    try {
      final docsDir = await _documentsDirectory;
      final directory = Directory('${docsDir.path}/$folderName');
      
      if (!await directory.exists()) {
        return;
      }
      
      final cutoffDate = DateTime.now().subtract(maxAge);
      final files = await directory.list().toList();
      
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            if (kDebugMode) {
              print('Deleted old file: ${entity.path}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error cleaning up old files: $e');
      }
    }
  }

  // Get storage usage statistics
  Future<Map<String, dynamic>> getStorageStats() async {
    try {
      final docsDir = await _documentsDirectory;
      int totalFiles = 0;
      int totalSize = 0;
      
      final folders = ['banners', 'profiles', 'uploads'];
      
      for (final folder in folders) {
        final directory = Directory('${docsDir.path}/$folder');
        if (await directory.exists()) {
          final files = await directory.list(recursive: true).toList();
          
          for (final entity in files) {
            if (entity is File) {
              totalFiles++;
              final stat = await entity.stat();
              totalSize += stat.size;
            }
          }
        }
      }
      
      return {
        'totalFiles': totalFiles,
        'totalSizeBytes': totalSize,
        'totalSizeMB': (totalSize / (1024 * 1024)).toStringAsFixed(2),
        'storageLocation': docsDir.path,
      };
    } catch (e) {
      throw Exception('Error getting storage stats: $e');
    }
  }

  // Copy file to cache (for temporary files)
  Future<String> copyToCache(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Source file does not exist');
      }
      
      final cacheDir = await _cacheDirectory;
      final fileName = _getFileName(filePath);
      final newPath = '${cacheDir.path}/$fileName';
      
      await file.copy(newPath);
      
      if (kDebugMode) {
        print('File copied to cache: $newPath');
      }
      
      return newPath;
    } catch (e) {
      throw Exception('Error copying file to cache: $e');
    }
  }

  // Clear all cached files
  Future<void> clearCache() async {
    try {
      final cacheDir = await _cacheDirectory;
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
        if (kDebugMode) {
          print('Cache cleared');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing cache: $e');
      }
    }
  }

  // Get app data directory path
  Future<String> getDataDirectoryPath() async {
    final docsDir = await _documentsDirectory;
    return docsDir.path;
  }

  // Batch operations 
  Future<List<String>> saveBatchImages(List<String> imagePaths, String folder) async {
    final savedPaths = <String>[];
    
    try {
      for (final imagePath in imagePaths) {
        final savedPath = await saveImageFromXFile(
          XFile(imagePath), 
          folder
        );
        savedPaths.add(savedPath);
      }
      
      if (kDebugMode) {
        print('Batch saved ${savedPaths.length} images to $folder');
      }
      
      return savedPaths;
    } catch (e) {
      throw Exception('Error in batch save: $e');
    }
  }

  // Get directory size
  Future<int> getDirectorySize(String folderName) async {
    try {
      final docsDir = await _documentsDirectory;
      final directory = Directory('${docsDir.path}/$folderName');
      
      if (!await directory.exists()) {
        return 0;
      }
      
      int totalSize = 0;
      final files = await directory.list(recursive: true).toList();
      
      for (final entity in files) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }
      
      return totalSize;
    } catch (e) {
      return 0;
    }
  }

  // Check available storage space
  Future<Map<String, dynamic>> getStorageInfo() async {
    try {
      final docsDir = await _documentsDirectory;
      final stats = await getStorageStats();
      
      return {
        'usedSpace': stats['totalSizeBytes'],
        'usedSpaceMB': stats['totalSizeMB'],
        'location': docsDir.path,
        'totalFiles': stats['totalFiles'],
      };
    } catch (e) {
      throw Exception('Error getting storage info: $e');
      }
    }
  }
