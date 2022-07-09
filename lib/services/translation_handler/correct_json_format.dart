import 'dart:convert';
import 'dart:isolate';

class CorrectJsonFormatIsolateMessage {
  final SendPort port;
  final String json;

  CorrectJsonFormatIsolateMessage({required this.port, required this.json});
}

void correctJsonFormat(CorrectJsonFormatIsolateMessage message) {
  var res = '';

  final json = message.json;

  var numberOfQuotes = 0;

  if (json[0] != "{") {
    json.padLeft(1, "{");
  }

  if (json[json.length - 1] != "}") {
    json.padRight(1, "}");
  }

  var previousChar = "";

  for (var i = 0; i < json.length; i++) {
    final currentChar = json[i];

    if (numberOfQuotes == 4) {
      if (i == json.length - 1) {
        res += "}";
        break;
      }

      if (currentChar == " " && previousChar == '"') {
        continue;
      }

      if (currentChar != ",") {
        res += ",";
      }
      numberOfQuotes = 0;
    }

    if (currentChar == '"') {
      numberOfQuotes++;
    }

    res += currentChar;
    previousChar = currentChar;
  }

  final parsedJson = jsonDecode(res);

  final translationMap = Map<String, String?>.from(parsedJson);

  message.port.send(translationMap);
}
