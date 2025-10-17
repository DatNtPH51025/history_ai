import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:history_ai/providers/auth_provider.dart';
import 'package:history_ai/providers/theme_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:intl/intl.dart'; // ✅ THÊM DÒNG NÀY
// Provider để lấy thông tin phiên bản (sử dụng FutureProvider)
final packageInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final themeMode = ref.watch(themeNotifierProvider);
    final packageInfo = ref.watch(packageInfoProvider); // Lấy thông tin phiên bản

    // Hàm trợ giúp để tạo các ListTile đẹp hơn
    Widget _buildInfoTile(String title, String subtitle, IconData icon) {
      return ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
      );
    }

    // Hàm trợ giúp để tạo tiêu đề cho mỗi nhóm
    Widget _buildSectionTitle(String title) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hồ Sơ & Cài Đặt'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: user == null
      // Hiển thị màn hình chờ nếu chưa có thông tin người dùng
          ? const Center(child: CircularProgressIndicator())
      // Xây dựng UI chính khi đã có thông tin
          : ListView(
        children: [
          // --- 1. HEADER VỚI AVATAR VÀ TÊN ---
          _buildProfileHeader(context, user.displayName, user.photoURL),

          // --- 2. NHÓM THÔNG TIN TÀI KHOẢN ---
          _buildSectionTitle('Tài khoản'),
          _buildInfoTile('Email', user.email ?? 'Chưa cập nhật', Icons.email_outlined),
          _buildInfoTile('Tên hiển thị', user.displayName ?? 'Người dùng', Icons.person_outline),
          _buildInfoTile(
            'Ngày tham gia',
            user.metadata.creationTime != null
                ? DateFormat('dd/MM/yyyy').format(user.metadata.creationTime!)
                : 'Không rõ',
            Icons.calendar_today_outlined,
          ),

          // --- 3. NHÓM CÀI ĐẶT CHUNG ---
          _buildSectionTitle('Cài đặt chung'),
          SwitchListTile(
            title: const Text('Chế độ tối'),
            value: themeMode == ThemeMode.dark,
            onChanged: (value) {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
            secondary: Icon(
              themeMode == ThemeMode.dark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          ListTile(
            leading: Icon(Icons.language_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Ngôn ngữ'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Tiếng Việt'),
                Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              // TODO: Thêm logic đổi ngôn ngữ trong tương lai
            },
          ),

          // --- 4. NHÓM THÔNG TIN ỨNG DỤNG ---
          _buildSectionTitle('Ứng dụng'),
          ListTile(
            leading: Icon(Icons.policy_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Chính sách bảo mật'),
            onTap: () { /* TODO: Mở link chính sách */ },
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary),
            title: const Text('Điều khoản dịch vụ'),
            onTap: () { /* TODO: Mở link điều khoản */ },
          ),
          // Hiển thị phiên bản ứng dụng từ packageInfoProvider
          packageInfo.when(
            data: (info) => _buildInfoTile('Phiên bản', '${info.version} (${info.buildNumber})', Icons.info_outline),
            loading: () => const ListTile(title: Text('Đang tải phiên bản...')),
            error: (err, stack) => _buildInfoTile('Phiên bản', 'Lỗi', Icons.error_outline),
          ),

          // --- 5. NHÓM HÀNH ĐỘNG NGUY HIỂM ---
          const SizedBox(height: 24),
          _buildDangerZone(context, ref),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Widget cho header
  Widget _buildProfileHeader(BuildContext context, String? displayName, String? photoURL) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: photoURL != null ? NetworkImage(photoURL) : null,
            child: photoURL == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            displayName ?? 'Người dùng mới',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Widget cho khu vực nguy hiểm (Đăng xuất, Xóa tài khoản)
  Widget _buildDangerZone(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text('Đăng xuất', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.primary),
            onTap: () async {
              final confirmed = await _showConfirmationDialog(
                context,
                title: 'Xác nhận Đăng xuất',
                content: 'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?',
              );
              if (confirmed == true) {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              }
            },
          ),
          const Divider(height: 1),
          ListTile(
            title: Text('Xóa tài khoản', style: TextStyle(color: Colors.red.shade700)),
            leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
            onTap: () async {
              // TODO: Thêm logic xóa tài khoản (cần xác thực lại)
              final confirmed = await _showConfirmationDialog(
                context,
                title: 'CẢNH BÁO: Xóa Tài Khoản',
                content: 'Hành động này không thể hoàn tác. Tất cả dữ liệu của bạn, bao gồm các cuộc trò chuyện, sẽ bị xóa vĩnh viễn. Bạn có chắc chắn muốn tiếp tục?',
              );
              if (confirmed == true) {
                // Logic xóa tài khoản thực sự sẽ cần yêu cầu người dùng
                // đăng nhập lại để xác thực. Đây là một tính năng phức tạp.
              }
            },
          ),
        ],
      ),
    );
  }

  // Hộp thoại xác nhận hành động
  Future<bool?> _showConfirmationDialog(BuildContext context, {required String title, required String content}) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            CupertinoDialogAction(
              child: const Text('Hủy'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              child: const Text('Xác nhận'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }
}
