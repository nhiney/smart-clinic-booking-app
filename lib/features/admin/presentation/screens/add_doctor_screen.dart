import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/extensions/context_extension.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../controllers/admin_controller.dart';
import '../../domain/entities/facility_entities.dart';

class AddDoctorScreen extends StatefulWidget {
  const AddDoctorScreen({super.key});

  @override
  State<AddDoctorScreen> createState() => _AddDoctorScreenState();
}

class _AddDoctorScreenState extends State<AddDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();

  Hospital? _selectedHospital;
  Department? _selectedDepartment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminController>().fetchHospitals();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _specialtyController.dispose();
    _bioController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AdminController>();

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text('Thêm Bác sĩ mới', style: context.textStyles.heading3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thông tin cơ bản', style: context.textStyles.bodyBold),
              const SizedBox(height: 16),
              AppTextField(
                controller: _nameController,
                labelText: 'Họ và tên bác sĩ',
                hintText: 'VD: Nguyễn Văn An',
                validator: (v) => v?.isEmpty ?? true ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _phoneController,
                labelText: 'Số điện thoại',
                hintText: 'VD: 0912345678',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 24),
              
              Text('Phân vùng công tác', style: context.textStyles.bodyBold),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<Hospital>(
                value: _selectedHospital,
                decoration: InputDecoration(
                  labelText: 'Bệnh viện',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: controller.hospitals.map((h) => DropdownMenuItem(
                  value: h,
                  child: Text(h.name),
                )).toList(),
                onChanged: (h) {
                  setState(() {
                    _selectedHospital = h;
                    _selectedDepartment = null;
                  });
                  if (h != null) controller.fetchDepartments(h.id);
                },
                validator: (v) => v == null ? 'Vui lòng chọn bệnh viện' : null,
              ),
              
              const SizedBox(height: 16),
              
              DropdownButtonFormField<Department>(
                value: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: 'Khoa chuyên môn',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: controller.selectedDepartments.map((d) => DropdownMenuItem(
                  value: d,
                  child: Text(d.name),
                )).toList(),
                onChanged: (d) => setState(() => _selectedDepartment = d),
                validator: (v) => v == null ? 'Vui lòng chọn khoa' : null,
              ),
              
              const SizedBox(height: 24),
              Text('Hồ sơ nghề nghiệp', style: context.textStyles.bodyBold),
              const SizedBox(height: 16),
              
              AppTextField(
                controller: _specialtyController,
                labelText: 'Chuyên khoa',
                hintText: 'VD: Tim mạch can thiệp',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _bioController,
                labelText: 'Mô tả ngắn',
                hintText: 'VD: 10 năm kinh nghiệm phẫu thuật...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _addressController,
                labelText: 'Địa chỉ công tác',
                hintText: 'Số 1, đường 2...',
              ),
              
              const SizedBox(height: 32),
              
              if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(controller.errorMessage!, style: const TextStyle(color: Colors.red)),
                ),
                
              AppButton(
                text: 'Tạo tài khoản Bác sĩ',
                isLoading: controller.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Mật khẩu mặc định sẽ là: Icare@123\nEmail sẽ được tự động tạo theo tên.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final controller = context.read<AdminController>();
    await controller.createDoctor(
      fullName: _nameController.text,
      hospitalId: _selectedHospital!.id,
      hospitalName: _selectedHospital!.name,
      departmentId: _selectedDepartment!.id,
      phone: _phoneController.text,
      specialty: _specialtyController.text,
      bio: _bioController.text,
      address: _addressController.text,
    );

    if (mounted && controller.errorMessage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo tài khoản bác sĩ thành công!')),
      );
      Navigator.pop(context);
    }
  }
}
