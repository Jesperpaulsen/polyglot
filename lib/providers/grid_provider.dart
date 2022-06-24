import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/providers/translation_provider.dart';
import 'package:intl_ui/services/grid_builder.dart';
import 'package:pluto_grid/pluto_grid.dart';

class GridState {
  var rows = <PlutoRow>[];
  var columns = <PlutoColumn>[];
  var key = 1;
  GridState copyWith({
    List<PlutoRow>? rows,
    List<PlutoColumn>? columns,
  }) {
    final copy = GridState();
    copy.rows = rows ?? this.rows;
    copy.columns = columns ?? this.columns;
    return copy;
  }
}

class GridStateProvider extends StateNotifier<GridState> {
  GridStateProvider(TranslationState translationState) : super(GridState()) {
    final gridBuilderResult = GridBuilder().buildGridFromTranslationKeys(
      translationKeys: translationState.translationKeys,
      translationManagers: translationState.translations,
    );
    final newState = state.copyWith(
      rows: gridBuilderResult.rows,
      columns: gridBuilderResult.columns,
    );
    _setState(newState);
  }

  _setState(GridState newState) {
    newState.key = newState.key + 1;
    state = newState;
  }

  static final provider =
      StateNotifierProvider<GridStateProvider, GridState>((ref) {
    final translationState = ref.watch(TranslationProvider.provider);
    return GridStateProvider(translationState);
  });
}
