import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_ui/models/translation_manager.dart';
import 'package:intl_ui/services/config_handler.dart';
import 'package:intl_ui/services/translation_writer_isolate.dart';
import 'package:intl_ui/services/translations_loader_isolate.dart';

class TranslationState {
  var translationKeys = <String>{};
  var translations = SplayTreeMap<String, TranslationManager>();
  var loading = false;
  var version = 0;

  TranslationState copyWith({
    Set<String>? translationKeys,
    SplayTreeMap<String, TranslationManager>? translations,
    bool? loading,
  }) {
    final copy = TranslationState();
    copy.translationKeys = translationKeys ?? this.translationKeys;
    copy.translations = translations ?? this.translations;
    copy.loading = loading ?? this.loading;
    copy.version = version;
    return copy;
  }
}

class TranslationProvider extends StateNotifier<TranslationState> {
  TranslationProvider() : super(TranslationState()) {
    _setLoading(isLoading: true);
    try {
      _initializeTranslations();
    } catch (e) {
      print(e);
    }
    _setLoading(isLoading: false);
  }

  _setState(TranslationState newState) {
    state = newState;
  }

  _setLoading({required bool isLoading}) {
    final newState = state.copyWith(loading: isLoading);
    _setState(newState);
  }

  Future<void> reloadTranslations() async {
    final newState = state.copyWith(
        translations: SplayTreeMap<String, TranslationManager>(),
        translationKeys: <String>{});
    _setState(newState);
    await _initializeTranslations();
  }

  Future<void> _initializeTranslations() async {
    final translationsLoad =
        await TranslationsLoaderIsolate().loadTranslations();

    final sortedTranslations = SplayTreeMap<String, TranslationManager>.from(
        translationsLoad.translationsPerCountry, (a, b) {
      final masterA = translationsLoad.translationsPerCountry[a]?.isMaster;
      final masterB = translationsLoad.translationsPerCountry[b]?.isMaster;
      if (masterA != null && masterA) {
        return -1;
      }
      if (masterB != null && masterB) {
        return 1;
      }
      return 0;
    });

    final newState = state.copyWith(
      translationKeys: translationsLoad.allTranslationKeys,
      translations: sortedTranslations,
    );
    newState.version = state.version + 1;
    _setState(newState);
  }

  Future<void> addTranslations({
    required String translationKey,
    required Map<String, String?> translations,
  }) async {
    await TranslationWriterIsolate().addTranslations(
      translationKey: translationKey,
      translations: translations,
      translationManagers: state.translations,
    );
    reloadTranslations();
  }

  Future<void> updateTranslation({
    required String translationKey,
    required String translationCode,
    required String newValue,
  }) async {
    final translationManager = state.translations[translationCode];
    if (translationManager == null) {
      throw Exception(
          'No translation manager matching translation code $translationCode');
    }

    final translationConfig =
        ConfigHandler.instance.projectConfig?.languageConfigs[translationCode];

    if (translationConfig == null) {
      throw Exception(
          'No translation config matching translation code $translationCode');
    }

    translationManager.translations[translationKey] = newValue;
    _setState(state);

    return TranslationWriterIsolate()
        .sortAndWriteTranslationFileWithSeparateIsolate(
      translationConfig,
      translationManager,
    );
  }

  Future<void> updateTranslationKey({
    required String oldTranslationKey,
    String? newTranslationKey,
  }) async {
    final translationKeys = state.translationKeys;
    translationKeys.remove(oldTranslationKey);
    if (newTranslationKey != null) {
      translationKeys.add(newTranslationKey);
    }
    final newState = state.copyWith(translationKeys: translationKeys);
    _setState(newState);

    return TranslationWriterIsolate().updateKeyInAllTranslationFiles(
      oldTranslationKey: oldTranslationKey,
      newTranslationKey: newTranslationKey,
      translationManagers: state.translations,
    );
  }

  static final provider =
      StateNotifierProvider<TranslationProvider, TranslationState>(
    (_) => TranslationProvider(),
  );
}
