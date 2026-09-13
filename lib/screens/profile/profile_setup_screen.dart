import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';
import '../../core/state/profile_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../../widgets/common/custom_card.dart';

/// Screen for creating and editing the user's educational profile.
class ProfileSetupScreen extends StatefulWidget {
  final bool isEditing;

  const ProfileSetupScreen({super.key, this.isEditing = false});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _schoolController;

  UserRole? _selectedRole;
  String? _selectedGrade;
  String? _selectedGender;

  bool _isSaving = false;
  String? _roleError;

  // Primary school grade options
  static const List<String> primaryGrades = [
    'Class 1 (Grade 1)',
    'Class 2 (Grade 2)',
    'Class 3 (Grade 3)',
    'Class 4 (Grade 4)',
    'Class 5 (Grade 5)',
  ];

  static const List<String> genderOptions = [
    'Female',
    'Male',
    'Other',
    'Prefer not to say',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _schoolController = TextEditingController();

    // Default defaults for clean new profile
    _selectedGrade = primaryGrades.first;
    _selectedRole = UserRole.teacher;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // If editing or existing profile exists, prefill data
    final currentProfile = ProfileScope.of(context).profile;
    if (currentProfile != null && _nameController.text.isEmpty) {
      _nameController.text = currentProfile.fullName;
      _schoolController.text = currentProfile.schoolName;
      _selectedRole = currentProfile.role;
      _selectedGrade = currentProfile.grade;
      _selectedGender = currentProfile.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() {
      _roleError = _selectedRole == null ? 'Please select a role (Teacher or Student)' : null;
    });

    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final profile = UserProfile(
      fullName: _nameController.text.trim(),
      role: _selectedRole!,
      grade: _selectedGrade ?? primaryGrades.first,
      schoolName: _schoolController.text.trim(),
      gender: _selectedGender,
    );

    final controller = ProfileScope.of(context);
    await controller.saveProfile(profile);

    if (!mounted) return;

    setState(() {
      _isSaving = false;
    });

    if (widget.isEditing) {
      Navigator.of(context).pop(true);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.main, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isEditing ? 'Edit Profile' : 'Set Up Your Profile';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            children: [
              // Header description
              CustomCard(
                backgroundColor: AppColors.lavenderLight,
                borderColor: AppColors.lavenderMedium.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.badge_outlined,
                      color: AppColors.primaryLavender,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.isEditing
                            ? 'Update your institutional profile and role preferences.'
                            : 'Set up your details once to customize your classroom translation direction.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.darkCharcoal,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 1. Role Selection
              Text(
                '1. Select Your Role *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildRoleCard(
                      role: UserRole.teacher,
                      title: 'Teacher',
                      subtitle: 'Hindi → Santhali',
                      icon: Icons.school_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRoleCard(
                      role: UserRole.student,
                      title: 'Student',
                      subtitle: 'Santhali → Hindi',
                      icon: Icons.person_pin_rounded,
                    ),
                  ),
                ],
              ),
              if (_roleError != null) ...[
                const SizedBox(height: 6),
                Text(
                  _roleError!,
                  style: const TextStyle(
                    color: AppColors.statusError,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // 2. Full Name
              Text(
                '2. Full Name *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.charcoalMuted),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Full Name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Please enter at least 2 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 3. School Name
              Text(
                '3. School Name *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _schoolController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Govt Primary School, Dumka',
                  prefixIcon: Icon(Icons.account_balance_outlined, color: AppColors.charcoalMuted),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'School Name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 4. Primary School Grade
              Text(
                '4. Primary Grade / Class *',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _selectedGrade,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.menu_book_outlined, color: AppColors.charcoalMuted),
                ),
                items: primaryGrades.map((grade) {
                  return DropdownMenuItem(
                    value: grade,
                    child: Text(grade),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedGrade = val;
                  });
                },
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Please select a grade';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // 5. Gender (Optional)
              Text(
                '5. Gender (Optional)',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: genderOptions.map((gender) {
                  final isSelected = _selectedGender == gender;
                  return ChoiceChip(
                    label: Text(gender),
                    selected: isSelected,
                    selectedColor: AppColors.lavenderLight,
                    backgroundColor: AppColors.whiteCard,
                    side: BorderSide(
                      color: isSelected ? AppColors.primaryLavender : AppColors.cardBorder,
                    ),
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.lavenderDark : AppColors.charcoalMuted,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        _selectedGender = selected ? gender : null;
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          color: AppColors.whiteCard,
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1.0),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSaving ? null : _handleSave,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    widget.isEditing ? 'Save Profile Changes' : 'Complete Setup & Continue',
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required UserRole role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;

    return CustomCard(
      onTap: () {
        setState(() {
          _selectedRole = role;
          _roleError = null;
        });
      },
      backgroundColor: isSelected ? AppColors.lavenderLight : AppColors.whiteCard,
      borderColor: isSelected ? AppColors.primaryLavender : AppColors.cardBorder,
      padding: const EdgeInsets.all(14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.whiteCard : AppColors.lavenderLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primaryLavender,
                  size: 22,
                ),
              ),
              if (isSelected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryLavender,
                  size: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.darkCharcoal,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected ? AppColors.lavenderDark : AppColors.charcoalMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
