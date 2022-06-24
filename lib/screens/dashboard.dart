import 'package:flutter/material.dart';
import 'package:intl_ui/screens/settings.dart';
import 'package:intl_ui/widgets/common/screen_widget.dart';
import 'package:intl_ui/widgets/dashboard/add_key_input.dart';
import 'package:intl_ui/widgets/dashboard/grid/grid.dart';
import 'package:intl_ui/widgets/dashboard/refresh_button.dart';

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
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(),
              const Text(
                'Intl UI',
                style: TextStyle(fontSize: 34),
              ),
              Row(
                children: [
                  const RefreshButton(),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context, builder: (_) => const Settings());
                    },
                    icon: const Icon(
                      Icons.settings,
                    ),
                  )
                ],
              )
            ],
          ),
          const SizedBox(
            height: 50,
          ),
          const AddKeyInput(),
          const SizedBox(
            height: 20,
          ),
          const Expanded(child: Grid())
        ],
      ),
    );
  }
}
