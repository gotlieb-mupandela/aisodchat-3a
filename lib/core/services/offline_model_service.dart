class OfflineModelService {
  Future<bool> isModelDownloaded() async {
    return false;
  }

  Future<void> downloadModel(void Function(double progress) onProgress) async {
    onProgress(0.0);
    onProgress(1.0);
  }

  Future<void> deleteModel() async {}

  Stream<String> complete(String prompt) async* {
    yield 'Offline mode is not fully wired yet. Prompt: $prompt';
  }
}
