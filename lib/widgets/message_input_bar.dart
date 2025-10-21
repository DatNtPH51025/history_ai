import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/providers/connectivity_provider.dart'; // ✅ 1. IMPORT PROVIDER

class MessageInputBar extends ConsumerWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  const MessageInputBar({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // THÊM WidgetRef
    final isConnected = ref.watch(isConnectedProvider); // LẮNG NGHE TRẠNG THÁI MẠNG

    // Xác định xem có nên vô hiệu hóa thanh nhập liệu không
    final bool isDisabled = isLoading || !isConnected;

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isDisabled, // ✅ 5. VÔ HIỆU HÓA TEXTFIELD
                decoration: InputDecoration(
                  hintText: isConnected ? 'Nhập câu hỏi của bạn...' : 'Không có kết nối mạng...', // ✅ 6. THAY ĐỔI HINT TEXT
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton(
              icon: isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.send),
              onPressed: isDisabled ? null : onSend, // ✅ 7. VÔ HIỆU HÓA NÚT GỬI
              style: IconButton.styleFrom(
                backgroundColor: isDisabled
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
