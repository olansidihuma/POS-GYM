import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/member_controller.dart';
import '../../models/member_model.dart';
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
  
  // Form controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  
  String _gender = 'Male';
  DateTime _dateOfBirth = DateTime.now().subtract(const Duration(days: 6570)); // 18 years ago
  String _provinsi = '';
  String _kabupaten = '';
  String _kecamatan = '';
  String _kelurahan = '';
  
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
  }

  void _populateForm(Member member) {
    _fullNameController.text = member.fullName;
    _emailController.text = member.email;
    _phoneController.text = member.phone;
    _addressController.text = member.address;
    _emergencyContactController.text = member.emergencyContact ?? '';
    _emergencyPhoneController.text = member.emergencyPhone ?? '';
    _gender = member.gender;
    _dateOfBirth = member.dateOfBirth;
    _provinsi = member.provinsi;
    _kabupaten = member.kabupaten;
    _kecamatan = member.kecamatan;
    _kelurahan = member.kelurahan;
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
        provinsi: _provinsi,
        kabupaten: _kabupaten,
        kecamatan: _kecamatan,
        kelurahan: _kelurahan,
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
                const SizedBox(height: AppSpacing.md),
                
                // Location fields (simplified - in production, fetch from API)
                CustomTextField(
                  initialValue: _provinsi,
                  label: 'Province',
                  prefixIcon: Icons.location_city,
                  onChanged: (value) => _provinsi = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter province';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  initialValue: _kabupaten,
                  label: 'Kabupaten/Kota',
                  prefixIcon: Icons.location_city,
                  onChanged: (value) => _kabupaten = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter kabupaten';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  initialValue: _kecamatan,
                  label: 'Kecamatan',
                  prefixIcon: Icons.location_on,
                  onChanged: (value) => _kecamatan = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter kecamatan';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                
                CustomTextField(
                  initialValue: _kelurahan,
                  label: 'Kelurahan',
                  prefixIcon: Icons.location_on,
                  onChanged: (value) => _kelurahan = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter kelurahan';
                    }
                    return null;
                  },
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
