// ignore_for_file: unused_import, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/health_profile.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import 'app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart';

class AddConditionScreen extends StatefulWidget {
  const AddConditionScreen({super.key});

  @override
  State<AddConditionScreen> createState() => _AddConditionScreenState();
}

class _AddConditionScreenState extends State<AddConditionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  DateTime? _selectedDiagnosisDate;
  int? _selectedConditionId;
  bool _isLoading = false;

  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();

  Future<void> _addCondition() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedConditionId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn bệnh lý từ danh sách gợi ý.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final AddConditionDto newCondition = AddConditionDto(
      conditionId: _selectedConditionId!,
      diagnosedDate: _selectedDiagnosisDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDiagnosisDate!)
          : null,
      notes: _notesController.text.isEmpty ? null : _notesController.text,
    );

    final token = await _storageService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy token. Vui lòng đăng nhập lại.")),
        );
        Navigator.of(context).pop(); // Go back to previous screen
      }
      return;
    }

    final result = await _profileService.addCondition(token, newCondition);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm bệnh lý nền thành công!")),
        );
        Navigator.of(context).pop(true); // Pop with true to indicate success and refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Thêm bệnh lý nền thất bại.")),
        );
      }
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section - Blue with curved bottom
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: size.height * 0.25,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary, // Blue for primary
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Thêm bệnh lý nền mới",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Cung cấp thông tin chẩn đoán chính xác",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Condition Name Field
                    _buildSectionTitle("Tên bệnh lý nền *"),
                    Autocomplete<ConditionSearchResponseDto>(
                      optionsBuilder: (TextEditingValue textEditingValue) async {
                        if (textEditingValue.text.isEmpty) {
                          return const Iterable<ConditionSearchResponseDto>.empty();
                        }
                        final token = await _storageService.getToken();
                        if (token == null) return const Iterable<ConditionSearchResponseDto>.empty();
                        return await _profileService.searchConditions(token, textEditingValue.text);
                      },
                      displayStringForOption: (ConditionSearchResponseDto option) => option.conditionName,
                      onSelected: (ConditionSearchResponseDto selection) {
                        setState(() {
                          _selectedConditionId = selection.conditionId;
                        });
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          onChanged: (value) {
                            if (_selectedConditionId != null) {
                              setState(() {
                                _selectedConditionId = null;
                              });
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty || _selectedConditionId == null) {
                              return 'Vui lòng chọn bệnh lý nền từ danh sách gợi ý.';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: "Tìm kiếm bệnh lý (VD: dạ dày, suy tim...)",
                            prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                            filled: true,
                            fillColor: AppColors.cardWhite,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Material(
                            elevation: 4.0,
                            borderRadius: BorderRadius.circular(12),
                            clipBehavior: Clip.antiAlias,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 250,
                                maxWidth: MediaQuery.of(context).size.width - 40, // 20 padding mỗi bên
                              ),
                              child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                itemCount: options.length,
                                itemBuilder: (BuildContext context, int index) {
                                  final option = options.elementAt(index);
                                  return ListTile(
                                    title: Text(option.conditionName, style: const TextStyle(color: AppColors.textDark)),
                                    onTap: () => onSelected(option),
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Diagnosis Date Field
                    _buildSectionTitle("Ngày chẩn đoán / phát hiện bệnh"),
                    GestureDetector(
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDiagnosisDate ?? DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.primary, // Header background color
                                  onPrimary: Colors.white, // Header text color
                                  onSurface: AppColors.textDark, // Body text color
                                ),
                                textButtonTheme: TextButtonThemeData(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.primary, // Button text color
                                  ),
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (picked != null && picked != _selectedDiagnosisDate) {
                          setState(() {
                            _selectedDiagnosisDate = picked;
                          });
                        }
                      },
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.cardWhite,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: AppColors.textMuted),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _selectedDiagnosisDate == null
                                    ? "mm / dd / yyyy"
                                    : DateFormat('dd / MM / yyyy').format(_selectedDiagnosisDate!),
                                style: TextStyle(
                                  color: _selectedDiagnosisDate == null ? AppColors.textMuted : AppColors.textDark,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const Icon(Icons.calendar_month_outlined, color: AppColors.textMuted),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notes Field
                    _buildSectionTitle("Ghi chú tình trạng hoặc lời dặn bác sĩ (Không bắt buộc)"),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 5,
                      maxLength: 300, // Max length as per description
                      decoration: InputDecoration(
                        hintText: "VD: Giai đoạn 2, theo dõi 3 tháng/lần. Bác sĩ dặn hạn chế muối và đạm...",
                        filled: true,
                        fillColor: AppColors.cardWhite,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Info Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.infoHighlight, // Light blue background
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)), // Light blue border
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.info_outline, color: AppColors.primary, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Thông tin bệnh lý nền giúp hệ thống kiểm tra tương tác thuốc chính xác hơn cho bạn.",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textDark),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMuted,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Quay lại"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: "Xác nhận thêm bệnh lý",
              onPressed: _addCondition,
              isLoading: _isLoading,
              backgroundColor: AppColors.primary, // Blue button for condition
            ),
          ),
        ],
      ),
    );
  }
}