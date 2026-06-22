// ignore_for_file: unnecessary_to_list_in_spreads, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import 'app_colors.dart';
import '../services/storage_service.dart';
import '../services/doctor_service.dart';
import '../services/drug_service.dart';
import '../services/prescription_service.dart';

class AddPrescriptionScreen extends StatefulWidget {
  const AddPrescriptionScreen({super.key});

  @override
  State<AddPrescriptionScreen> createState() => _AddPrescriptionScreenState();
}

class _AddPrescriptionScreenState extends State<AddPrescriptionScreen> {
  final _diagnosisController = TextEditingController(
    text: "Điều trị huyết áp cao",
  );
  final StorageService _storageService = StorageService();
  final DoctorService _doctorService = DoctorService();
  final DrugService _drugService = DrugService();
  final PrescriptionService _prescriptionService = PrescriptionService();
  bool _isChecking = false;
  int? _draftPrescriptionId;

  // Danh sách thuốc được chọn
  final List<Map<String, dynamic>> _selectedDrugs = [];

  final PublishSubject<String> _searchSubject = PublishSubject<String>();
  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearchingDrugs = false;
  StreamSubscription? _searchSubscription;

  int? _selectedDoctorId;
  final PublishSubject<String> _doctorSearchSubject = PublishSubject<String>();
  List<Map<String, dynamic>> _doctorSuggestions = [];
  bool _isSearchingDoctors = false;
  StreamSubscription? _doctorSearchSubscription;

  TextEditingController? _drugSearchController;
  TextEditingController? _doctorSearchController;

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

    _doctorSearchSubscription = _doctorSearchSubject
        .debounceTime(const Duration(milliseconds: 400))
        .distinct()
        .switchMap((keyword) {
          if (keyword.trim().isEmpty) {
            return Stream.value(<Map<String, dynamic>>[]);
          }
          if (mounted) {
            setState(() {
              _isSearchingDoctors = true;
            });
          }
          return Stream.fromFuture(_doctorService.searchDoctors(keyword));
        })
        .listen((results) {
          if (mounted) {
            setState(() {
              _doctorSuggestions = results;
              _isSearchingDoctors = false;
            });
          }
        });
  }

  Future<void> _showAddDrugDialog(Map<String, dynamic> drug) async {
    final dosageController = TextEditingController();
    final frequencyController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 7));

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Thêm ${drug['drugName']}",
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dosageController,
                decoration: InputDecoration(
                  labelText: "Liều lượng (VD: 5mg)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: frequencyController,
                decoration: InputDecoration(
                  labelText: "Tần suất (VD: 1 viên/ngày)",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Hủy",
                style: TextStyle(color: AppColors.textMuted),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                final dosage = dosageController.text.trim();
                final frequency = frequencyController.text.trim();
                if (dosage.isEmpty || frequency.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập liều lượng và tần suất")));
                   return;
                }

                bool draftOk = await _ensureDraftPrescriptionCreated();
                if (!draftOk) return;

                setState(() => _isChecking = true);
                
                try {
                  final token = await _storageService.getToken();
                  const String baseUrl = 'https://localhost:7170/api';
                  
                  final addRes = await http.post(
                    Uri.parse('$baseUrl/Prescriptions/$_draftPrescriptionId/items'),
                    headers: {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      "drugId": drug["drugId"],
                      "dosage": dosage,
                      "frequency": frequency,
                      "startDate": startDate.toIso8601String(),
                      "endDate": endDate.toIso8601String(),
                    }),
                  );
                  
                  if (addRes.statusCode == 200 || addRes.statusCode == 201 || addRes.statusCode == 400 || addRes.statusCode == 409) {
                    final addData = jsonDecode(addRes.body);
                    if (addData['success'] == false) {
                      if (addData['conflicts'] != null && (addData['conflicts'] as List).isNotEmpty) {
                        if (mounted) {
                          Navigator.pop(context); // Đóng modal thêm thuốc
                          _showConflictWarningModal(addData['conflicts']);
                        }
                        return; // Không thêm thuốc vào danh sách hiển thị
                      } else {
                        throw Exception(addData['message'] ?? "Lỗi thêm thuốc");
                      }
                    }
                  } else {
                     throw Exception("Server lỗi HTTP ${addRes.statusCode}");
                  }
                  
                  if (mounted) {
                    setState(() {
                      _selectedDrugs.add({
                        "drugId": drug['drugId'],
                        "drugName": drug['drugName'],
                        "dosageDesc": "$dosage • $frequency",
                        "dosage": dosage,
                        "frequency": frequency,
                        "startDate": startDate.toIso8601String(),
                        "endDate": endDate.toIso8601String(),
                        "displayDate": "${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}",
                      });
                    });
                    _drugSearchController?.clear();
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text("Đã thêm thuốc vào đơn", style: TextStyle(color: Colors.white)), backgroundColor: AppColors.success)
                    );
                  }
                } catch (e) {
                   if (mounted) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text("Lỗi: $e"), backgroundColor: AppColors.danger)
                     );
                   }
                } finally {
                   if (mounted) {
                     setState(() => _isChecking = false);
                   }
                }
              },
              child: const Text(
                "Thêm thuốc",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _ensureDraftPrescriptionCreated() async {
    if (_draftPrescriptionId != null) return true;

    if (_diagnosisController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập chẩn đoán trước khi thêm thuốc")),
      );
      return false;
    }

    try {
      final token = await _storageService.getToken();
      if (token == null) throw Exception("Không tìm thấy token");

      const String baseUrl = 'https://localhost:7170/api';
      final createRes = await http.post(
        Uri.parse('$baseUrl/Prescriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "diagnosis": _diagnosisController.text.trim(),
          "doctorId": _selectedDoctorId,
          "notes": "Tạo từ App",
        }),
      );

      if (createRes.statusCode != 200 && createRes.statusCode != 201) {
        throw Exception("Lỗi tạo đơn thuốc HTTP ${createRes.statusCode}");
      }

      int prescriptionId = 0;
      try {
        final createData = jsonDecode(createRes.body);
        if (createData is Map) {
          prescriptionId = createData['prescriptionId'] ?? createData['id'] ?? 0;
        } else if (createData is int) {
          prescriptionId = createData;
        }
      } catch (_) {
        prescriptionId = int.tryParse(createRes.body) ?? 0;
      }

      if (prescriptionId == 0) {
        throw Exception("Không thể lấy ID đơn thuốc");
      }

      _draftPrescriptionId = prescriptionId;
      return true;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tạo đơn nháp: $e"), backgroundColor: AppColors.danger),
      );
      return false;
    }
  }

  void _showConflictWarningModal(List<dynamic> conflicts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.danger,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Cảnh báo tương tác thuốc!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  "Hệ thống phát hiện các xung đột nguy hiểm nếu sử dụng kết hợp các loại thuốc trong đơn này. Vui lòng xem xét kỹ trước khi quyết định.",
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
                const SizedBox(height: 20),
                // List of conflicts
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const BouncingScrollPhysics(),
                    itemCount: conflicts.length,
                    itemBuilder: (context, index) {
                      final conflict = conflicts[index];
                      final severity = conflict['severity'] ?? 'High';
                      final description =
                          conflict['description'] ?? 'Có tương tác nguy hiểm.';
                      final type = conflict['type'] ?? 'Interaction';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.danger.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.gpp_bad_outlined,
                              color: AppColors.danger,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.danger,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Text(
                                          severity.toString().toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        type == 'Allergy'
                                            ? 'DỊ ỨNG'
                                            : 'TƯƠNG TÁC',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: AppColors.danger,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                           Navigator.pop(context); // Đóng modal
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Đã hiểu",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _checkInteractionsAndSave() async {
    if (_diagnosisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng nhập chẩn đoán")));
      return;
    }
    if (_selectedDrugs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Vui lòng thêm ít nhất 1 loại thuốc")));
      return;
    }

    _draftPrescriptionId = null; // Do not delete on pop
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Đơn thuốc đã được tạo thành công!"),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _searchSubject.close();
    _searchSubscription?.cancel();
    _doctorSearchSubject.close();
    _doctorSearchSubscription?.cancel();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (_draftPrescriptionId != null || _selectedDrugs.isNotEmpty) {
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text("Hủy tạo đơn thuốc?"),
          content: const Text(
            "Bạn có đơn thuốc chưa được hoàn tất. Bạn có muốn hủy và xóa nháp này không?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Tiếp tục", style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                if (_draftPrescriptionId != null) {
                  await _prescriptionService.deletePrescription(_draftPrescriptionId!);
                }
                if (mounted) Navigator.pop(context, true);
              },
              child: const Text(
                "Xóa & Thoát",
                style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.textDark,
            size: 20,
          ),
          onPressed: () async {
            if (await _onWillPop()) {
              if (mounted) Navigator.of(context).pop();
            }
          },
        ),
        title: const Text(
          "Tạo đơn thuốc mới",
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 2. Khu vực Khối thông tin đơn thuốc
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tên đơn thuốc / Chẩn đoán *",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _diagnosisController,
                    decoration: const InputDecoration(
                      hintText: "Nhập chẩn đoán...",
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Tên bác sĩ (Tùy chọn)",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      final keyword = textEditingValue.text.trim();
                      if (keyword.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (keyword != _doctorSearchController?.text.trim()) {
                         return const Iterable<Map<String, dynamic>>.empty();
                      }

                      if (mounted) setState(() => _isSearchingDoctors = true);
                      try {
                        final results = await _doctorService.searchDoctors(keyword);
                        if (mounted) setState(() => _isSearchingDoctors = false);
                        return results.where((doc) => doc['fullName']
                            .toString()
                            .toLowerCase()
                            .startsWith(keyword.toLowerCase()));
                      } catch (e) {
                        if (mounted) setState(() => _isSearchingDoctors = false);
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                    },
                    displayStringForOption: (option) => option['fullName'] ?? '',
                    onSelected: (option) {
                      setState(() {
                        _selectedDoctorId = option['doctorId'];
                      });
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      _doctorSearchController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: (value) {
                          if (_selectedDoctorId != null) {
                            setState(() {
                              _selectedDoctorId = null;
                            });
                          }
                        },
                        decoration: InputDecoration(
                          hintText: "Nhập tên bác sĩ kê đơn",
                          hintStyle: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                          prefixIcon: const Icon(
                            Icons.person_outline,
                            color: AppColors.textMuted,
                          ),
                          suffixIcon: _isSearchingDoctors
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
                          fillColor: Colors.white,
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
                              maxWidth: MediaQuery.of(context).size.width - 40,
                            ),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option['fullName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                                  subtitle: Text(option['specialty'] ?? 'Chưa rõ chuyên khoa', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 3. Khu vực Danh sách thuốc được thêm
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Danh sách thuốc",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.infoHighlight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${_selectedDrugs.length} thuốc",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Thẻ thuốc đã chọn
            ..._selectedDrugs.asMap().entries.map((entry) {
              int index = entry.key;
              var drug = entry.value;
              return _buildSelectedDrugCard(
                drugName: drug["drugName"],
                dosageDesc: drug["dosageDesc"],
                dateRange: drug["displayDate"],
                onDelete: () => setState(() => _selectedDrugs.removeAt(index)),
              );
            }).toList(),

            const SizedBox(height: 16),

            // Vùng tìm kiếm và thêm thuốc mới (Dashed Border effect)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.infoHighlight.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.5),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                // Ghi chú: Flutter chuẩn không có nét đứt (dashed), sử dụng solid mờ thay thế
                // hoặc cài package `dotted_border` nếu muốn đúng pixel-perfect theo Figma.
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tìm kiếm tên thuốc",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      final keyword = textEditingValue.text.trim();
                      if (keyword.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (keyword != _drugSearchController?.text.trim()) {
                         return const Iterable<Map<String, dynamic>>.empty();
                      }

                      if (mounted) setState(() => _isSearchingDrugs = true);
                      try {
                        final results = await _drugService.searchDrugs(keyword);
                        if (mounted) setState(() => _isSearchingDrugs = false);
                        return results.where((drug) => drug['drugName']
                            .toString()
                            .toLowerCase()
                            .startsWith(keyword.toLowerCase()));
                      } catch (e) {
                        if (mounted) setState(() => _isSearchingDrugs = false);
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                    },
                    displayStringForOption: (option) =>
                        option['drugName'] ?? '',
                    onSelected: (option) {
                      _showAddDrugDialog(option);
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          _drugSearchController = controller;
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              hintText: "Nhập tên thuốc hoặc hoạt chất...",
                              hintStyle: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: AppColors.textMuted,
                              ),
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
                              fillColor: Colors.white,
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
                          );
                        },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      // 4. Nút chức năng đặc biệt dưới đáy (Bottom Action)
      bottomNavigationBar: SafeArea(
        child: InkWell(
          onTap: _isChecking ? null : _checkInteractionsAndSave,
          child: Container(
            height: 60,
            color: _isChecking
                ? AppColors.primary.withOpacity(0.7)
                : AppColors.primary,
            child: _isChecking
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "TẠO ĐƠN THUỐC",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildSelectedDrugCard({
    required String drugName,
    required String dosageDesc,
    required String dateRange,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                drugName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              GestureDetector(
                onTap: onDelete,
                child: const Text(
                  "Xóa",
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dosageDesc,
            style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                dateRange,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
