import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/providers/translation_provider.dart';
import 'package:polyglot/screens/settings.dart';
import 'package:polyglot/widgets/common/screen_widget.dart';
import 'package:polyglot/widgets/dashboard/add_key_input.dart';
import 'package:polyglot/widgets/dashboard/grid/grid.dart';
import 'package:polyglot/widgets/dashboard/refresh_button.dart';
import 'package:polyglot/widgets/settings/select_project.dart';

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
                'Polyglot',
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
