import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:polyglot/models/translation_manager.dart';
import 'package:polyglot/services/config_handler.dart';
import 'package:polyglot/services/translation_handler/translation_handler.dart';
import 'package:polyglot/services/translation_writer_isolate.dart';
import 'package:polyglot/services/translations_loader_isolate.dart';

class TranslationState {
  var translationKeys = <String>{};
  var translations = <String, TranslationManager>{};
  var sortedManagersKeys = <String>[];
  String? masterIntlCode;
  var loading = false;
  var version = 0;

  TranslationState copyWith({
    Set<String>? translationKeys,
    Map<String, TranslationManager>? translations,
    bool? loading,
    String? masterIntlCode,
    List<String>? sortedManagersKeys,
  }) {
    final copy = TranslationState();
    copy.translationKeys = translationKeys ?? this.translationKeys;
    copy.translations = translations ?? this.translations;
    copy.loading = loading ?? this.loading;
    copy.masterIntlCode = masterIntlCode ?? this.masterIntlCode;
    copy.sortedManagersKeys = sortedManagersKeys ?? this.sortedManagersKeys;
    copy.version = version;
    return copy;
  }
}

class Test {
  final String label;
  final bool master;

  Test({required this.label, required this.master});
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
      translations: <String, TranslationManager>{},
      translationKeys: <String>{},
      sortedManagersKeys: <String>[],
    );
    _setState(newState);
    await _initializeTranslations();
  }

  Future<void> _initializeTranslations() async {
    final translationsLoad =
        await TranslationsLoaderIsolate().loadTranslations();

    final sortedTranslations = translationsLoad.translationsPerCountry.entries
        .toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final sortedKeys = sortedTranslations.map((e) => e.key).toList();

    final newState = state.copyWith(
      translationKeys: translationsLoad.allTranslationKeys,
      translations: translationsLoad.translationsPerCountry,
      masterIntlCode: translationsLoad.masterIntlCode,
      sortedManagersKeys: sortedKeys,
    );
    newState.version = state.version + 1;
    _setState(newState);
  }

  Future<String?> translateAndAddWord({
    required String translationKey,
    required String intlCode,
  }) async {
    final masterIntlCode = state.masterIntlCode;

    if (masterIntlCode == null || state.translations[masterIntlCode] == null) {
      return null;
    }

    final masterTranslation =
        state.translations[masterIntlCode]!.translations[translationKey];

    if (masterTranslation == null) {
      return null;
    }

    final translation = await TranslationHandler.instance.translateString(
      sourceIntlCode: masterIntlCode,
      targetIntlCode: intlCode,
      stringToTranslate: masterTranslation,
    );

    if (translation == null) {
      return null;
    }

    await addTranslations(
      translationKey: translationKey,
      translations: {
        intlCode: translation,
      },
      shouldReload: false,
    );

    _insertTranslationToManagerWithoutReload(
      translationKey: translationKey,
      translationCode: intlCode,
      newValue: translation,
    );
    return translation;
  }

  Future<void> addTranslations({
    required String translationKey,
    required Map<String, String?> translations,
    bool shouldReload = true,
  }) async {
    await TranslationWriterIsolate().addTranslations(
      translationKey: translationKey,
      translations: translations,
      translationManagers: state.translations,
    );
    if (shouldReload) reloadTranslations();
  }

  TranslationManager _insertTranslationToManagerWithoutReload({
    required String translationKey,
    required String translationCode,
    required String newValue,
  }) {
    final translationManager = state.translations[translationCode];
    if (translationManager == null) {
      throw Exception(
          '[TranslationProvider] No translation manager matching translation code $translationCode');
    }

    translationManager.translations[translationKey] = newValue;
    _setState(state);
    return translationManager;
  }

  Future<void> updateTranslation({
    required String translationKey,
    required String translationCode,
    required String newValue,
  }) async {
    final translationManager = _insertTranslationToManagerWithoutReload(
      translationKey: translationKey,
      translationCode: translationCode,
      newValue: newValue,
    );

    final translationConfig =
        ConfigHandler.instance.projectConfig?.languageConfigs[translationCode];

    if (translationConfig == null) {
      throw Exception(
          '[TranslationProvider] No translation config matching translation code $translationCode');
    }

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

  Future<void> batchTranslation({required String targetIntlCode}) async {
    final newTranslations = await TranslationHandler.instance.translateBatch(
      masterTranslations:
          state.translations[state.masterIntlCode]!.translations,
      existingTranslations: state.translations[targetIntlCode]?.translations,
      sourceIntlCode: state.masterIntlCode!,
      targetIntlCode: targetIntlCode,
    );

    final translationManager = state.translations[targetIntlCode];

    if (translationManager == null) {
      throw Exception(
          '[TranslationProvider] No translation manager matching translation code $targetIntlCode');
    }

    translationManager.translations = newTranslations;

    final translationConfig =
        ConfigHandler.instance.projectConfig?.languageConfigs[targetIntlCode];

    if (translationConfig == null) {
      throw Exception(
          '[TranslationProvider] No translation config matching translation code $targetIntlCode');
    }

    await TranslationWriterIsolate()
        .sortAndWriteTranslationFileWithSeparateIsolate(
            translationConfig, translationManager);
    reloadTranslations();
  }

  static final provider =
      StateNotifierProvider<TranslationProvider, TranslationState>(
    (_) => TranslationProvider(),
  );
}
