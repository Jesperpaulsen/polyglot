import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/models/internal_project_config.dart';
import 'package:polyglot/providers/translation_provider.dart';
import 'package:polyglot/services/config_handler.dart';
import 'package:polyglot/widgets/common/button.dart';
import 'package:polyglot/widgets/common/custom_icon_button.dart';

class SelectProject extends ConsumerWidget {
  const SelectProject({Key? key}) : super(key: key);

  Future<void> openProjectFromFolder(
      VoidCallback reloadTranslations, BuildContext context) async {
    final files = await FilePicker.platform
        .pickFiles(allowedExtensions: ['json'], type: FileType.custom);
    final result = files?.paths.first;
    if (result == null) {
      return;
    }
    _changePath(result, reloadTranslations, context);
  }

  _changePath(String newPath, VoidCallback reloadTranslations,
      BuildContext context) async {
    await ConfigHandler.instance.changeProject(newPath);
    reloadTranslations();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reloadTranslations =
        ref.read(TranslationProvider.provider.notifier).reloadTranslations;
    return Dialog(
      child: SizedBox(
        width: 800,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Projects',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Button(
                    onPressed: () =>
                        openProjectFromFolder(reloadTranslations, context),
                    label: 'Open new',
                  )
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              for (final project in ConfigHandler
                      .instance.internalConfig?.projects
                      .where((element) =>
                          element.id !=
                          ConfigHandler.instance.internalConfig
                              ?.internalProjectConfig?.id) ??
                  <InternalProjectConfig>[])
                GestureDetector(
                  onTap: () =>
                      _changePath(project.id, reloadTranslations, context),
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: Text(
                                project.path,
                              ),
                            ),
                          ),
                          CustomIconButton(
                            onPressed: () => _changePath(
                                project.id, reloadTranslations, context),
                            iconData: Icons.launch,
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          CustomIconButton(
                            onPressed: project.id !=
                                    ConfigHandler.instance.internalConfig
                                        ?.internalProjectConfig?.id
                                ? () => ConfigHandler.instance
                                    .removeProjectFromInternalConfig(project.id)
                                : null,
                            iconData: Icons.delete,
                            color: Colors.red,
                          )
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
