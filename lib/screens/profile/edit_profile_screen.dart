import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme/app_colors.dart';
import '../../config/theme/app_dimensions.dart';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _hasEquipment = false;
  String _flowPreference = 'guided';
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().userModel;
    if (user != null) {
      _nameController.text = user.name;
      _weightController.text = user.weight?.toStringAsFixed(0) ?? '';
      _heightController.text = user.height?.toStringAsFixed(0) ?? '';
      _hasEquipment = user.hasEquipment;
      _flowPreference = user.flowPreference;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final auth = context.read<AuthProvider>();
    final name = _nameController.text.trim();
    final weight = double.tryParse(_weightController.text) ?? 0;
    final height = double.tryParse(_heightController.text) ?? 0;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    await auth.updateUserProfile({
      'name': name,
      'weight': weight,
      'height': height,
      'hasEquipment': _hasEquipment,
      'flowPreference': _flowPreference,
    });

    if (auth.error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final user = auth.userModel;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profil'),
        actions: [
          if (auth.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('Simpan'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.xxl),
        child: Column(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: user?.avatarUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: Image.network(
                            user!.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                                Icons.person_rounded,
                                size: 48,
                                color: Colors.white),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? AppColors.darkBg : AppColors.lightBg,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppDimensions.xxxl),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Berat Badan',
                prefixIcon: Icon(Icons.monitor_weight_outlined),
                suffixText: 'kg',
              ),
            ),
            const SizedBox(height: AppDimensions.lg),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tinggi Badan',
                prefixIcon: Icon(Icons.height_rounded),
                suffixText: 'cm',
              ),
            ),
            const SizedBox(height: AppDimensions.xl),
            const SizedBox(height: AppDimensions.xl),
            DropdownButtonFormField<String>(
              value: _flowPreference,
              decoration: const InputDecoration(
                labelText: 'Gaya App (Flow)',
                prefixIcon: Icon(Icons.style_outlined),
              ),
              items: const [
                DropdownMenuItem(value: 'guided', child: Text('User Awam (Terpandu)')),
                DropdownMenuItem(value: 'efficient', child: Text('User Terbiasa (Efisien)')),
              ],
              onChanged: (val) => setState(() => _flowPreference = val!),
            ),
            const SizedBox(height: AppDimensions.lg),
            SwitchListTile(
              title: const Text('Memiliki Alat Latihan'),
              subtitle: const Text('Dumbbell, Pull-up bar, resistance band, dsb.'),
              value: _hasEquipment,
              onChanged: (val) => setState(() => _hasEquipment = val),
              secondary: Icon(
                _hasEquipment ? Icons.fitness_center_rounded : Icons.do_not_disturb_rounded,
                color: _hasEquipment ? AppColors.primary : AppColors.textSecondaryLight,
              ),
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primary,
            ),
            if (auth.error != null) ...[
              const SizedBox(height: AppDimensions.lg),
              Text(
                auth.error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
