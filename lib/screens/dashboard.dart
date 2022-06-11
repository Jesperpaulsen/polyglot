import 'package:flutter/material.dart';
import 'package:intl_ui/screens/settings.dart';
import 'package:intl_ui/widgets/common/screen_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return ScreenWidget(
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(),
              Text(
                'Intl UI',
                style: TextStyle(fontSize: 34),
              ),
              IconButton(
                  onPressed: () {
                    showDialog(context: context, builder: (_) => Settings());
                  },
                  icon: Icon(Icons.settings))
            ],
          ),
        ],
      ),
    );
  }
}
