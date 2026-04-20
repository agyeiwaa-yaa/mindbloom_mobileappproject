class AppSettingsState {
  const AppSettingsState({
    required this.onboardingComplete,
    required this.biometricsEnabled,
    required this.passcodeEnabled,
    this.apiBaseUrl,
    this.journalReminderHour,
    this.journalReminderMinute,
  });

  final bool onboardingComplete;
  final bool biometricsEnabled;
  final bool passcodeEnabled;
  final String? apiBaseUrl;
  final int? journalReminderHour;
  final int? journalReminderMinute;

  AppSettingsState copyWith({
    bool? onboardingComplete,
    bool? biometricsEnabled,
    bool? passcodeEnabled,
    String? apiBaseUrl,
    int? journalReminderHour,
    int? journalReminderMinute,
  }) {
    return AppSettingsState(
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      biometricsEnabled: biometricsEnabled ?? this.biometricsEnabled,
      passcodeEnabled: passcodeEnabled ?? this.passcodeEnabled,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      journalReminderHour: journalReminderHour ?? this.journalReminderHour,
      journalReminderMinute: journalReminderMinute ?? this.journalReminderMinute,
    );
  }
}
