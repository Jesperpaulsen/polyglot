import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:intl_ui/screens/dashboard.dart';
import 'package:intl_ui/services/config_handler.dart';
import 'package:intl_ui/services/language_code_to_readable_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindow.setWindowSize(const Size(1280, 1000));
  await DesktopWindow.setMinWindowSize(const Size(400, 400));
  await LanguageCodeToReadableName.instance.ensureInitialised();
  await ConfigHandler.instance.ensureInitialised();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internalization UI',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Dashboard(),
    );
  }
}
