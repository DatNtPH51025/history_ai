import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Tạo một StreamProvider để cung cấp trạng thái kết nối mạng
final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  // Trả về một stream lắng nghe sự thay đổi của kết nối
  return Connectivity().onConnectivityChanged.map((results) => results.first);
});
// 2. Một provider tiện ích để kiểm tra nhanh xem có kết nối không
final isConnectedProvider = Provider<bool>((ref) {
  // Lắng nghe connectivityProvider
  final connectivityResult = ref.watch(connectivityProvider);

  // Trả về true nếu có kết nối (wifi hoặc mobile), ngược lại trả về false
  return connectivityResult.when(
    data: (result) => result == ConnectivityResult.mobile || result == ConnectivityResult.wifi, // ✅ ĐÃ XÓA PHẦN THỪA
    loading: () => true, // Giả định là có kết nối khi đang tải
    error: (error, stackTrace) {
      return false;
    },
  );
});



