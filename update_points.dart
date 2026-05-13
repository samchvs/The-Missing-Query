import 'dart:io';

void main() {
  final dir = Directory('lib/presentation/screens/mystery');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;
    
    final filename = file.uri.pathSegments.last;
    if (!filename.contains('_screen.dart')) continue;
    
    final locationId = filename.replaceAll('_screen.dart', '');
    
    if (content.contains('addPoints(')) {
      content = content.replaceAllMapped(
        RegExp(r'PointsController\.instance\.addPoints\((\d+)\)'),
        (match) => "PointsController.instance.addLocationScore('$locationId', ${match.group(1)})"
      );
      changed = true;
    }
    
    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ${file.path}');
    }
  }
}
