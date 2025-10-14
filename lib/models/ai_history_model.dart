import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HistoryAI {
  final String _apiKey = dotenv.env['GOOGLE_API_KEY'] ?? "";

  final List<Content> _conversation = [
    Content.text(
        "Bạn là trợ lý AI về lịch sử Việt Nam và thế giới. "
            "Hãy giải thích ngắn gọn, rõ ràng, dễ hiểu, như đang kể chuyện cho học sinh – sinh viên. "
            "Đưa ra mốc thời gian, nhân vật, hoặc ví dụ thú vị để làm cho câu trả lời sinh động hơn. "
            "Luôn trả lời bằng tiếng Việt."
    ),
  ];

  static const int _maxMemory = 15;

  void _trimMemory() {
    if (_conversation.length > _maxMemory) {
      _conversation.removeAt(1); // giữ lời nhắc đầu
    }
  }

  Future<String> ask(String question) async {
    if (_apiKey.isEmpty) {
      return "❌ Chưa có API Key";
    }

    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );

    _conversation.add(Content.text("Câu hỏi: $question"));
    _trimMemory();

    try {
      final response = await model.generateContent(_conversation);
      final answer = response.text;

      if (answer == null || answer.isEmpty) {
        return "🤖 Không có phản hồi từ AI.";
      }

      _conversation.add(Content.text("Trả lời: $answer"));
      return answer;
    } catch (e) {
      return "❌ Lỗi AI: $e";
    }
  }
}
