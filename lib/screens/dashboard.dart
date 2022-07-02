import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:intl_ui/screens/settings.dart';
import 'package:intl_ui/widgets/common/screen_widget.dart';
import 'package:intl_ui/widgets/dashboard/add_key_input.dart';
import 'package:intl_ui/widgets/dashboard/grid/grid.dart';
import 'package:intl_ui/widgets/dashboard/refresh_button.dart';
import 'package:intl_ui/widgets/settings/select_project.dart';

class Dashboard extends ConsumerStatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final translationState = ref.watch(TranslationProvider.provider);

    return ScreenWidget(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Intl UI',
                style: TextStyle(fontSize: 34),
              ),
              const AddKeyInput(),
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
                  ),
                  IconButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => const SelectProject());
                    },
                    icon: const Icon(
                      Icons.grid_view,
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Grid(
              translationState: translationState,
            ),
          )
        ],
      ),
    );
  }
}
