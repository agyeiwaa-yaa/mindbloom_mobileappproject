import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/providers/core_providers.dart';
import '../../../../core/utils/validators.dart';
import '../../models/journal_entry.dart';
import '../providers/journal_controller.dart';

class JournalEditorPage extends ConsumerStatefulWidget {
  const JournalEditorPage({super.key, this.entry});

  final JournalEntry? entry;

  @override
  ConsumerState<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends ConsumerState<JournalEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedMood = 'Calm';
  bool _attachLocation = false;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    if (entry != null) {
      _titleController.text = entry.title;
      _contentController.text = entry.content;
      _selectedMood = entry.mood ?? 'Calm';
      _imagePath = entry.imagePath;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked == null) return;
    final savedPath = await ref.read(storageServiceProvider).persistJournalImage(picked.path);
    setState(() => _imagePath = savedPath);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.entry != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Entry' : 'New Entry')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                validator: (value) => Validators.requiredText(value, fieldName: 'Title'),
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contentController,
                validator: (value) => Validators.requiredText(value, fieldName: 'Content'),
                maxLines: 8,
                decoration: const InputDecoration(labelText: 'Reflection'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedMood,
                decoration: const InputDecoration(labelText: 'Mood tag'),
                items: ['Joyful', 'Calm', 'Okay', 'Low', 'Stressed']
                    .map((mood) => DropdownMenuItem(value: mood, child: Text(mood)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedMood = value ?? 'Calm'),
              ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                value: _attachLocation,
                contentPadding: EdgeInsets.zero,
                title: const Text('Attach current location'),
                subtitle: const Text('Adds a place label so dashboard insights can compare locations'),
                onChanged: (value) => setState(() => _attachLocation = value),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: const Text('Camera'),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Gallery'),
                  ),
                ],
              ),
              if (_imagePath != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(_imagePath!),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final location = _attachLocation
                      ? await ref.read(locationServiceProvider).getCurrentLocation()
                      : null;
                  final entry = JournalEntry(
                    id: widget.entry?.id ?? const Uuid().v4(),
                    title: _titleController.text.trim(),
                    content: _contentController.text.trim(),
                    mood: _selectedMood,
                    imagePath: _imagePath,
                    createdAt: widget.entry?.createdAt ?? DateTime.now(),
                    locationName: location?.label ?? widget.entry?.locationName,
                    latitude: location?.latitude ?? widget.entry?.latitude,
                    longitude: location?.longitude ?? widget.entry?.longitude,
                  );
                  await ref.read(journalControllerProvider.notifier).saveEntry(entry);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                },
                child: Text(isEditing ? 'Save changes' : 'Create entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
