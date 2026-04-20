import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/validators.dart';
import '../../models/habit.dart';
import '../providers/habits_controller.dart';

class HabitEditorPage extends ConsumerStatefulWidget {
  const HabitEditorPage({super.key, this.habit});

  final Habit? habit;

  @override
  ConsumerState<HabitEditorPage> createState() => _HabitEditorPageState();
}

class _HabitEditorPageState extends ConsumerState<HabitEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _iconKey = 'water';
  int _targetPerWeek = 7;
  TimeOfDay? _reminderTime;
  bool _reminderEnabled = false;
  int _selectedColor = 0xFF8AB6D6;

  static const _iconChoices = {
    'water': Icons.water_drop_outlined,
    'spa': Icons.spa_outlined,
    'moon': Icons.nights_stay_outlined,
    'fitness': Icons.fitness_center_outlined,
    'gratitude': Icons.favorite_outline,
  };

  static const _colors = [0xFF8AB6D6, 0xFF7B9E87, 0xFFE68A6B, 0xFFF2C66D, 0xFFE6A57E];

  @override
  void initState() {
    super.initState();
    final habit = widget.habit;
    if (habit != null) {
      _nameController.text = habit.name;
      _iconKey = habit.iconKey;
      _targetPerWeek = habit.targetPerWeek;
      _selectedColor = habit.colorValue;
      _reminderEnabled = habit.reminderEnabled;
      if (habit.reminderHour != null && habit.reminderMinute != null) {
        _reminderTime = TimeOfDay(hour: habit.reminderHour!, minute: habit.reminderMinute!);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.habit != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Habit' : 'Create Habit')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                validator: (value) => Validators.requiredText(value, fieldName: 'Habit name'),
                decoration: const InputDecoration(labelText: 'Habit name'),
              ),
              const SizedBox(height: 16),
              Text('Icon', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _iconChoices.entries
                    .map(
                      (entry) => ChoiceChip(
                        selected: _iconKey == entry.key,
                        label: Icon(entry.value),
                        onSelected: (_) => setState(() => _iconKey = entry.key),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              Text('Accent color', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                children: _colors
                    .map(
                      (color) => GestureDetector(
                        onTap: () => setState(() => _selectedColor = color),
                        child: CircleAvatar(
                          radius: _selectedColor == color ? 22 : 18,
                          backgroundColor: Color(color),
                          child: _selectedColor == color ? const Icon(Icons.check, color: Colors.white) : null,
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _targetPerWeek,
                decoration: const InputDecoration(labelText: 'Target per week'),
                items: List.generate(7, (index) => index + 1)
                    .map((value) => DropdownMenuItem(value: value, child: Text('$value times per week')))
                    .toList(),
                onChanged: (value) => setState(() => _targetPerWeek = value ?? 7),
              ),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Enable daily reminder'),
                value: _reminderEnabled,
                onChanged: (value) => setState(() => _reminderEnabled = value),
              ),
              if (_reminderEnabled)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reminder time'),
                  subtitle: Text(_reminderTime?.format(context) ?? 'Choose a time'),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: _reminderTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      setState(() => _reminderTime = picked);
                    }
                  },
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final habit = Habit(
                    id: widget.habit?.id ?? const Uuid().v4(),
                    name: _nameController.text.trim(),
                    iconKey: _iconKey,
                    colorValue: _selectedColor,
                    targetPerWeek: _targetPerWeek,
                    reminderEnabled: _reminderEnabled,
                    reminderHour: _reminderTime?.hour,
                    reminderMinute: _reminderTime?.minute,
                    createdAt: widget.habit?.createdAt ?? DateTime.now(),
                  );
                  await ref.read(habitsControllerProvider.notifier).saveHabit(habit);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(isEditing ? 'Save habit' : 'Create habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
