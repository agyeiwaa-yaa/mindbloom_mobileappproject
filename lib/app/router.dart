import 'package:go_router/go_router.dart';

import '../features/habits/models/habit.dart';
import '../features/habits/presentation/pages/habit_editor_page.dart';
import '../features/journal/models/journal_entry.dart';
import '../features/journal/presentation/pages/journal_editor_page.dart';
import '../features/onboarding/presentation/pages/app_entry_page.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppEntryPage(),
      ),
      GoRoute(
        path: '/journal/edit',
        builder: (context, state) {
          final entry = state.extra is JournalEntry ? state.extra as JournalEntry : null;
          return JournalEditorPage(entry: entry);
        },
      ),
      GoRoute(
        path: '/habit/edit',
        builder: (context, state) {
          final habit = state.extra is Habit ? state.extra as Habit : null;
          return HabitEditorPage(habit: habit);
        },
      ),
    ],
  );
}
