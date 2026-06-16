import 'package:flutter/material.dart';
import 'app_colors.dart';
import '../models/health_profile.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

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
    if (_conditions.isEmpty) return const Center(child: Text("Chưa có dữ liệu bệnh lý"));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _conditions.length,
      itemBuilder: (context, index) {
        final item = _conditions[index];
        return Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.border)),
          child: ListTile(
            leading: const Icon(Icons.description_outlined, color: AppColors.primary),
            title: Text(item.conditionName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: item.description != null ? Text(item.description!) : null,
          ),
        );
      },
    );
  }

  Widget _buildAllergyList() {
    if (_allergies.isEmpty) return const Center(child: Text("Chưa có dữ liệu dị ứng"));
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _allergies.length,
      itemBuilder: (context, index) {
        final item = _allergies[index];
        Color severityColor = _getSeverityColor(item.severity);
        
        return Card(
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
                if (item.symptoms != null) ...[
                  const SizedBox(height: 8),
                  Text("Triệu chứng: ${item.symptoms}", style: const TextStyle(color: AppColors.textMuted)),
                ],
              ],
            ),
          ),
        );
      },
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