enum MascotState { calm, alert, panicked, emergency, celebrating }

extension MascotStateX on MascotState {
  String get moodLine => switch (this) {
        MascotState.calm => "Looking good 💚 You're on track this week.",
        MascotState.alert =>
          "Spending is picking up. Maybe cook at home tonight? 🍳",
        MascotState.panicked =>
          "You've used over 70% of your budget. Slow down ya! 👀",
        MascotState.emergency =>
          "Whoa — that pushed you past your weekly limit 😬",
        MascotState.celebrating =>
          "Proud of you! Another deposit into your future 🎉",
      };

  String get label => switch (this) {
        MascotState.calm => 'calm',
        MascotState.alert => 'alert',
        MascotState.panicked => 'panicked',
        MascotState.emergency => 'emergency',
        MascotState.celebrating => 'celebrating',
      };

  static MascotState fromString(String s) => switch (s.toLowerCase()) {
        'alert' => MascotState.alert,
        'panicked' => MascotState.panicked,
        'emergency' => MascotState.emergency,
        'celebrating' => MascotState.celebrating,
        _ => MascotState.calm,
      };

  static MascotState fromPercentage(double pct) {
    if (pct >= 100) return MascotState.emergency;
    if (pct >= 70) return MascotState.panicked;
    if (pct >= 40) return MascotState.alert;
    return MascotState.calm;
  }
}

class MascotModel {
  const MascotModel({required this.state, required this.moodLine});

  factory MascotModel.fromJson(Map<String, dynamic> json) => MascotModel(
        state: MascotStateX.fromString(json['state'] as String? ?? 'calm'),
        // mood_line is the backend key
        moodLine:
            json['mood_line'] as String? ?? json['moodLine'] as String? ?? '',
      );

  final MascotState state;
  final String moodLine;
}
