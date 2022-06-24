import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/grid_provider.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:pluto_grid/pluto_grid.dart';

class Grid extends ConsumerStatefulWidget {
  const Grid({Key? key}) : super(key: key);

  @override
  ConsumerState<Grid> createState() => _GridState();
}

class _GridState extends ConsumerState<Grid> {
  var rows = <PlutoRow>[];
  var columns = <PlutoColumn>[];

  @override
  Widget build(BuildContext context) {
    final gridState = ref.watch(GridStateProvider.provider);
    final translationProvider = ref.read(TranslationProvider.provider.notifier);
    return PlutoGrid(
      key: Key(
          '${gridState.key - gridState.columns.length - gridState.rows.length}'),
      onLoaded: (PlutoGridOnLoadedEvent event) {
        event.stateManager.setShowColumnFilter(true);
      },
      columns: gridState.columns,
      rows: gridState.rows,
      configuration: PlutoGridConfiguration(
        columnFilterConfig: PlutoGridColumnFilterConfig(
          resolveDefaultColumnFilter: (column, resolver) =>
              resolver<PlutoFilterTypeContains>() as PlutoFilterType,
        ),
      ),
      onChanged: (event) {
        if (event.columnIdx == 0) {
          translationProvider.updateTranslationKey(
            oldTranslationKey: event.oldValue,
            newTranslationKey: event.value,
          );
          return;
        }
        print(event.row?.cells['translation_key']?.value);
        translationProvider.updateTranslation(
          translationKey: event.row?.cells['translation_key']?.value,
          translationCode: event.column!.field,
          newValue: event.value,
        );
      },
    );
  }
}
