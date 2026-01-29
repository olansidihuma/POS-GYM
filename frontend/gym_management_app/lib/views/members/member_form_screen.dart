import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/member_controller.dart';
import '../../models/member_model.dart';
import '../../services/member_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';
import '../../utils/constants.dart';

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({Key? key}) : super(key: key);

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<MemberController>();
  final MemberService _memberService = MemberService();
  
  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  
  String _gender = 'Male';
  DateTime _dateOfBirth = DateTime.now().subtract(const Duration(days: 6570)); // 18 years ago
  
  // Regional data for cascading dropdowns
  List<Map<String, dynamic>> _provinsiList = [];
  List<Map<String, dynamic>> _kabupatenList = [];
  List<Map<String, dynamic>> _kecamatanList = [];
  List<Map<String, dynamic>> _kelurahanList = [];
  
  int? _selectedProvinsiId;
  int? _selectedKabupatenId;
  int? _selectedKecamatanId;
  int? _selectedKelurahanId;
  
  String _provinsiName = '';
  String _kabupatenName = '';
  String _kecamatanName = '';
  String _kelurahanName = '';
  
  bool _isLoadingRegions = false;
  
  Member? existingMember;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    existingMember = Get.arguments as Member?;
    if (existingMember != null) {
      isEditMode = true;
      _populateForm(existingMember!);
    }
    _loadProvinsi();
  }

  void _populateForm(Member member) {
    _fullNameController.text = member.fullName;
    _emailController.text = member.email;
    _phoneController.text = member.phone;
    _addressController.text = member.address;
    _emergencyContactController.text = member.emergencyContact ?? '';
    _emergencyPhoneController.text = member.emergencyPhone ?? '';
    _gender = member.gender.isNotEmpty ? member.gender : 'Male';
    _dateOfBirth = member.dateOfBirth;
    _provinsiName = member.provinsi;
    _kabupatenName = member.kabupaten;
    _kecamatanName = member.kecamatan;
    _kelurahanName = member.kelurahan;
  }

  Future<void> _loadProvinsi() async {
    setState(() => _isLoadingRegions = true);
    try {
      final result = await _memberService.getProvinsi();
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _provinsiList = List<Map<String, dynamic>>.from(result['data']);
        });
      }
    } catch (e) {
      // Silent fail
    } finally {
      setState(() => _isLoadingRegions = false);
    }
  }

  Future<void> _loadKabupaten(int provinsiId) async {
    setState(() {
      _isLoadingRegions = true;
      _kabupatenList = [];
      _kecamatanList = [];
      _kelurahanList = [];
      _selectedKabupatenId = null;
      _selectedKecamatanId = null;
      _selectedKelurahanId = null;
      _kabupatenName = '';
      _kecamatanName = '';
      _kelurahanName = '';
    });
    try {
      final result = await _memberService.getKabupaten(provinsiId.toString());
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _kabupatenList = List<Map<String, dynamic>>.from(result['data']);
        });
      }
    } catch (e) {
      // Silent fail
    } finally {
      setState(() => _isLoadingRegions = false);
    }
  }

  Future<void> _loadKecamatan(int kabupatenId) async {
    setState(() {
      _isLoadingRegions = true;
      _kecamatanList = [];
      _kelurahanList = [];
      _selectedKecamatanId = null;
      _selectedKelurahanId = null;
      _kecamatanName = '';
      _kelurahanName = '';
    });
    try {
      final result = await _memberService.getKecamatan(kabupatenId.toString());
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _kecamatanList = List<Map<String, dynamic>>.from(result['data']);
        });
      }
    } catch (e) {
      // Silent fail
    } finally {
      setState(() => _isLoadingRegions = false);
    }
  }

  Future<void> _loadKelurahan(int kecamatanId) async {
    setState(() {
      _isLoadingRegions = true;
      _kelurahanList = [];
      _selectedKelurahanId = null;
      _kelurahanName = '';
    });
    try {
      final result = await _memberService.getKelurahan(kecamatanId.toString());
      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _kelurahanList = List<Map<String, dynamic>>.from(result['data']);
        });
      }
    } catch (e) {
      // Silent fail
    } finally {
      setState(() => _isLoadingRegions = false);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final member = Member(
        id: existingMember?.id,
        memberCode: existingMember?.memberCode ?? 'AUTO',
        fullName: _fullNameController.text.trim(),
        gender: _gender,
        dateOfBirth: _dateOfBirth,
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        provinsi: _provinsiName,
        kabupaten: _kabupatenName,
        kecamatan: _kecamatanName,
        kelurahan: _kelurahanName,
        emergencyContact: _emergencyContactController.text.trim(),
        emergencyPhone: _emergencyPhoneController.text.trim(),
      );

      bool success;
      if (isEditMode) {
        success = await controller.updateMember(existingMember!.id!, member);
      } else {
        success = await controller.createMember(member);
      }

      if (success) {
        Get.back();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Member' : 'Add Member'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomTextField(
                  controller: _fullNameController,
                  label: 'Full Name',
                  prefixIcon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Gender Selection
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Date of Birth
                InkWell(
                  onTap: _selectDate,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    child: Text(
                      DateFormat('dd MMM yyyy').format(_dateOfBirth),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  controller: _emailController,
                  label: 'Email',
                  prefixIcon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!GetUtils.isEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  controller: _phoneController,
                  label: 'Phone',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  controller: _addressController,
                  label: 'Address',
                  prefixIcon: Icons.home,
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                
                Text(
                  'Regional Information',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Provinsi Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedProvinsiId,
                  decoration: InputDecoration(
                    labelText: 'Provinsi',
                    prefixIcon: const Icon(Icons.location_city),
                    border: const OutlineInputBorder(),
                    hintText: isEditMode && _provinsiName.isNotEmpty ? _provinsiName : 'Select Provinsi',
                  ),
                  items: _provinsiList.map((provinsi) {
                    return DropdownMenuItem<int>(
                      value: provinsi['id'] as int,
                      child: Text(provinsi['name']?.toString() ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selected = _provinsiList.firstWhere(
                        (p) => p['id'] == value,
                        orElse: () => {},
                      );
                      setState(() {
                        _selectedProvinsiId = value;
                        _provinsiName = selected['name']?.toString() ?? '';
                      });
                      _loadKabupaten(value);
                    }
                  },
                  validator: (value) {
                    if (value == null && _provinsiName.isEmpty) {
                      return 'Please select provinsi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Kabupaten/Kota Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedKabupatenId,
                  decoration: InputDecoration(
                    labelText: 'Kabupaten/Kota',
                    prefixIcon: const Icon(Icons.location_city),
                    border: const OutlineInputBorder(),
                    hintText: isEditMode && _kabupatenName.isNotEmpty ? _kabupatenName : 'Select Kabupaten/Kota',
                  ),
                  items: _kabupatenList.map((kabupaten) {
                    return DropdownMenuItem<int>(
                      value: kabupaten['id'] as int,
                      child: Text(kabupaten['name']?.toString() ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selected = _kabupatenList.firstWhere(
                        (k) => k['id'] == value,
                        orElse: () => {},
                      );
                      setState(() {
                        _selectedKabupatenId = value;
                        _kabupatenName = selected['name']?.toString() ?? '';
                      });
                      _loadKecamatan(value);
                    }
                  },
                  validator: (value) {
                    if (value == null && _kabupatenName.isEmpty) {
                      return 'Please select kabupaten/kota';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Kecamatan Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedKecamatanId,
                  decoration: InputDecoration(
                    labelText: 'Kecamatan',
                    prefixIcon: const Icon(Icons.location_on),
                    border: const OutlineInputBorder(),
                    hintText: isEditMode && _kecamatanName.isNotEmpty ? _kecamatanName : 'Select Kecamatan',
                  ),
                  items: _kecamatanList.map((kecamatan) {
                    return DropdownMenuItem<int>(
                      value: kecamatan['id'] as int,
                      child: Text(kecamatan['name']?.toString() ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selected = _kecamatanList.firstWhere(
                        (k) => k['id'] == value,
                        orElse: () => {},
                      );
                      setState(() {
                        _selectedKecamatanId = value;
                        _kecamatanName = selected['name']?.toString() ?? '';
                      });
                      _loadKelurahan(value);
                    }
                  },
                  validator: (value) {
                    if (value == null && _kecamatanName.isEmpty) {
                      return 'Please select kecamatan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                // Kelurahan Dropdown
                DropdownButtonFormField<int>(
                  value: _selectedKelurahanId,
                  decoration: InputDecoration(
                    labelText: 'Kelurahan',
                    prefixIcon: const Icon(Icons.location_on),
                    border: const OutlineInputBorder(),
                    hintText: isEditMode && _kelurahanName.isNotEmpty ? _kelurahanName : 'Select Kelurahan',
                  ),
                  items: _kelurahanList.map((kelurahan) {
                    return DropdownMenuItem<int>(
                      value: kelurahan['id'] as int,
                      child: Text(kelurahan['name']?.toString() ?? ''),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      final selected = _kelurahanList.firstWhere(
                        (k) => k['id'] == value,
                        orElse: () => {},
                      );
                      setState(() {
                        _selectedKelurahanId = value;
                        _kelurahanName = selected['name']?.toString() ?? '';
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null && _kelurahanName.isEmpty) {
                      return 'Please select kelurahan';
                    }
                    return null;
                  },
                ),
                
                if (_isLoadingRegions)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: LinearProgressIndicator(),
                  ),
                
                const SizedBox(height: AppSpacing.lg),
                
                Text(
                  'Emergency Contact (Optional)',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  controller: _emergencyContactController,
                  label: 'Emergency Contact Name',
                  prefixIcon: Icons.person_outline,
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  controller: _emergencyPhoneController,
                  label: 'Emergency Phone',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.xl),
                
                CustomButton(
                  text: isEditMode ? 'Update Member' : 'Create Member',
                  onPressed: _handleSubmit,
                  isFullWidth: true,
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
