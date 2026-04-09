import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/ai_service.dart';
import '../../core/services/offline_model_service.dart';
import '../../core/storage/app_storage.dart';
import '../../shared/models/chat_models.dart';
import '../repositories/auth_repository.dart';
import '../repositories/chat_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository());
final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepository());
final aiServiceProvider = Provider<AiService>((ref) => AiService());
final offlineModelServiceProvider = Provider<OfflineModelService>((ref) => OfflineModelService());

final defaultModeProvider = StateNotifierProvider<DefaultModeController, ChatMode>(
  (ref) => DefaultModeController()..load(),
);

final modelDownloadedProvider = StateNotifierProvider<ModelDownloadedController, bool>(
  (ref) => ModelDownloadedController()..load(),
);

class DefaultModeController extends StateNotifier<ChatMode> {
  DefaultModeController() : super(ChatMode.online);

  Future<void> load() async {
    state = await AppStorage.getDefaultMode();
  }

  Future<void> set(ChatMode mode) async {
    state = mode;
    await AppStorage.setDefaultMode(mode);
  }
}

class ModelDownloadedController extends StateNotifier<bool> {
  ModelDownloadedController() : super(false);

  Future<void> load() async {
    state = await AppStorage.getModelDownloaded();
  }

  Future<void> set(bool value) async {
    state = value;
    await AppStorage.setModelDownloaded(value);
  }
}
