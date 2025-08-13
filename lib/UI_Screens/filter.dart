import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final Map<String, dynamic>? currentFilters;
  
  const FilterScreen({Key? key, this.currentFilters}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final pink = const Color(0xFFA51C48);
  
  // Age filter
  RangeValues ageRange = const RangeValues(18, 60);
  
  // Education filter
  String? selectedEducation;
  final List<String> educationOptions = [
    'MBA', 'B.Tech', 'M.Tech', 'MBBS', 'B.Com', 'M.Com', 'BA', 'MA', 'PhD', 'Diploma'
  ];
  
  // Employment filter
  String? selectedEmployment;
  final List<String> employmentOptions = [
    'Private', 'Government', 'Business', 'Self Employed'
  ];
  
  // Location filter
  final TextEditingController locationController = TextEditingController();
  
  // Income filter
  RangeValues incomeRange = const RangeValues(0, 2000000);

  @override
  void initState() {
    super.initState();
    if (widget.currentFilters != null) {
      _loadCurrentFilters();
    }
  }

  void _loadCurrentFilters() {
    final filters = widget.currentFilters!;
    
    if (filters['from_age'] != null && filters['to_age'] != null) {
      ageRange = RangeValues(
        double.parse(filters['from_age'].toString()),
        double.parse(filters['to_age'].toString()),
      );
    }
    
    selectedEducation = filters['higher_education'];
    selectedEmployment = filters['employee_in'];
    locationController.text = filters['city'] ?? '';
    
    if (filters['from_income'] != null && filters['to_income'] != null) {
      incomeRange = RangeValues(
        double.parse(filters['from_income'].toString()),
        double.parse(filters['to_income'].toString()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: pink,
        title: const Text('Filters', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _clearFilters,
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAgeFilter(),
                  const SizedBox(height: 24),
                  _buildEducationFilter(),
                  const SizedBox(height: 24),
                  _buildEmploymentFilter(),
                  const SizedBox(height: 24),
                  _buildLocationFilter(),
                  const SizedBox(height: 24),
                  _buildIncomeFilter(),
                ],
              ),
            ),
          ),
          _buildApplyButton(),
        ],
      ),
    );
  }

  Widget _buildAgeFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Age Range', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            RangeSlider(
              values: ageRange,
              min: 18,
              max: 60,
              divisions: 42,
              activeColor: pink,
              labels: RangeLabels(
                '${ageRange.start.round()} years',
                '${ageRange.end.round()} years',
              ),
              onChanged: (values) => setState(() => ageRange = values),
            ),
            Text('${ageRange.start.round()} - ${ageRange.end.round()} years'),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Education', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedEducation,
              decoration: const InputDecoration(
                hintText: 'Select Education',
                border: OutlineInputBorder(),
              ),
              items: educationOptions.map((education) {
                return DropdownMenuItem(value: education, child: Text(education));
              }).toList(),
              onChanged: (value) => setState(() => selectedEducation = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmploymentFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Employment', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedEmployment,
              decoration: const InputDecoration(
                hintText: 'Select Employment Type',
                border: OutlineInputBorder(),
              ),
              items: employmentOptions.map((employment) {
                return DropdownMenuItem(value: employment, child: Text(employment));
              }).toList(),
              onChanged: (value) => setState(() => selectedEmployment = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                hintText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeFilter() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Annual Income', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            RangeSlider(
              values: incomeRange,
              min: 0,
              max: 2000000,
              divisions: 20,
              activeColor: pink,
              labels: RangeLabels(
                '₹${(incomeRange.start / 100000).toStringAsFixed(1)}L',
                '₹${(incomeRange.end / 100000).toStringAsFixed(1)}L',
              ),
              onChanged: (values) => setState(() => incomeRange = values),
            ),
            Text('₹${(incomeRange.start / 100000).toStringAsFixed(1)}L - ₹${(incomeRange.end / 100000).toStringAsFixed(1)}L'),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _applyFilters,
          style: ElevatedButton.styleFrom(
            backgroundColor: pink,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      ageRange = const RangeValues(18, 60);
      selectedEducation = null;
      selectedEmployment = null;
      locationController.clear();
      incomeRange = const RangeValues(0, 2000000);
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    if (ageRange.start > 18 || ageRange.end < 60) {
      filters['from_age'] = ageRange.start.round();
      filters['to_age'] = ageRange.end.round();
    }
    
    if (selectedEducation != null) {
      filters['higher_education'] = selectedEducation;
    }
    
    if (selectedEmployment != null) {
      filters['employee_in'] = selectedEmployment;
    }
    
    if (locationController.text.isNotEmpty) {
      filters['city'] = locationController.text;
    }
    
    if (incomeRange.start > 0 || incomeRange.end < 2000000) {
      filters['from_income'] = incomeRange.start.round();
      filters['to_income'] = incomeRange.end.round();
    }
    
    Navigator.pop(context, filters);
  }
}