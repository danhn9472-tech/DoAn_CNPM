// ignore_for_file: curly_braces_in_flow_control_structures, unused_field, unused_import, prefer_final_fields, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;
import '../models/health_profile.dart';
import '../models/allergy.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import '../services/drug_service.dart';
import 'app_colors.dart';
import '../widgets/primary_button.dart';
import '../widgets/custom_text_field.dart'; // Reusing CustomTextField

class AddAllergyScreen extends StatefulWidget {
  const AddAllergyScreen({super.key});

  @override
  State<AddAllergyScreen> createState() => _AddAllergyScreenState();
}

class _AddAllergyScreenState extends State<AddAllergyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otherSymptomsController = TextEditingController();
  int? _selectedDrugId; // ID thuốc dùng để gửi xuống DB
  String? _selectedSeverity;
  List<String> _selectedSymptoms = [];
  bool _isLoading = false;

  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  final DrugService _drugService = DrugService();

  final List<String> _predefinedSymptoms = [
    "Nổi mề đay",
    "Sưng phù",
    "Khó thở",
    "Nôn mửa",
    "Ngứa da",
    "Phát ban toàn thân",
    "Tụt huyết áp",
    "Tim đập nhanh",
  ];

  final PublishSubject<String> _searchSubject = PublishSubject<String>();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearchingDrugs = false;
  StreamSubscription? _searchSubscription;
  TextEditingController? _drugSearchController;

  @override
  void initState() {
    super.initState();
    _searchSubscription = _searchSubject
        .debounceTime(const Duration(milliseconds: 400))
        .distinct()
        .switchMap((keyword) {
          if (keyword.trim().isEmpty) {
            return Stream.value(<Map<String, dynamic>>[]);
          }
          if (mounted) {
            setState(() {
              _isSearchingDrugs = true;
            });
          }
          return Stream.fromFuture(_drugService.searchDrugs(keyword));
        })
        .listen((results) {
          if (mounted) {
            setState(() {
              _suggestions = results;
              _isSearchingDrugs = false;
            });
          }
        });
  }

  Future<void> _addAllergy() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedSeverity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn mức độ dị ứng.")),
      );
      return;
    }

    setState(() => _isLoading = true);

    String allSymptoms = _selectedSymptoms.join(", ");
    if (_otherSymptomsController.text.isNotEmpty) {
      if (allSymptoms.isNotEmpty) {
        allSymptoms += ", ";
      }
      allSymptoms += _otherSymptomsController.text;
    }

    final AddAllergyDto newAllergy = AddAllergyDto(
      drugId: _selectedDrugId!, // Truyền ID thuốc để validate API
      severity: _selectedSeverity!,
      symptoms: allSymptoms.isEmpty ? null : allSymptoms,
    );

    final token = await _storageService.getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không tìm thấy token. Vui lòng đăng nhập lại."),
          ),
        );
        Navigator.of(context).pop(); // Go back to previous screen
      }
      return;
    }

    final result = await _profileService.addAllergy(token, newAllergy);

    if (mounted) {
      setState(() => _isLoading = false);
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Thêm dị ứng thuốc thành công!")),
        );
        Navigator.of(
          context,
        ).pop(true); // Pop with true to indicate success and refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Thêm dị ứng thuốc thất bại."),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _otherSymptomsController.dispose();
    _searchSubject.close();
    _searchSubscription?.cancel();
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
            // Header Section - Red with curved bottom
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: size.height * 0.25,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.danger, // Red for danger/severe
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
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.5),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Thêm tiền sử dị ứng",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Thông tin quan trọng cho an toàn sinh mạng",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
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
                    // Drug Name Field
                    _buildSectionTitle("Thuốc / Hoạt chất gây dị ứng *"),
                    Autocomplete<Map<String, dynamic>>(
                      optionsBuilder:
                          (TextEditingValue textEditingValue) async {
                            final keyword = textEditingValue.text.trim();
                            if (keyword.isEmpty) {
                              return const Iterable<
                                Map<String, dynamic>
                              >.empty();
                            }

                            await Future.delayed(
                              const Duration(milliseconds: 300),
                            );
                            if (keyword != _drugSearchController?.text.trim()) {
                              return const Iterable<
                                Map<String, dynamic>
                              >.empty();
                            }

                            if (mounted)
                              setState(() => _isSearchingDrugs = true);
                            try {
                              final results = await _drugService.searchDrugs(
                                keyword,
                              );
                              if (mounted)
                                setState(() => _isSearchingDrugs = false);
                              return results.where(
                                (drug) => drug['drugName']
                                    .toString()
                                    .toLowerCase()
                                    .startsWith(keyword.toLowerCase()),
                              );
                            } catch (e) {
                              if (mounted)
                                setState(() => _isSearchingDrugs = false);
                              return const Iterable<
                                Map<String, dynamic>
                              >.empty();
                            }
                          },
                      displayStringForOption: (option) => option['drugName'],
                      onSelected: (option) {
                        setState(() {
                          _selectedDrugId = option['drugId'];
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onFieldSubmitted) {
                            _drugSearchController = controller;
                            return TextFormField(
                              controller: controller,
                              focusNode: focusNode,
                              onChanged: (value) {
                                if (_selectedDrugId != null) {
                                  setState(() {
                                    _selectedDrugId = null;
                                  });
                                }
                              },
                              decoration: InputDecoration(
                                hintText:
                                    "Tìm tên biệt dược (VD: Penicillin...)",
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _isSearchingDrugs
                                    ? const Padding(
                                        padding: EdgeInsets.all(12.0),
                                        child: SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : null,
                                filled: true,
                                fillColor: AppColors.cardWhite,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: AppColors.border,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    _selectedDrugId == null) {
                                  return 'Vui lòng chọn thuốc từ danh sách gợi ý.';
                                }
                                return null;
                              },
                            );
                          },
                    ),
                    const SizedBox(height: 24),

                    // Severity Selection
                    _buildSectionTitle("Mức độ dị ứng *"),
                    _buildSeverityOption("Nhẹ", "Mẩn ngứa, buồn nôn", "Low"),
                    _buildSeverityOption(
                      "Trung bình",
                      "Phát ban toàn thân, sốt",
                      "Moderate",
                    ),
                    _buildSeverityOption(
                      "Nghiêm trọng",
                      "Sốc phản vệ, khó thở",
                      "High",
                      showWarningIcon: true,
                    ),
                    const SizedBox(height: 24),

                    // Symptoms Selection
                    _buildSectionTitle("Triệu chứng lâm sàng *"),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: _predefinedSymptoms.map((symptom) {
                        return ChoiceChip(
                          label: Text(symptom),
                          selected: _selectedSymptoms.contains(symptom),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedSymptoms.add(symptom);
                              } else {
                                _selectedSymptoms.remove(symptom);
                              }
                            });
                          },
                          selectedColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(
                            color: _selectedSymptoms.contains(symptom)
                                ? AppColors.primary
                                : AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                          side: BorderSide(
                            color: _selectedSymptoms.contains(symptom)
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                          backgroundColor: AppColors.cardWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _otherSymptomsController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: "Triệu chứng khác (tự điền)...",
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
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  Widget _buildSeverityOption(
    String title,
    String description,
    String value, {
    bool showWarningIcon = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selectedSeverity == value
              ? AppColors.danger
              : AppColors.border,
          width: _selectedSeverity == value ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        groupValue: _selectedSeverity,
        onChanged: (String? newValue) {
          setState(() {
            _selectedSeverity = newValue;
          });
        },
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: AppColors.textMuted),
        ),
        secondary: showWarningIcon
            ? const Icon(Icons.warning_amber_rounded, color: AppColors.danger)
            : null,
        activeColor: AppColors.danger,
        controlAffinity: ListTileControlAffinity.trailing,
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Quay lại"),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: "Xác nhận thêm dị ứng",
              onPressed: _addAllergy,
              isLoading: _isLoading,
              backgroundColor: AppColors.danger, // Red button for allergy
            ),
          ),
        ],
      ),
    );
  }
}
