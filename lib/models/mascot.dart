enum MascotState { calm, alert, panicked, celebrating }

extension MascotStateX on MascotState {
  String get moodLine => switch (this) {
        MascotState.calm => "Looking good 💚 You're on track this week.",
        MascotState.alert => "You've used 78% of your food budget and it's only Wednesday 👀",
        MascotState.panicked => "Whoa — that pushed you past your weekly limit 😬",
        MascotState.celebrating => "Proud of you! Another deposit into your future 🎉",
      };

  String get label => switch (this) {
        MascotState.calm => 'calm',
        MascotState.alert => 'alert',
        MascotState.panicked => 'panicked',
        MascotState.celebrating => 'celebrating',
      };

  static MascotState fromString(String s) => switch (s) {
        'alert' => MascotState.alert,
        'panicked' => MascotState.panicked,
        'celebrating' => MascotState.celebrating,
        _ => MascotState.calm,
      };
}

class MascotModel {
  const MascotModel({required this.state, required this.moodLine});

  factory MascotModel.fromJson(Map<String, dynamic> json) => MascotModel(
        state: MascotStateX.fromString(json['state'] as String? ?? 'calm'),
        moodLine: json['mood_line'] as String? ?? '',
      );

  final MascotState state;
  final String moodLine;
}
