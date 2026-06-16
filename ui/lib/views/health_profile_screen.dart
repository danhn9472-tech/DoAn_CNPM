// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../models/health_profile.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';
import 'add_condition_screen.dart'; // Import new screen
import 'add_allergy_screen.dart'; // Import new screen

class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ProfileService _profileService = ProfileService();
  final StorageService _storageService = StorageService();
  List<PatientConditionDto> _conditions = [];
  List<PatientAllergyDto> _allergies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    final token = await _storageService.getToken();
    if (token == null) return;

    final results = await Future.wait([
      _profileService.getConditions(token),
      _profileService.getAllergies(token),
    ]);

    setState(() {
      _conditions = results[0] as List<PatientConditionDto>;
      _allergies = results[1] as List<PatientAllergyDto>;
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Hồ sơ sức khỏe", style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),
                _buildSegmentedControl(),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildConditionList(),
                      _buildAllergyList(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSegmentedControl() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textMuted,
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(text: "Bệnh lý nền"),
          Tab(text: "Dị ứng thuốc"),
        ],
      ),
    );
  }

  Widget _buildConditionList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddConditionScreen()),
              );
              if (result == true) {
                _refreshData(); // Refresh data if a new condition was added
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Thêm bệnh lý nền mới", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        Expanded(
          child: _conditions.isEmpty
              ? const Center(child: Text("Chưa có dữ liệu bệnh lý"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _conditions.length,
                  itemBuilder: (context, index) {
                    final item = _conditions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
                      child: ListTile(
                        leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                        title: Text(item.conditionName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: item.description != null
                            ? Text("${item.description!}\nChẩn đoán: ${item.diagnosisDate}", style: const TextStyle(color: AppColors.textMuted))
                            : Text("Chẩn đoán: ${item.diagnosisDate}", style: const TextStyle(color: AppColors.textMuted)),
                        isThreeLine: item.description != null,
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                          onPressed: () => _confirmDeleteCondition(item),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _confirmDeleteCondition(PatientConditionDto item) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa bệnh lý '${item.conditionName}' không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Hủy", style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text("Xóa", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteCondition(item.id);
    }
  }

  Future<void> _deleteCondition(int id) async {
    final token = await _storageService.getToken();
    if (token == null) return;

    final result = await _profileService.deleteCondition(token, id);
    if (mounted) {
      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Xóa bệnh lý thành công")),
        );
        _refreshData(); // Tự động load lại danh sách sau khi xóa thành công
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? "Xóa thất bại"),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Widget _buildAllergyList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAllergyScreen()),
              );
              if (result == true) {
                _refreshData(); // Refresh data if a new allergy was added
              }
            },
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text("Thêm tiền sử dị ứng thuốc", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger, // Red for allergy
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        Expanded(
          child: _allergies.isEmpty
              ? const Center(child: Text("Chưa có dữ liệu dị ứng"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _allergies.length,
                  itemBuilder: (context, index) {
                    final item = _allergies[index];
                    Color severityColor = _getSeverityColor(item.severity);
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12), 
                        side: BorderSide(color: severityColor.withOpacity(0.5))
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(item.drugName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: severityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                  child: Text(item.severity, style: TextStyle(color: severityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                                ),
                              ],
                            ),
                            if (item.symptoms != null && item.symptoms!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text("Triệu chứng: ${item.symptoms}", style: const TextStyle(color: AppColors.textMuted)),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high': return AppColors.danger;
      case 'moderate': return AppColors.warning;
      default: return AppColors.primary;
    }
  }
}