// ignore_for_file: deprecated_member_use, unused_element

import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../models/health_profile.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import 'health_profile_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  HealthProfileResponseDto? _profile;
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    // Lấy token thực tế đã lưu
    final token = await _storageService.getToken();
    
    if (token == null) {
      // Nếu không có token, điều hướng người dùng về màn hình đăng nhập
      return;
    }

    final profile = await _profileService.getMyProfile(token);
    setState(() {
      _profile = profile;
      _isLoading = false;
    });
  }

  Future<void> _handleLogout() async {
    await _storageService.deleteToken();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildHomeBody(),
      const Center(child: Text("Danh sách đơn thuốc")),
      const HealthProfileScreen(),
      _buildSettingsBody(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _currentIndex == 0 && _isLoading 
          ? const Center(child: CircularProgressIndicator()) 
          : screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.description_outlined), label: 'Đơn thuốc'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Hồ sơ'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Cài đặt'),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: AppColors.primary,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 30),
            )
          : null,
    );
  }

  Widget _buildHomeBody() {
    final size = MediaQuery.of(context).size;
    
    // Tính toán initials cho avatar
    String initials = "PT";
    if (_profile != null && _profile!.fullName.isNotEmpty) {
      List<String> names = _profile!.fullName.trim().split(" ");
      if (names.length >= 2) {
        initials = (names[0][0] + names[names.length - 1][0]).toUpperCase();
      } else {
        initials = names[0][0].toUpperCase();
      }
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Khu vực Khởi đầu / Phần trên (Header Section)
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Nền xanh dương đậm
              Container(
                height: size.height * 0.3,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(initials, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("Xin chào,", style: TextStyle(color: Colors.white70, fontSize: 14)),
                          Text(_profile?.fullName ?? "Nguyễn Văn A", 
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Thẻ Chỉ số Sức khỏe (Health Metrics Card)
              Positioned(
                top: size.height * 0.18,
                left: 20,
                right: 20,
                child: _buildHealthStats(),
              ),
            ],
          ),
          
          const SizedBox(height: 130), // Tăng khoảng trống để tránh đè nội dung lên Card sức khỏe

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text("Thuốc đang dùng", 
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.infoHighlight, borderRadius: BorderRadius.circular(8)),
                      child: const Text("4 đang dùng", 
                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTodayMedications(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsBody() {
    // Tính toán tên viết tắt cho Avatar
    String initials = "NT";
    if (_profile != null && _profile!.fullName.isNotEmpty) {
      List<String> names = _profile!.fullName.trim().split(" ");
      if (names.length >= 2) {
        initials = (names[0][0] + names[names.length - 1][0]).toUpperCase();
      } else {
        initials = names[0][0].toUpperCase();
      }
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Khu vực Tiêu đề và Hồ sơ Cá nhân (Header & Profile Section)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 180,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const Text(
                  "Cài đặt",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Thẻ Hồ sơ (Profile Card) nổi lên trên
              Positioned(
                top: 110,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFF1F5F9), // Light Gray
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _profile?.fullName ?? "Nguyễn Thanh Danh",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              _profile?.phoneNumber ?? "0912 345 678",
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.circle, color: AppColors.success, size: 8),
                                SizedBox(width: 4),
                                Text(
                                  "Đang hoạt động",
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Nút chuyển tiếp hồ sơ
                      GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                          );
                          if (result == true) _loadProfile();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chevron_right, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 100), // Khoảng trống cho Card nổi

          // 2. Khu vực Danh sách Cài đặt
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2a. Nhóm "TÀI KHOẢN"
                _settingsSectionTitle("Tài khoản"),
                _buildSettingsGroup([
                  _buildDetailedTile(
                    icon: Icons.lock_outline,
                    title: "Đổi mật khẩu",
                    subtitle: "Cập nhật mật khẩu để bảo mật tài khoản",
                    onTap: () {},
                  ),
                  _buildDetailedTile(
                    icon: Icons.link,
                    title: "Liên kết tài khoản y tế",
                    subtitle: "Kết nối hồ sơ bệnh viện",
                    onTap: () {},
                  ),
                ]),
                
                const SizedBox(height: 24),
                // 2b. Nhóm "TUY CHỌN"
                _settingsSectionTitle("Tùy chọn"),
                _buildSettingsGroup([
                  _buildDetailedTile(
                    icon: Icons.notifications_none,
                    title: "Cài đặt thông báo",
                    subtitle: "Quản lý cách bạn nhận thông báo",
                    trailing: Switch(value: true, onChanged: (v) {}, activeColor: AppColors.primary),
                  ),
                  _buildDetailedTile(
                    icon: Icons.language,
                    title: "Ngôn ngữ",
                    subtitle: "Chọn ngôn ngữ hiển thị",
                    trailingText: "Tiếng Việt",
                    onTap: () {},
                  ),
                  _buildDetailedTile(
                    icon: Icons.dark_mode_outlined,
                    title: "Chế độ màn hình",
                    subtitle: "Lựa chọn chế độ sáng hoặc tối",
                    trailingText: "Chế độ sáng",
                    trailing: Switch(value: false, onChanged: (v) {}, activeColor: AppColors.primary),
                  ),
                ]),
                
                const SizedBox(height: 24),
                // 2c. Nhóm "KHÁC"
                _settingsSectionTitle("Khác"),
                _buildSettingsGroup([
                  _buildDetailedTile(
                    icon: Icons.info_outline,
                    title: "Về ứng dụng",
                    subtitle: "Phiên bản 1.0.0",
                    onTap: () {},
                  ),
                  _buildDetailedTile(
                    icon: Icons.logout,
                    title: "Đăng xuất",
                    iconColor: AppColors.danger,
                    textColor: AppColors.danger,
                    onTap: _handleLogout,
                  ),
                ]),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          return Column(
            children: [
              child,
              if (idx < children.length - 1)
                const Divider(height: 1, indent: 52, endIndent: 16, color: AppColors.border),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDetailedTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    Widget? trailing,
    Color iconColor = AppColors.primary,
    Color textColor = AppColors.textDark,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: const TextStyle(color: AppColors.textMuted, fontSize: 14)),
          const SizedBox(width: 4),
          trailing ?? const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chào bạn,", style: TextStyle(color: Colors.white70, fontSize: 14)),
              Text(_profile?.fullName ?? "Người dùng", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
    );
  }

  Widget _buildHealthStats() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _statCard("Nhóm máu", _profile?.bloodType ?? "N/A", Icons.bloodtype, Colors.red),
        _statCard("BMI", _profile?.bmi.toStringAsFixed(1) ?? "0.0", Icons.speed, Colors.orange),
        _statCard("Chiều cao", "${_profile?.height ?? 0} cm", Icons.height, Colors.blue),
        _statCard("Cân nặng", "${_profile?.weight ?? 0} kg", Icons.monitor_weight_outlined, Colors.green),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        ],
      ),
    );
  }

  Widget _buildTodayMedications() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Center(
        child: Text("Chưa có lịch uống thuốc hôm nay", style: TextStyle(color: AppColors.textMuted)),
      ),
    );
  }
}