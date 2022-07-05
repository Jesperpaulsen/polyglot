import 'package:flutter/material.dart';
import 'package:intl_ui/models/translation_manager.dart';
import 'package:intl_ui/widgets/dashboard/grid/delete_row_dialog.dart';
import 'package:pluto_grid/pluto_grid.dart';

class GridBuilderResult {
  List<PlutoRow> rows;
  List<PlutoColumn> columns;

  GridBuilderResult({
    required this.rows,
    required this.columns,
  });
}

class GridBuilder {
  final BuildContext _context;
  final Future<String?> Function({
    required String translationKey,
    required String intlCode,
  }) translateString;

  GridBuilder(
    this._context,
    this.translateString,
  );

  GridBuilderResult buildGridFromTranslationKeys({
    required Set<String> translationKeys,
    required Map<String, TranslationManager> translationManagers,
  }) {
    final columns = [
      PlutoColumn(
          frozen: PlutoColumnFrozen.left,
          title: 'Translation key',
          field: 'translation_key',
          type: PlutoColumnType.text(),
          enableColumnDrag: false,
          width: 350,
          minWidth: 250,
          renderer: (rendererContext) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    rendererContext
                        .row.cells[rendererContext.column.field]!.value
                        .toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  onPressed: () async {
                    showDialog(
                      context: _context,
                      builder: (_) => DeleteRowDialog(
                        translationKey: rendererContext
                            .row.cells[rendererContext.column.field]!.value
                            .toString(),
                        deleteCallback: () {
                          rendererContext.stateManager.removeRows(
                            [rendererContext.row],
                          );
                        },
                      ),
                    );
                  },
                  iconSize: 18,
                  color: Colors.red,
                  padding: const EdgeInsets.all(0),
                ),
              ],
            );
          }),
    ];
    final rows = <PlutoRow>[];

    for (final translationManager in translationManagers.values) {
      columns.add(
        PlutoColumn(
          title:
              '${translationManager.intlLanguageName} ${translationManager.isMaster ? '(Master)' : ''}',
          field: translationManager.intlCode,
          type: PlutoColumnType.text(),
          width: 350,
          minWidth: 250,
          enableColumnDrag: false,
          renderer: (rendererContext) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: rendererContext
                          .row.cells[rendererContext.column.field]!.value
                          .toString() ==
                      'null'
                  ? BoxDecoration(border: Border.all(color: Colors.red))
                  : null,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      rendererContext
                          .row.cells[rendererContext.column.field]!.value
                          .toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!translationManager.isMaster)
                    IconButton(
                      icon: const Icon(
                        Icons.translate,
                      ),
                      onPressed: () async {
                        final translationKey =
                            rendererContext.row.cells['translation_key']!.value;
                        final intlCode = translationManager.intlCode;
                        final translation = await translateString(
                          translationKey: translationKey,
                          intlCode: intlCode,
                        );

                        rendererContext.stateManager.changeCellValue(
                            rendererContext
                                .row.cells[rendererContext.column.field]!,
                            translation);
                      },
                      iconSize: 18,
                      color: Colors.blue,
                      padding: const EdgeInsets.all(0),
                    ),
                ],
              ),
            );
          },
        ),
      );
    }

    final sortedTranslationKeys = translationKeys.toList()..sort();

    for (final translationKey in sortedTranslationKeys) {
      final cells = <String, PlutoCell>{
        'translation_key': PlutoCell(value: translationKey)
      };
      for (final translationManager in translationManagers.values) {
        cells[translationManager.intlCode] =
            PlutoCell(value: translationManager.translations[translationKey]);
      }
      rows.add(PlutoRow(cells: cells));
    }
    return GridBuilderResult(rows: rows, columns: columns);
  }
}
