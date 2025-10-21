import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      final userCredential =
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // ✅ SỬA LẠI: Ném lại chính xác lỗi FirebaseAuthException
      rethrow;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final userCredential =
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // ✅ SỬA LẠI: Ném lại chính xác lỗi FirebaseAuthException
      rethrow;
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      // Nếu người dùng đóng cửa sổ popup
      if (googleUser == null) {
        // Ném một lỗi cụ thể để ViewModel có thể bắt
        throw FirebaseAuthException(code: 'cancelled', message: 'Google Sign-In was cancelled by user.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // ✅ SỬA LẠI: Ném lại chính xác lỗi FirebaseAuthException
      rethrow;
    } catch(e) {
      // Bắt các lỗi khác và ném lại một cách chung chung hơn nếu cần
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    try {
      // disconnect() không cần thiết và đôi khi gây ra luồng xác thực lại không mong muốn
      // Chỉ cần signOut là đủ để xóa phiên đăng nhập
      await _googleSignIn.signOut();
    } catch (_) {
      // Bỏ qua lỗi nếu người dùng chưa từng đăng nhập bằng Google
    }
  }
}
