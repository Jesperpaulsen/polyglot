import 'package:flutter/material.dart';

class ScreenWidget extends StatelessWidget {
  final Widget body;
  const ScreenWidget({
    required this.body,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: body,
      ),
    );
  }
}
