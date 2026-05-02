import 'dart:io';

void main() {
  final dir = Directory('lib/presentation/screens/tutorial');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart')).toList();

  int updatedCount = 0;
  for (var file in files) {
    String content = file.readAsStringSync();
    bool changed = false;

    if (content.contains('Center(') && content.contains('child: FittedBox(')) {
      content = content.replaceAll(
        'Center(\n        child: FittedBox(',
        'SizedBox.expand(\n        child: FittedBox('
      ).replaceAll(
        'Center(\n            child: FittedBox(',
        'SizedBox.expand(\n            child: FittedBox('
      ).replaceAll(
        'Center(\r\n        child: FittedBox(',
        'SizedBox.expand(\r\n        child: FittedBox('
      ).replaceAll(
        'Center(\r\n            child: FittedBox(',
        'SizedBox.expand(\r\n            child: FittedBox('
      );
      changed = true;
    }

    if (changed) {
      file.writeAsStringSync(content);
      print('Updated ' + file.path);
      updatedCount++;
    }
  }
  print('Total files updated: ' + updatedCount.toString());
}
