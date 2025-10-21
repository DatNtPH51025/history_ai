// auth_view_model.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:history_ai/core/services/firebase_auth_service.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  AuthState copyWith({User? user, bool? isLoading, String? error, bool clearError = false}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      // Nếu clearError là true, đặt error là null. Ngược lại, giữ giá trị cũ hoặc cập nhật giá trị mới.
      error: clearError ? null : error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;

  AuthNotifier(this._authService) : super(AuthState(isLoading: true)) {
    // Theo dõi auth state
    _authService.authStateChanges().listen((user) {
      if (mounted) { // Kiểm tra xem Notifier còn tồn tại không
        state = AuthState(user: user, isLoading: false);
      }
    });
  }

  // ✅ HÀM DIỄN GIẢI LỖI SANG TIẾNG VIỆT
  String _mapFirebaseAuthExceptionToMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này.';
      case 'wrong-password':
        return 'Mật khẩu không chính xác. Vui lòng thử lại.';
      case 'invalid-email':
        return 'Địa chỉ email không hợp lệ.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng bởi một tài khoản khác.';
      case 'weak-password':
        return 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này chưa được kích hoạt.';
      case 'user-disabled':
        return 'Tài khoản này đã bị vô hiệu hóa.';
      case 'too-many-requests':
        return 'Bạn đã thử quá nhiều lần. Vui lòng thử lại sau.';
    // Lỗi khi đăng nhập Google
      case 'account-exists-with-different-credential':
        return 'Tài khoản đã tồn tại với một phương thức đăng nhập khác.';
      case 'popup-closed-by-user':
        return 'Bạn đã đóng cửa sổ đăng nhập. Vui lòng thử lại.';
      case 'cancelled': // Tên lỗi có thể là 'cancelled' cho Google Sign-In
        return 'Bạn đã hủy quá trình đăng nhập.';
      default:
      // Lỗi không xác định
        return 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.';
    }
  }


  Future<void> signInWithGoogle() async {
    // Xóa lỗi cũ và bắt đầu loading
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.signInWithGoogle();
      if (mounted) {
        state = state.copyWith(user: user, isLoading: false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Sử dụng hàm diễn giải lỗi
        final errorMessage = _mapFirebaseAuthExceptionToMessage(e);
        state = state.copyWith(error: errorMessage, isLoading: false);
      }
    } catch (e) { // Bắt các lỗi chung khác
      if (mounted) {
        state = state.copyWith(error: 'Đã xảy ra lỗi. Vui lòng thử lại.', isLoading: false);
      }
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    // Không cần kiểm tra mounted ở đây vì chúng ta đang reset state
    state = AuthState(user: null, isLoading: false);
  }

  // Bạn có thể áp dụng tương tự cho các hàm signIn và signUp
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.signInWithEmail(email, password);
      if (mounted) {
        state = state.copyWith(user: user, isLoading: false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        final errorMessage = _mapFirebaseAuthExceptionToMessage(e);
        state = state.copyWith(error: errorMessage, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: 'Đã xảy ra lỗi. Vui lòng thử lại.', isLoading: false);
      }
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Gọi đến service để tạo người dùng mới
      final user = await _authService.signUpWithEmail(email, password);
      if (mounted) {
        state = state.copyWith(user: user, isLoading: false);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        // Sử dụng lại hàm dịch lỗi tiện lợi của chúng ta
        final errorMessage = _mapFirebaseAuthExceptionToMessage(e);
        state = state.copyWith(error: errorMessage, isLoading: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(error: 'Đã xảy ra lỗi. Vui lòng thử lại.', isLoading: false);
      }
    }
  }
}


// Provider không thay đổi
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(FirebaseAuthService()),
);
