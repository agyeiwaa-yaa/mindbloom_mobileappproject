class AppSettingsState {
  const AppSettingsState({
    required this.onboardingComplete,
    required this.biometricsEnabled,
    required this.passcodeEnabled,
    this.journalReminderHour,
    this.journalReminderMinute,
  });

  final bool onboardingComplete;
  final bool biometricsEnabled;
  final bool passcodeEnabled;
  final int? journalReminderHour;
  final int? journalReminderMinute;

  AppSettingsState copyWith({
    bool? onboardingComplete,
    bool? biometricsEnabled,
    bool? passcodeEnabled,
    int? journalReminderHour,
    int? journalReminderMinute,
  }) {
    return AppSettingsState(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      passcodeEnabled: passcodeEnabled ?? this.passcodeEnabled,
      journalReminderHour: journalReminderHour ?? this.journalReminderHour,
      journalReminderMinute: journalReminderMinute ?? this.journalReminderMinute,
    );
  }
}
