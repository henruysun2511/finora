class NotificationPreferences {
  final bool pushNotifications;
  final bool emailNotifications;
  final bool budgetAlerts;
  final bool loanReminders;
  final bool mascotEvolutionAlerts;
  final bool friendActivityAlerts;

  const NotificationPreferences({
    this.pushNotifications = true,
    this.emailNotifications = true,
    this.budgetAlerts = true,
    this.loanReminders = true,
    this.mascotEvolutionAlerts = true,
    this.friendActivityAlerts = true,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationPreferences();
    return NotificationPreferences(
      pushNotifications: map['pushNotifications'] as bool? ?? true,
      emailNotifications: map['emailNotifications'] as bool? ?? true,
      budgetAlerts: map['budgetAlerts'] as bool? ?? true,
      loanReminders: map['loanReminders'] as bool? ?? true,
      mascotEvolutionAlerts: map['mascotEvolutionAlerts'] as bool? ?? true,
      friendActivityAlerts: map['friendActivityAlerts'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'pushNotifications': pushNotifications,
      'emailNotifications': emailNotifications,
      'budgetAlerts': budgetAlerts,
      'loanReminders': loanReminders,
      'mascotEvolutionAlerts': mascotEvolutionAlerts,
      'friendActivityAlerts': friendActivityAlerts,
    };
  }

  NotificationPreferences copyWith({
    bool? pushNotifications,
    bool? emailNotifications,
    bool? budgetAlerts,
    bool? loanReminders,
    bool? mascotEvolutionAlerts,
    bool? friendActivityAlerts,
  }) {
    return NotificationPreferences(
      pushNotifications: pushNotifications ?? this.pushNotifications,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      loanReminders: loanReminders ?? this.loanReminders,
      mascotEvolutionAlerts: mascotEvolutionAlerts ?? this.mascotEvolutionAlerts,
      friendActivityAlerts: friendActivityAlerts ?? this.friendActivityAlerts,
    );
  }
}
