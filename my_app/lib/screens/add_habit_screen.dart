import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../providers/habit_provider.dart';

class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minutesController = TextEditingController();

  String _selectedIcon = '📖';
  HabitCategory _selectedCategory = HabitCategory.anytime;

  final List<String> _availableIcons = [
    '📖',
    '💪',
    '🏃',
    '🧘',
    '💧',
    '🍎',
    '😴',
    '🎯',
    '✍️',
    '🎨',
    '🎵',
    '💊',
    '🧹',
    '📱',
    '💰',
    '🙏',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('New Habit', style: theme.textTheme.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Icon selector
            Text('Choose an icon', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _buildIconSelector(isDark),

            const SizedBox(height: 24),

            // Name input
            Text('Habit name', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'e.g., Read a book',
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a habit name';
                }
                return null;
              },
            ),

            const SizedBox(height: 24),

            // Category selector
            Text(
              'When do you want to do it?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildCategorySelector(isDark),

            const SizedBox(height: 24),

            // Duration input
            Text('Duration (optional)', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            TextFormField(
              controller: _minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'e.g., 30',
                suffixText: 'minutes',
                filled: true,
                fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Create Habit',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconSelector(bool isDark) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _availableIcons.map((icon) {
        final isSelected = icon == _selectedIcon;
        return GestureDetector(
          onTap: () => setState(() => _selectedIcon = icon),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? Colors.white : Colors.black)
                  : (isDark ? Colors.grey[900] : Colors.grey[100]),
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? null
                  : Border.all(
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategorySelector(bool isDark) {
    return Row(
      children: HabitCategory.values.map((category) {
        final isSelected = category == _selectedCategory;
        String label;
        IconData icon;

        switch (category) {
          case HabitCategory.morning:
            label = 'Morning';
            icon = Icons.wb_sunny_outlined;
            break;
          case HabitCategory.evening:
            label = 'Evening';
            icon = Icons.nightlight_outlined;
            break;
          case HabitCategory.anytime:
            label = 'Anytime';
            icon = Icons.schedule;
            break;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = category),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? Colors.white : Colors.black)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : (isDark ? Colors.grey[700]! : Colors.grey[300]!),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    icon,
                    color: isSelected
                        ? (isDark ? Colors.black : Colors.white)
                        : (isDark ? Colors.white : Colors.black),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.black : Colors.white)
                          : (isDark ? Colors.white : Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<HabitProvider>();

      provider.addHabit(
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        category: _selectedCategory,
        targetMinutes: int.tryParse(_minutesController.text) ?? 0,
      );

      Navigator.pop(context);
    }
  }
}
