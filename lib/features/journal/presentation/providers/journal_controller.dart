import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../models/journal_entry.dart';

final journalControllerProvider =
    AsyncNotifierProvider<JournalController, List<JournalEntry>>(JournalController.new);

class JournalController extends AsyncNotifier<List<JournalEntry>> {
  @override
  Future<List<JournalEntry>> build() async {
    return ref.read(databaseServiceProvider).fetchJournals();
  }

  Future<void> saveEntry(JournalEntry entry) async {
    await ref.read(databaseServiceProvider).upsertJournal(entry);
    state = AsyncData(await ref.read(databaseServiceProvider).fetchJournals());
  }

  Future<void> deleteEntry(String id) async {
    await ref.read(databaseServiceProvider).deleteJournal(id);
    state = AsyncData(await ref.read(databaseServiceProvider).fetchJournals());
  }
}
