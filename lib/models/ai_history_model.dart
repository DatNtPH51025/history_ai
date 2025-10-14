import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:history_ai/models/message.dart' as app_message; // Sử dụng bí danh để tránh xung đột tên

class HistoryAI {
  final GenerativeModel _model;

  // Lời nhắc hệ thống, được giữ lại theo yêu cầu của bạn
  static final Content systemPrompt = Content.text(
      "Bạn là một trợ lý AI chuyên về lịch sử Việt Nam và thế giới. "
          "Hãy giải thích các sự kiện một cách ngắn gọn, rõ ràng và dễ hiểu, như thể bạn đang kể chuyện cho học sinh hoặc sinh viên. "
          "Hãy bao gồm các mốc thời gian, nhân vật quan trọng, hoặc các chi tiết thú vị để làm cho câu chuyện trở nên sinh động. "
          "Luôn luôn trả lời bằng tiếng Việt.");

  // Constructor: Nhận API key từ bên ngoài để khởi tạo model
  // Điều này giúp quản lý key tập trung và an toàn hơn.
  HistoryAI({required String apiKey})
      : _model = GenerativeModel(
    // ✅ SỬA DÒNG NÀY
    model: 'gemini-2.5-flash', // Bỏ phần "-latest"
    apiKey: apiKey,
  );
  // Hàm "ask" mới: Nhận cả câu hỏi và lịch sử trò chuyện (context)
  Future<String> ask(
      String question, List<app_message.Message> history) async {
    try {
      // 1. Xây dựng nội dung gửi cho AI
      final List<Content> conversation = [
        systemPrompt, // Bắt đầu với lời nhắc hệ thống
      ];

      // 2. Chuyển đổi lịch sử tin nhắn từ model của app sang model của Google AI
      for (final message in history) {
        if (message.isUser) {
          conversation.add(Content.text(message.text));
        } else {
          // Tin nhắn của AI được coi là 'model' response
          conversation.add(Content.model([TextPart(message.text)]));
        }
      }

      // 3. Thêm câu hỏi mới nhất của người dùng
      conversation.add(Content.text(question));

      // 4. Gọi API
      final response = await _model.generateContent(conversation);
      final answer = response.text;

      if (answer == null || answer.isEmpty) {
        return "🤖 Rất tiếc, tôi không thể tìm thấy câu trả lời. Vui lòng thử lại.";
      }
      return answer;
    } catch (e) {
      print("Lỗi khi gọi API của Google AI: $e"); // In lỗi ra console để dễ gỡ lỗi
      return "❌ Đã xảy ra lỗi khi kết nối với AI. Vui lòng kiểm tra lại kết nối hoặc API key.";
    }
  }
}

