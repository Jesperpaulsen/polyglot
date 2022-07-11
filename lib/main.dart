import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/screens/dashboard.dart';
import 'package:polyglot/services/config_handler.dart';
import 'package:polyglot/services/language_code_to_readable_name.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isWindows) {
    await DesktopWindow.setWindowSize(const Size(1280, 1000));
    await DesktopWindow.setMinWindowSize(const Size(600, 400));
  }

  await LanguageCodeToReadableName.instance.ensureInitialised();
  await ConfigHandler.instance.ensureInitialised();

  runApp(const ProviderScope(child: IntlUI()));
}

class IntlUI extends StatelessWidget {
  const IntlUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internalization UI',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.orange,
        backgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        backgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.dark,
      home: const Dashboard(),
    );
  }
}

class LoggingShortcutManager extends ShortcutManager {
  @override
  KeyEventResult handleKeypress(BuildContext context, RawKeyEvent event) {
    final KeyEventResult result = super.handleKeypress(context, event);
    if (result == KeyEventResult.handled) {
      print('Handled shortcut $event in $context');
    }
    return result;
  }
}
