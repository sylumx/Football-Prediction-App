class Prediction {
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final DateTime date;
  final String leagueName;
  final String leagueCountry;
  final String betType;
  final double recommendedOdd;
  final double confidenceLevel;
  final String? weather;
  final String? venue;
  final double? predictedHomeScore;
  final double? predictedAwayScore;

  Prediction({
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.date,
    required this.leagueName,
    required this.leagueCountry,
    required this.betType,
    required this.recommendedOdd,
    required this.confidenceLevel,
    this.weather,
    this.venue,
    this.predictedHomeScore,
    this.predictedAwayScore,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      homeTeam:
          json['home_team'] ?? json['fixture']?['homeTeam']?['name'] ?? '',
      awayTeam:
          json['away_team'] ?? json['fixture']?['awayTeam']?['name'] ?? '',
      homeTeamLogo:
          json['home_team_logo'] ?? json['fixture']?['homeTeam']?['logo'] ?? '',
      awayTeamLogo:
          json['away_team_logo'] ?? json['fixture']?['awayTeam']?['logo'] ?? '',
      date: DateTime.parse(json['fixture_date'] ??
          json['date'] ??
          DateTime.now().toIso8601String()),
      leagueName:
          json['league_name'] ?? json['fixture']?['league']?['name'] ?? '',
      leagueCountry: json['league_country'] ??
          json['fixture']?['league']?['country'] ??
          '',
      betType: json['bet_type'] ?? '',
      recommendedOdd: (json['recommended_odd'] as num?)?.toDouble() ?? 0.0,
      confidenceLevel: (json['confidence_level'] as num?)?.toDouble() ?? 0.0,
      weather: json['weather'] ?? json['fixture']?['weather']?['description'],
      venue: json['venue'] ?? json['fixture']?['venue']?['name'] ?? 'Unknown',
      predictedHomeScore: (json['predicted_home_score'] as num?)?.toDouble(),
      predictedAwayScore: (json['predicted_away_score'] as num?)?.toDouble(),
    );
  }

  String get predictedScore {
    if (predictedHomeScore == null || predictedAwayScore == null) {
      return 'N/A';
    }
    return '${predictedHomeScore!.toStringAsFixed(1)} - ${predictedAwayScore!.toStringAsFixed(1)}';
  }
}
