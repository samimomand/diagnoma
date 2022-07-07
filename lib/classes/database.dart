import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'result.dart';

class DatabaseFileRoutines {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/diagnoma_local_persistence.json');
  }

  Future<String> readResults() async {
    try {
      final file = await _localFile;
      if (!file.existsSync()) {
        print('File does not exist: ${file.absolute}');
        await writeResults('{"results": []}');
      }

      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      print("error readResults: $e");
      return "";
    }
  }

  Future<File> writeResults(String json) async {
    final file = await _localFile;
    return file.writeAsString('$json');
  }
}

Database databaseFromJson(String str) {
  final dataFromJson = json.decode(str);
  return Database.fromJson(dataFromJson);
}

String databaseToJson(Database data) {
  final dataToJson = data.toJson();
  return json.encode(dataToJson);
}

class Database {
  List<Result> result;

  Database({required this.result});

  factory Database.fromJson(Map<String, dynamic> json) => Database(
        result:
            List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "results": List<dynamic>.from(result.map((x) => x.toJson())),
      };
}
