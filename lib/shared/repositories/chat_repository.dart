import '../../core/services/supabase_service.dart';
import '../models/chat_models.dart';

class ChatRepository {
  Future<List<AppConversation>> getConversations(String userId) async {
    final rows = await SupabaseService.client
        .from('conversations')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false);
    return rows.map<AppConversation>((row) => AppConversation.fromMap(row)).toList();
  }

  Future<List<AppMessage>> getMessages(String conversationId) async {
    final rows = await SupabaseService.client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at');
    return rows.map<AppMessage>((row) => AppMessage.fromMap(row)).toList();
  }

  Future<String> createConversation({
    required String userId,
    required String title,
    required ChatMode mode,
  }) async {
    final row = await SupabaseService.client
        .from('conversations')
        .insert({'user_id': userId, 'title': title, 'mode': mode.name})
        .select()
        .single();
    return row['id'] as String;
  }

  Future<void> saveMessage({
    required String conversationId,
    required String role,
    required String content,
    required bool isOffline,
  }) async {
    await SupabaseService.client.from('messages').insert({
      'conversation_id': conversationId,
      'role': role,
      'content': content,
      'is_offline': isOffline,
    });
  }

  Future<void> deleteConversation(String conversationId) async {
    await SupabaseService.client.from('messages').delete().eq('conversation_id', conversationId);
    await SupabaseService.client.from('conversations').delete().eq('id', conversationId);
  }
}
