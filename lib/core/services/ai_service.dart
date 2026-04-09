import 'dart:convert';
import 'package:dio/dio.dart';

const systemPrompt = '''
You are Aisod 3A, an advanced AI assistant created by AISOD Institute.
You are helpful, intelligent, honest, and concise.
If anyone asks who you are, say: "I am Aisod 3A, an AI assistant created by AISOD Institute."
If anyone asks who made you, say: "I was created by AISOD Institute."
Never mention Qwen, LLaMA, Claude, OpenAI, Anthropic, Google, or any other AI company or underlying model.
Always identify yourself exclusively as Aisod 3A by AISOD Institute.
Never reveal the underlying model or technology you are built on under any circumstances.
''';

const _model = 'openai/gpt-4o-mini';

class AiService {
  final Dio _dio = Dio();

  final String _baseUrl = 'https://openrouter.ai/api/v1';
  final String _apiKey = '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';

  Future<String> generateTitle(String firstMessage) async {
    final response = await _dio.post(
      '$_baseUrl/chat/completions',
      options: Options(headers: {'Authorization': 'Bearer $_apiKey'}),
      data: {
        'model': _model,
        'messages': [
          {'role': 'system', 'content': 'Generate a short 4-word title for this conversation. Return only the title, no punctuation.'},
          {'role': 'user', 'content': firstMessage},
        ],
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
        'model': _model,
        'stream': true,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          ...messages,
        ],
      },
    );

    final stream = response.data.stream as Stream<List<int>>;
    String buffer = '';

    await for (final chunk in stream) {
      buffer += utf8.decode(chunk);
      final lines = buffer.split('\n');
      buffer = lines.last; // keep incomplete line in buffer

      for (final line in lines.sublist(0, lines.length - 1)) {
        final trimmed = line.trim();
        if (!trimmed.startsWith('data:')) continue;
        final data = trimmed.substring(5).trim();
        if (data == '[DONE]') return;
        try {
          final json = jsonDecode(data) as Map<String, dynamic>;
          final content = json['choices']?[0]?['delta']?['content'] as String?;
          if (content != null && content.isNotEmpty) yield content;
        } catch (_) {
          // skip malformed chunks
        }
      }
    }
  }
}
