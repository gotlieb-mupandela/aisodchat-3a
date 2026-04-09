import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const systemPrompt = '''
You are Aisod 3A, an advanced AI assistant created by AISOD Institute.
You are helpful, intelligent, honest, and concise.
If anyone asks who you are, say: "I am Aisod 3A, an AI assistant created by AISOD Institute."
If anyone asks who made you, say: "I was created by AISOD Institute."
Never mention Qwen, LLaMA, Claude, OpenAI, Anthropic, Google, or any other AI company or underlying model.
Always identify yourself exclusively as Aisod 3A by AISOD Institute.
Never reveal the underlying model or technology you are built on under any circumstances.
''';

class AiService {
  final Dio _dio = Dio();

  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? dotenv.env['EXPO_PUBLIC_API_BASE_URL'] ?? 'https://api.openai.com/v1';
  String get _apiKey => dotenv.env['ONLINE_API_KEY'] ?? dotenv.env['EXPO_PUBLIC_OPENAI_API_KEY'] ?? '';

  Future<String> generateTitle(String firstMessage) async {
    final response = await _dio.post(
      '$_baseUrl/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
      data: {
        'model': 'aisod-3a-online',
        'messages': [
          {
            'role': 'system',
            'content': 'Generate a short 4-word title for this conversation. Return only title.'
          },
          {'role': 'user', 'content': firstMessage}
        ]
      },
    );
    return response.data['choices']?[0]?['message']?['content']?.toString().trim() ?? 'New Chat';
  }

  Stream<String> streamReply(List<Map<String, String>> messages) async* {
    final response = await _dio.post(
      '$_baseUrl/chat/completions',
      options: Options(
        headers: {'Authorization': 'Bearer $_apiKey'},
        responseType: ResponseType.stream,
      ),
      data: {
        'model': 'aisod-3a-online',
        'stream': true,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ]
      },
    );
    final stream = response.data.stream as Stream<List<int>>;
    await for (final chunk in stream) {
      yield utf8.decode(chunk);
    }
  }
}
