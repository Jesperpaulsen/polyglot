import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:intl_ui/services/grid_builder.dart';
import 'package:pluto_grid/pluto_grid.dart';

class Grid extends ConsumerStatefulWidget {
  final TranslationState translationState;
  const Grid({
    required this.translationState,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<Grid> createState() => _GridState();
}

class _GridState extends ConsumerState<Grid> {
  var rows = <PlutoRow>[];
  var columns = <PlutoColumn>[];
  var _internalVersion = 0;

  _buildGrid() {
    final builderResult = GridBuilder(context).buildGridFromTranslationKeys(
      translationKeys: widget.translationState.translationKeys,
      translationManagers: widget.translationState.translations,
    );
    setState(() {
      rows = builderResult.rows;
      columns = builderResult.columns;
    });
  }

  @override
  void initState() {
    super.initState();
    _buildGrid();
  }

  @override
  void didUpdateWidget(covariant Grid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.translationState.version != widget.translationState.version) {
      print(
          '[New version, Grid reloading]: ${oldWidget.translationState.version}, ${widget.translationState.version}');
      _buildGrid();
      setState(() {
        _internalVersion += 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final translationProvider = ref.read(TranslationProvider.provider.notifier);
    return PlutoGrid(
      key: Key(_internalVersion.toString()),
      onLoaded: (PlutoGridOnLoadedEvent event) {
        event.stateManager.setShowColumnFilter(true);
      },
      columns: columns,
      rows: rows,
      configuration: PlutoGridConfiguration(
        columnFilterConfig: PlutoGridColumnFilterConfig(
          resolveDefaultColumnFilter: (column, resolver) =>
              resolver<PlutoFilterTypeContains>() as PlutoFilterType,
        ),
      ),
      onChanged: (event) {
        print(event);
        if (event.columnIdx == 0) {
          translationProvider.updateTranslationKey(
            oldTranslationKey: event.oldValue,
            newTranslationKey: event.value,
          );
          return;
        }
        translationProvider.updateTranslation(
          translationKey: event.row?.cells['translation_key']?.value,
          translationCode: event.column!.field,
          newValue: event.value,
        );
      },
    );
  }
}
