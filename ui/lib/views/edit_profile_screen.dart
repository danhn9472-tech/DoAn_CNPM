import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../models/health_profile.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import '../services/profile_service.dart';
import '../services/storage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();

  HealthProfileResponseDto? _profile;
  bool _isLoading = true;
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodType;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final token = await _storageService.getToken();
    if (token == null) return;

    final profile = await _profileService.getMyProfile(token);
    if (mounted) {
      setState(() {
        _profile = profile;
        if (_profile != null) {
          _nameController.text = _profile!.fullName;
          _phoneController.text = _profile!.phoneNumber;
          _addressController.text = _profile!.address;
          _heightController.text = _profile!.height.toString();
          _weightController.text = _profile!.weight.toString();
          _selectedGender = _profile!.gender;
          _selectedBloodType = _profile!.bloodType;
          try {
            _selectedDate = DateTime.parse(_profile!.dateOfBirth);
          } catch (_) {}
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    final token = await _storageService.getToken();
    if (token == null || _profile == null) return;

    String formattedDate = _selectedDate != null 
        ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
        : _profile!.dateOfBirth;

    double? newHeight = double.tryParse(_heightController.text);
    double? newWeight = double.tryParse(_weightController.text);

    if (newHeight == null || newWeight == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Chiều cao và Cân nặng phải là số hợp lệ")));
      return;
    }

    final updatedProfile = HealthProfileResponseDto(
      fullName: _nameController.text,
      dateOfBirth: formattedDate,
      gender: _selectedGender ?? _profile!.gender,
      phoneNumber: _phoneController.text,
      address: _addressController.text,
      bloodType: _selectedBloodType ?? _profile!.bloodType,
      height: newHeight,
      weight: newWeight,
      bmi: _profile!.bmi,
    );

    final result = await _profileService.updateMyProfile(token, updatedProfile);
    if (mounted) {
      if (result['success']) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cập nhật thành công")));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result['message'] ?? "Cập nhật thất bại"),
          backgroundColor: AppColors.danger,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: AppColors.primary),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            // Avatar Section
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: AppColors.border, // Placeholder background
                      child: _profile?.fullName != null && _profile!.fullName.isNotEmpty
                          ? Text(
                              _profile!.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').join().toUpperCase(),
                              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: AppColors.primary),
                            )
                          : const Icon(Icons.person, size: 60, color: AppColors.textMuted),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Chức năng thay đổi ảnh đại diện chưa được triển khai.")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24), // Space between avatar and form fields
                Padding( // <--- Thêm widget Padding để bọc Container
                  padding: const EdgeInsets.all(20),
                  child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildField("Họ và tên", _nameController, Icons.person_outline),
                  const Divider(height: 24),
                  _buildDatePicker(),
                  const Divider(height: 24),
                  _buildGenderPicker(),
                  const Divider(height: 24),
                  _buildBloodTypePicker(),
                  const Divider(height: 24),
                  _buildReadOnlyField("Chỉ số BMI (Tự động tính)", _profile?.bmi.toStringAsFixed(1) ?? "0.0", Icons.speed),
                  const Divider(height: 24),
                  _buildField("Chiều cao (cm)", _heightController, Icons.height, keyboardType: TextInputType.number),
                  const Divider(height: 24),
                  _buildField("Cân nặng (kg)", _weightController, Icons.monitor_weight_outlined, keyboardType: TextInputType.number),
                  const Divider(height: 24),
                  _buildField("Số điện thoại", _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const Divider(height: 24),
                  _buildField("Địa chỉ", _addressController, Icons.location_on_outlined),
                ],
              ),
            ),
          ), // <--- Đóng widget Padding
        ],
      ),
    ),
  );
}

  Widget _buildField(String label, TextEditingController controller, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              TextField(
                controller: controller,
                keyboardType: keyboardType,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 4)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker() {
    String formattedDisplayDate = _selectedDate != null
        ? DateFormat('dd / MM / yyyy').format(_selectedDate!)
        : "Chọn ngày sinh";

    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate ?? DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime.now(),
          builder: (context, child) { // Apply theme for date picker
            return Theme(data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary, onPrimary: Colors.white, onSurface: AppColors.textDark,), textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: AppColors.primary,),),), child: child!,);
          },
        );
        if (picked != null && picked != _selectedDate) setState(() => _selectedDate = picked);
      },
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ngày sinh", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              Text(formattedDisplayDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderPicker() {
    return Row( // Added Row
      children: [
        const Icon(Icons.wc_outlined, color: AppColors.textMuted, size: 20), // Added Icon
        const SizedBox(width: 12), // Added SizedBox
        Expanded( // Added Expanded
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Giới tính", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              const SizedBox(height: 8), // Added space
              SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(value: 'Nam', label: Text('Nam')),
                  ButtonSegment<String>(value: 'Nữ', label: Text('Nữ')),
                  ButtonSegment<String>(value: 'Khác', label: Text('Khác')),
                ], // Pass an empty set if _selectedGender is null
                selected: _selectedGender != null ? <String>{_selectedGender!} : <String>{},
                onSelectionChanged: (Set<String> newSelection) {
                  if (newSelection.isNotEmpty) {
                    setState(() => _selectedGender = newSelection.first);
                  }
                },
                style: SegmentedButton.styleFrom(
                  foregroundColor: AppColors.textDark,
                  selectedForegroundColor: Colors.white,
                  selectedBackgroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypePicker() {
    return Row(
      children: [
        const Icon(Icons.bloodtype_outlined, color: AppColors.textMuted, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Nhóm máu", style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
              DropdownButton<String>(
                value: ["A", "B", "O", "AB", "N/A"].contains(_selectedBloodType) ? _selectedBloodType : null,
                isExpanded: true,
                underline: const SizedBox(),
                items: ["A", "B", "O", "AB", "N/A"].map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)))).toList(),
                onChanged: (val) => setState(() => _selectedBloodType = val),
              ),
            ],
          ),
        ),
      ],
    );
  }
}